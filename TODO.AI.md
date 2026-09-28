# TODO

Pre-existing `script-lint` violations found while linting unrelated
diffs. Not in the lines each companion commit touched - logged here
rather than fixed inline to keep those commits' diffs scoped to their
actual changes.

## root/.local/bin/root_dhparams.sh (found 2026-09-04, AUDIT.AI.md #40
companion commit)

- [ ] Header `##@Version` (202305090019-git) has no matching `VERSION=`
      assignment in the script body - add one or drop the header field
- [ ] `DHDIR="${DHDIR:-...}"` on line 25 is read as a caller-settable
      override but uses a bare name; rename to the script-name-prefixed
      `ROOT_DHPARAMS_DHDIR` throughout the file

## root/.local/bin/run-os-update (found 2026-09-09, firewalld fix
companion commit)

Fixed 2026-09-17: `__` prefix on `devnull`/`execute`/`run_grub`/
`rm_if_exists` (+ all call sites); `##@Version` header synced to
`VERSION=`; `--` added before every grep query; all bare `exit`
converted to `exit 0`/`1`. Remaining, not yet fixed:

- [ ] Add a `--color` flag to the argument parser
- [ ] Check the `NO_COLOR` env var before emitting color codes
      (lines ~220-229)
- [ ] Inline comments at lines 221–229 (color definitions) — move above
      the line each describes
- [ ] `local` missing on `pkgs="$(rpm -qa ...)"` in `__kernel_ml` (line
      93) and `__kernel_lt` (line 127)
- [ ] UUOC: `grub_bin_name="$(basename "$grub_bin" ...)"` (line 146),
      `filename="$(basename "$file")"` (line 510) — use `"${var##*/}"`;
      `$(dirname "$path")` at lines 493, 637, 722 — use `"${path%/*}"`
- [ ] UUOC: `echo "$PATH" | grep -q -- "/root/.local/bin"` (line 218) —
      use `[[ "$PATH" == */root/.local/bin* ]]`
- [ ] Missing man page (`man/run-os-update.1`) and bash completions
      (`completions/_run-os-update_completions.bash`) — route to
      doc-sync agent

## root/.local/bin/update-resolv.sh (found 2026-09-13, centos->rhel
rename companion commit — not on lines that commit touched)

- [ ] Header `##@Version` has no matching `VERSION=` assignment in the
      script body — add one or drop the header field
- [ ] `exit $exitCode` at line 44 can exit with a code outside the
      allowed range (0-2, 64-78, 128-143) when multiple curl failures
      accumulate — clamp or map to an allowed code

## Pre-existing violations found 2026-09-09 (fail2ban jail.local
disable-by-default companion commit — none on lines that commit touched;
only config files changed, no scripts)

- [ ] root/.local/bin/root_certbot.sh line 50: add `--` before the grep
      query — `grep -s -- 'dns_rfc2136_secret = '`
- [ ] root/.local/bin/update-resolv.sh line 59: bare `exit` — use
      `exit 0`/`1`/`"$?"`
- [ ] root/.local/bin/process-check.sh: add `--` before the grep query at
      lines 42 (x3), 47 (x4), 59, 73, 74, 80, 81
- [ ] root/.local/bin/root_clean.sh lines 20-21: inline comments on code
      lines — move `# added in /etc/logrotate.conf` above each
      `[ -f ... ] && rm -Rf ...` line
- [ ] etc/skel/.config/bash/functions/global.sh: rename function `geany`
      to `__geany` (line 21); add `--` before the grep query at lines 39,
      52, 53 (x2)
