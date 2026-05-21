#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202305090019-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  process-check --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Feb 28, 2023 14:45 EST
# @@File             :  process-check
# @@Description      :  Check and restart failed processes
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  shell/sh
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202305090019-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
FULL_HOSTNAME="$(hostname -f || echo "$HOSTNAME")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initial debugging
[ "$1" = "--debug" ] && set -x && export SCRIPT_OPTS="--debug" && export _DEBUG="on"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# pipes fail
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set process check
PROCS="nginx httpd postfix crond dockerd sshd php-fpm "
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User defined functions
__check_url() { curl -q -LSsfI --max-time 3 --max-time 2 --retry 1 "$1" >/dev/null 2>&1 || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__proc_check() {
  proc="$(ps aux 2>&1 | grep -v 'grep' | grep -w "$1" | head -n1 | grep -q "$1" && echo "$1" || false)"
  [ -n "$proc" ] || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__get_proc_port() {
  port="$(netstat -tapln | grep "$1" | tr ' ' '\n' | grep -v '^$' | grep ':[0-9]' | head -n 1 | sed 's|.*:||g' | head -n1 | grep '[0-9]' || false)"
  [ -n "$port" ] && printf '%s\n' "$port" || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__website_check() {
  check="$(__get_proc_port "$1")"
  url="${2:-}"
  [ -n "$check" ] && [ -n "$url" ] && __check_url "${url%:*}" || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__service_restart() {
  exitcode=0
  systemctl list-unit-files | grep -qw "$1" || return 0
  systemctl restart "$1" &>/dev/null 2>&1
  systemctl is-active "$1" &>/dev/null || exitcode=1
  return $exitcode
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set exitCode variables
exitProcCode=0
exithttpdCode=0
exitnginxCode=0
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# get apache domains and port
if [ -d "/etc/apache2" ] && __proc_check "httpd"; then
  set_httpd_proto="http"
  get_httpd_domains="$(grep --no-filename -R 'ServerName ' /etc/apache2 | grep -Ev '#|localhost|unknown' | sed 's|.* ||g;s|;||g;s|server_name ||g' | grep -v '\*' | grep '[a-z0-9]' | sort -u | grep '^' || echo '')"
  get_httpd_port="$(grep -R --no-filename 'Listen ' /etc/apache2/conf/httpd.conf | grep -v '#' | awk -F ' ' '{print $2}' | sort -u | head -n1 | grep '^' || echo '')"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# get nginx domains and port
if [ -d "/etc/nginx" ] && __proc_check "nginx"; then
  set_nginx_proto="https"
  get_nginx_domains="$(grep -R --no-filename 'server_name ' /etc/nginx | grep -Ev '#|localhost|unknown' | sed 's|.* ||g;s|;||g;s|server_name ||g' | grep -v '\*' | grep '[a-z0-9]' | sort -u | grep '^' || echo '')"
  get_nginx_port="$(grep -R --no-filename 'listen ' /etc/nginx | grep ' [0-9][0-9]' | awk -F ' ' '{print $2}' | sort -u | head -n1 | grep '^' || echo '')"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check and restart broken processes
for proc in $PROCS; do
  if [ -n "$proc" ]; then
    if __proc_check "$proc"; then
      printf '%s\n' "$proc is running"
    elif systemctl is-enabled "$proc" &>/dev/null; then
      printf '%s\n' "Attempting to restart $proc"
      __service_restart "$proc" &>/dev/null
      exitProcCode=$((1 + exitProcCode))
    fi
  fi
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check apache hosts by default mine are http
for httpd_site in $get_httpd_domains; do
  if [ -n "$httpd_site" ]; then
    url="${set_httpd_proto:-http}://$httpd_site:$get_httpd_port"
    printf '%s: ' "Checking httpd: $url"
    if __website_check "httpd" "$url"; then
      printf '%s\n' "Success"
    else
      printf '%s\n' "Failed"
      exithttpdCode=$((exitProcCode++))
    fi
  fi
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check nginx hosts by default mine are http
for nginx_site in $get_nginx_domains; do
  if [ -n "$nginx_site" ]; then
    url="${set_nginx_proto:-https}://$nginx_site:$get_nginx_port"
    printf '%s: ' "Checking nginx: $url"
    if __website_check "nginx" "$url"; then
      printf '%s\n' "Success"
    else
      printf '%s\n' "Failed"
      exitnginxCode=$((exitProcCode++))
    fi
  fi
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
[ $exithttpdCode -eq 0 ] || __service_restart "httpd"
[ $exitnginxCode -eq 0 ] || __service_restart "nginx"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exitCode=$((exitProcCode + exithttpdCode + exitnginxCode))
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${exitCode:-0}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# ex: ts=2 sw=2 et filetype=sh
