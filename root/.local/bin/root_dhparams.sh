#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202305090019-git
# @@Author           :  Jason Hempstead
# @@Contact          :  git-admin@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  README.md
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Sep 06, 2022 15:18 EDT
# @@File             :  root_dhparams.sh
# @@Description      :  Update dhparams
# @@Changelog        :  Updated to use 2048
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  shell/sh
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -n "$(builtin type -P openssl 2>/dev/null)" ] || exit 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TMP="${TMP:-/tmp}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -d "/etc/ssl/CA/CasjaysDev/dhparam" ]; then
  DHDIR="${DHDIR:-/etc/ssl/CA/CasjaysDev/dhparam}"
elif [ -d "/etc/ssl/CA/dh" ]; then
  DHDIR="/etc/ssl/CA/dh/"
else
  DHDIR="/etc/ssl/dhparam"
  mkdir -p "/etc/ssl/dhparam"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
openssl dhparam -out "$TMP/dhparams1024.pem" 1024 >/dev/null 2>&1 && mv -f "$TMP/dhparams1024.pem" "$DHDIR/1024.pem"
openssl dhparam -out "$TMP/dhparams2048.pem" 2048 >/dev/null 2>&1 && mv -f "$TMP/dhparams2048.pem" "$DHDIR/2048.pem"
openssl dhparam -out "$TMP/dhparams4096.pem" 4096 >/dev/null 2>&1 && mv -f "$TMP/dhparams4096.pem" "$DHDIR/4096.pem"
[ -f "$DHDIR/2048.pem" ] && for dhpem in apache nginx postfix proftpd httpd; do cat "$DHDIR/2048.pem" >"$DHDIR/$dhpem.pem"; done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
