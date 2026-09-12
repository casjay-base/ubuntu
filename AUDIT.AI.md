# Security audit — centos/etc (source of truth)

Read-only audit performed via `security-auditor` agent, 2026-08-31. Nothing
fixed yet. Fix `centos/` first, then re-run `sync.sh` and re-check whether
each finding also applies to the derived distros (fedora/debian/ubuntu/
raspbian/arch/alpine) before considering this closed. `pkmgr/min.sh` and
`sync.sh` themselves were NOT reviewed — do that as a follow-up pass.

Logrotate findings below already reflect the finalized policy: `rotate 0`
(no retained backups) + `nocompress` for all logs; security logs (wtmp,
btmp, secure, ssh, maillog) get `maxage 180` + `maxsize 100M` instead of
immediate discard; everything else rotates monthly OR at a size threshold
(10/50/100M by verbosity) whichever comes first.

## CRITICAL

- [ ] 1. Real TLS private key committed and trusted by Cockpit —
      `etc/ssl/CA/CasjaysDev/private/localhost.key`,
      `etc/cockpit/ws-certs.d/localhost.key`,
      `etc/cockpit/ws-certs.d/1-my-cert.cert` (contains the key, not just
      the cert) — matches committed cert CN=casjay.net, valid to
      2031-11-18. MUST revoke+regenerate and purge from git history
      (`git filter-repo`) — already permanently burned since public.
      Generate at bootstrap into a gitignored path instead.
- [ ] 2. Shorewall default policy fully open, both IPv4 and IPv6 —
      `etc/shorewall/policy:4-5`, `etc/shorewall6/policy:4-5` = ACCEPT/
      ACCEPT; `rules` files are empty. No filtering exists at all. Change
      to DROP defaults + explicit per-service ACCEPT rules.
- [ ] 3. SNMP: `rwcommunity publicrw` (unauthenticated, any source, full
      MIB write) + `rocommunity public` — `etc/snmp/snmpd.conf:10-13,15,
      23-26`. Remove rw entirely; restrict ro to 127.0.0.1; move to SNMPv3.
- [ ] 4. Samba: `map to guest = Bad User` + `guest ok = yes` + `force
      user = root` + `create mask = 0777` on `[tmp]` and `[backups]` —
      `etc/samba/smb.conf`. Anonymous root-owned writes into the backup
      set and /tmp. Remove guest/public/force-user; add
      `server min protocol = SMB2`, `server signing = mandatory`.
- [ ] 5. rsyncd exports `/mnt/backups` anonymously, `uid = root`, no auth
      users/secrets/hosts allow — `etc/rsyncd.conf`,
      `etc/rsync.d/{backup,ftp}.conf`. Add auth + secrets file (0600) +
      hosts allow; drop uid to non-root.
- [ ] 6. Tor: SOCKS/HTTP/DNS proxy bound `0.0.0.0`, no SocksPolicy, plus
      `ExitRelay 1` — `etc/tor/torrc:25-31,53-59`. Open proxy + SSRF pivot
      to every loopback service. Bind to 127.0.0.1, add
      `SocksPolicy accept 127.0.0.0/8 / reject *`, drop exit relay.
