#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202305090019-git
# @@Author           :  Jason Hempstead
# @@Contact          :  git-admin@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  update-resolv.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Sep 06, 2022 15:18 EDT
# @@File             :  update-resolv.sh
# @@Description      :  Update the Resolver config
# @@Changelog        :  newScript
# @@TODO             :  Refactor code
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  bash/system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__fetch() {
  curl -q -LSsf "https://github.com/casjay-base/centos/raw/main/etc/resolv.conf" -o "/tmp/resolv.conf"
  return $?
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__default_resolv() {
  cat <<EOF | tee "/etc/resolv.conf" &>/dev/null
# DNS Resolver
search casjay.in
nameserver 1.1.1.1
nameserver 8.8.8.8
#nameserver 132.226.33.75

EOF
  [ -f "/etc/resolv.conf" ] || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$1" = "update" ]; then
  exitCode=0
  RAW_URL="https://raw.githubusercontent.com/casjay-base/centos/main/root/.local/bin"
  for f in root_certbot.sh root_changeip.sh root_clean.sh root_dhparams.sh run-os-update update-resolv.sh; do
    curl -q -LSsf "$RAW_URL/$f" -o "/tmp/$f" 2>/dev/null && true || { exitCode=$(($exitCode + 1)) && false; }
    [ -f "/tmp/$f" ] && chmod -Rf 755 "/tmp/$f" && mv -f "/tmp/$f" "/root/.local/bin/$f"
  done
  exit $exitCode
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "/etc/resolv.conf" ] && chattr -i "/etc/resolv.conf"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -n "$(type -P update-resolv)" ]; then
  update-resolv "$@"
elif __fetch; then
  [ -f "/tmp/resolv.conf" ] && mv -f "/tmp/resolv.conf" "/etc/resolv.conf"
  [ -f "/tmp/resolv.conf" ] && rm -Rf "/tmp/resolv.conf"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "/etc/resolv.conf" ] || __default_resolv
[ -f "/etc/resolv.conf" ] && chattr +i "/etc/resolv.conf"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end
