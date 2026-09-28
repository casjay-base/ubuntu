#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202305090019-git
# @@Author           :  Jason Hempstead
# @@Contact          :  git-admin@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  root_clean.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Sep 06, 2022 15:18 EDT
# @@File             :  root_clean.sh
# @@Description      :  Remove old log files
# @@Changelog        :  newScript
# @@TODO             :  Refactor code
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  bash/system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VERSION="202305090019-git"
# etc/logrotate.d/btmp and etc/logrotate.d/wtmp are now shipped as
# intentionally-empty overrides (see those files) so the deploy sync
# neutralizes the logrotate package's own stanzas at those paths - no
# runtime cleanup needed here any more
[ -z "$(builtin type -P clean-system 2>/dev/null)" ] || clean-system --raw