- [ ] 7. MySQL: hardcoded `[client] password` in world-readable
      `my.cnf:2-3`, no `bind-address` (defaults to 0.0.0.0 → internet-
      exposed given #2), `general_log = 2` logging cleartext
      CREATE/SET PASSWORD statements forever (no rotation, see #21).
      Remove password line, add `bind-address = 127.0.0.1`,
      `general_log = 0`.
- [ ] 8. PHP `allow_url_include = On` (`php.ini:80`) + empty
      `disable_functions` (`:18`) — turns any include($_GET[]) bug into
      unauthenticated RCE. Set `allow_url_include = Off`, populate
      `disable_functions`.

## HIGH

- [ ] 9. Daily root cron pipes unauthenticated `curl` output to `bash`,
      unpinned `main` ref, no signature — `cron.d/run-os-update:2`. Pin to
      a commit SHA + verify signature, or drop the fallback.
- [ ] 10. Apache `<Directory />` has no `Require all denied` (stock RHEL
      default removed) with `Options All` + `AllowOverride All` —
      `httpd.conf:123-138`. Restore deny-by-default, `Options None`.
- [ ] 11. `/cgi-bin` executes `.sh .php .js .go` as CGI, world-accessible,
      `AllowOverride All` — `httpd.conf:154-160`,
      `nginx/global.d/cgi-bin.conf`. Strip non-`.cgi/.pl` handlers,
      `AllowOverride None`.
- [ ] 12. Munin has zero access control on `/munin` and `/munin-cgi` (both
      Apache and nginx configs) — empty `munin-htpasswd` is never
      referenced anywhere. Add AuthType Basic + AuthUserFile + Require
      valid-user to both vhost configs; generate htpasswd at bootstrap.
- [ ] 13. munin-node runs plugins as root, zero `allow`/`cidr_allow` ACL —
      `munin-node.conf`. Add `cidr_allow 127.0.0.1/32`; drop root where
      plugins allow.
- [ ] 14. sshd_config: `PermitRootLogin yes`, `PasswordAuthentication yes`,
      `MaxSessions 99999`, `LoginGraceTime 300`, `GSSAPIAuthentication
      yes`, no cipher/kex/MAC hardening (client config has it, server
      doesn't) — `sshd_config:12,13,16,21,32`. Harden to match
      `ssh_config`'s crypto pins; `PermitRootLogin prohibit-password`;
      `PasswordAuthentication no`; `MaxSessions 10`; `LoginGraceTime 30`.
- [ ] 15. ProFTPD: `RootLogin on`, `TLSRequired off` (cleartext root
      password over network), `AllowForeignAddress on` (FTP bounce),
      `TLSProtocol` includes TLSv1/1.1 — `proftpd.conf`,
      `proftpd.d/tls.conf`. `RootLogin off`, `TLSRequired on`,
      `AllowForeignAddress off`, drop TLSv1/1.1.
- [ ] 16. fail2ban: stray `banaction = firewallcmd-ipset` in
      `jail.d/00-firewalld.conf` contradicts `action = shorewall` in
      `jail.local` (footgun for any jail added without an explicit
      action); no nginx jail despite nginx being the internet-facing TLS
      terminator (Apache jail bans the proxy, not the real client IP —
      also needs `set_real_ip_from`/`real_ip_header` in nginx); duplicate
      `logpath` in `[proftpd]` silently drops `/var/log/auth.log`; no
      `recidive` jail. Delete the firewalld banaction file, add nginx +
      recidive jails, fix the duplicate logpath.
- [ ] 17. Postfix `mynetworks` trusts all of `10/8`, `172.16/12`,
      `192.168/16`, malformed `fd00::/8` (should be `fc00::/7` scope) —
      `postfix/mynetworks:5-9`. Not an open relay to the internet, but any
      device on any of those private ranges can relay authenticated
      onward mail via `relayhost`. Narrow to the actual server subnet.
- [ ] 18. Apache emits `Access-Control-Allow-Origin: *` (incl. DELETE/PUT)
      on every vhost, a syntactically invalid `Content-Security-Policy
      "*"` (browsers discard it — zero XSS protection despite appearing
      configured), and a malformed `Header always add Header "..."`
      timing-leak line — `httpd.conf:222-227`. Remove all five lines; set
      CORS per-vhost with an explicit allowlist; write a real CSP.
- [ ] 19. `ssh_config` sets `ForwardX11Trusted yes` under `Host *` — any
      compromised remote host can keylog/screenshot the local X session.
      Set `ForwardX11 no` globally; enable per-host only, never Trusted.

## MEDIUM

- [ ] 20. SELinux disabled (`selinux/config`, `sysconfig/selinux`) — set
      `enforcing` (or `permissive` first to collect denials).
- [ ] 21. Logrotate gaps against policy (rotate 0 / nocompress / monthly-
      or-size / security logs maxage 180 + 100M):
  - `logrotate.conf` global stanza + `/var/log/btmp`: no `maxsize` at
    all (time-only) — btmp is exactly the file that fills fastest under
    the brute-force exposure from #2+#14.
  - `logrotate.d/named`, `logrotate.d/munin`: no `maxsize`, no explicit
    `rotate` (inherits ok, but no size cap).
  - secure/maillog/auth.log/mail.log currently use `maxsize 100M`
    uniformly — per policy these are the security-tier logs and should
    carry `maxage 180` alongside the size cap (add `maxage 180` to
    these stanzas specifically; other logs stay rotate-0/no-maxage).
  - **No logrotate stanza exists at all** for: httpd, nginx, proftpd
    (4 logs), php-fpm, fail2ban, rsyncd, mysql, samba, tor. Add stanzas
    for each, sized 10/50/100M by verbosity, `nocompress`, `rotate 0`
    (or `maxage 180` if it's a security-relevant log per the list above).
  - `logrotate.d/munin:8` — `postrotate` restarts munin/munin-node
    unnecessarily (already using `copytruncate` on line 6); drop the
    restart, it causes a monthly monitoring outage.
  - `cron.daily/logrotate` duplicates RHEL 9's `logrotate.timer` systemd
    unit — risk of double-rotation discarding a log the first run just
    created under `rotate 0`. Pick one mechanism.
- [ ] 22. PHP session/error hardening — `php.ini`: `display_errors = On`
      (`:33`, leaks paths/SQL/stack traces — set Off, log_errors already
      on); `session.cookie_httponly` empty (`:245` — XSS → full session
      theft, set On); no `session.cookie_secure`; `session.use_strict_mode
      = 0` (`:236` — session fixation, set 1); 6-day session lifetime
      never idle-expiring (`:242,249`); `post_max_size = 10G` /
      `upload_max_filesize = 1G` / `max_execution_time = 3600` (`:56,77,
      27` — disk-fill / worker-exhaustion DoS, reduce all three).
- [ ] 23. sysctl.conf: `send_redirects = 1` (should be 0, non-router host),
      `proxy_arp = 1` on all interfaces (ARP hijack risk), `log_martians
      = 0` (disables spoofed-packet logging) — lines 17-27. Missing
      entirely: `rp_filter`, `accept_redirects = 0`, `secure_redirects =
      0`, `accept_source_route = 0`, `net.ipv6.conf.all.accept_ra = 0`,
      `kernel.kptr_restrict`, `kernel.dmesg_restrict`. `ip_forward = 1`
      stays (needed for Docker).
- [ ] 24. Cockpit `disallowed-users` is empty (upstream ships `root`) —
      re-enables root login to the Cockpit web UI. Restore `root` to the
      file.
- [ ] 25. Committed placeholder passwords that deploy verbatim (not in the
      sed substitution list) — `munin/plugin-conf.d/munin-node` (mysql/
      pgsql/ldap-bindpw/squid/generic — `mysecurepassword`, `amp111`),
      `my.cnf:3` (`supersecretpassword`). Move to a gitignored
      `*.local` generated at bootstrap; add to the placeholder
      substitution list so an unsubstituted deploy fails loudly instead
      of silently shipping a known password.
- [ ] 26. Docker: `daemon.json` enables `ipv6`/`ip6tables` but
      `shorewall6/zones` has no `dock` zone (IPv4 has one, with
      `dock $FW REJECT`) and no `fixed-cidr-v6` is set — containers can
      get globally-routable IPv6 reachable directly from the internet,
      bypassing IPv4 port-publishing discipline. Also `"experimental":
      true` on a production host. Mirror the `dock` zone into shorewall6,
      set `fixed-cidr-v6` (ULA), drop `experimental`, add
      `"no-new-privileges": true`, `"icc": false`, `"live-restore": true`.
- [ ] 27. `login.defs`: `PASS_MAX_DAYS 99999` (never expires),
      `PASS_MIN_DAYS 0`; no `pam_pwquality` config anywhere in the tree,
      so password length/complexity has no real floor given
      `PasswordAuthentication yes` on sshd (#14). Set `PASS_MAX_DAYS
      365`, `PASS_MIN_DAYS 1`, ship `/etc/security/pwquality.conf`.
- [ ] 28. Expired private-CA anchor in system trust store —
      `pki/ca-trust/source/anchors/CasjaysDev.crt`, expired ~2024-04-09.
      Remove; the CA's private key is not in this repo (checked), so no
      compromise, just dead/silently-breaking trust. If a private CA is
      still needed, regenerate fresh and keep the key offline.

## LOW / INFO

- [ ] 29. `ServerSignature EMail` leaks an email address on every Apache
      error page, contradicts `ServerTokens Prod` — set `Off`.
- [ ] 30. `/health/apache` uses deprecated `Order Deny,Allow` syntax —
      migrate to `Require ip` (mod_access_compat still works but is
      legacy); note RFC1918 isn't a real trust boundary here given #6.
- [ ] 31. `SSLProxyCheckPeerName/CN/Expire off` disables cert validation
      for all outbound mod_proxy HTTPS — low impact today (loopback-ish
      target) but MITM-able for any future proxy target.
- [ ] 32. `Options Indexes` on shared asset paths + `~/Public/html` —
      directory listing enabled broadly; low value alone but consistent
      with #10's posture problem.
- [ ] 33. No `server_tokens off;` in nginx.conf (version disclosure); no
      HSTS observed at the nginx layer specifically (Apache sets one
      behind it — verify it actually reaches the client through the
      double-TLS-termination setup).
- [ ] 34. `named.conf` uses `dnssec-enable`/`dnssec-lookaside`/
      `bindkeys-file`, all removed in BIND 9.16+ (RHEL 9 ships 9.16) —
      named will fail to start. Access controls (`listen-on 127.0.0.1`,
      `allow-query localhost`) are correct — not an open resolver.
- [ ] 35. `dnf.conf`: `skip_if_unavailable=True` can silently skip
      security updates from a failing repo; `localpkg_gpgcheck` unset
      (defaults off) — locally-installed RPMs bypass signature checks.
- [ ] 36. `resolv.conf` hardcodes a specific third-party resolver IP
      (`82.29.128.43`) alongside 1.1.1.1/8.8.8.8 — baked into a public
      repo; will silently become someone else's server if reassigned.
- [ ] 37. `profile`/`bashrc` set `umask 002` (UPG convention) vs
      `login.defs UMASK 077` — standard RHEL behavior but worth a
      conscious decision; 002 means group-writable files by default.
- [ ] 38. `cron.d/yum-update` unattended daily `yum update -y` gated on
      `ping google.com` — availability risk (unreviewed updates), and the
      ping-as-connectivity-check fails closed on ICMP-blocking networks.
- [ ] 39. `proftpd.d/tls.conf`: `TLSOptions NoSessionReuseRequired`
      weakens control/data-channel binding — fix alongside #15.
- [ ] 40. Committed 1024-bit DH param file (`ssl/dhparam/1024.pem`) —
      unused (4096-bit one is referenced instead) but should be deleted;
      1024-bit DH is within reach of precomputation attacks (Logjam).
- [ ] 41. php-fpm `www.conf` is mostly correct (loopback-bound, allowed
      clients restricted, clear_env yes) — only `display_errors = on`
      needs to flip per #22; `pm.status_path`/`ping.path` aren't
      currently exposed by any vhost.
- [ ] 42. `certbot/dns.conf` `dns_rfc2136_secret` is empty (no committed
      secret) — flag only that deployed file mode should be 0600; repo/
      rsync overlay doesn't appear to enforce per-file modes.

## Not reviewed — follow-up needed

- `root/`, `usr/`, `var/` in this same repo — `usr/` and
  `root/.local/bin/` hold the actual scripts invoked by every `cron.d`
  entry (`run-os-update`, `process-check.sh`, `clean-system`,
  `update-resolv.sh`, `root_certbot.sh`), all running as root. Unreviewed;
  this is where finding #9's actual downloaded payload lives.
- `pkmgr/centos/scripts/min.sh` and `casjay-base/sync.sh` — not read for
  this pass; `sync.sh` decides how every finding above gets rewritten for
  the other 6 distros, so a per-distro re-check is needed after fixes land.
- File modes/ownership on deploy — this repo can't express them; several
  findings (#1 key files, #7 my.cnf, #25 plugin-conf.d, #42 certbot)
  depend on deployed permissions the repo alone can't guarantee.
- The other six distro trees were assumed to mirror these findings but
  were not independently checked — in particular whether the committed
  private key (#1) exists in all seven trees.
- Git history was not audited beyond confirming the key's commit
  (`42a5ace3f005`) — run `gitleaks --log-opts=--all` before remediation
  since the repo is public and history already leaked once.
- Not individually examined: `httpd/conf.modules.d/*`, `httpd/conf/magic`,
  most `shorewall*/` non-policy files, `postfix/` map files (canonical/
  transport/virtual/relocated/mydomains*), `skel/.config/bash/**` beyond
  umask, `ntp.conf`/`chrony.conf`, `webalizer.conf`, `vnstat.conf`,
  `uptimed.conf`, `tmpfiles.d/*`, `fail2ban/action.d/shorewall*.conf`,
  `fail2ban/filter.d/fail2ban.conf`, `fail2ban/ips.txt`.
- No runtime host was inspected — all findings are static-config only.
