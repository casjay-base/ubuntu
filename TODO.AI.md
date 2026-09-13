# TODO.AI.md

## Pre-existing `script-lint` violations found 2026-09-13 (centos->rhel rename sweep)

Surfaced incidentally while updating hardcoded `casjay-base/centos` URLs
to `casjay-base/rhel` in `run-os-update` and `update-resolv.sh` —
confirmed via `git diff` that these predate this edit (only the URL
lines changed). Re-run `script-lint` for exact current line numbers
before fixing.

- [ ] `root/.local/bin/run-os-update`: functions missing required `__`
      prefix (`devnull`, `execute`, `run_grub`, `rm_if_exists`); ~14
      `grep` calls missing `--` before the query; bare `exit` with no
      code; missing trailing newline; `echo "$user" | awk` avoidable
      subshell fork
- [ ] `root/.local/bin/update-resolv.sh`: bare `exit` with no code;
      missing trailing newline
- [ ] `etc/cron.d/run-os-update`: cron line exceeds 180 characters;
      missing trailing newline
