# $HOME/.bashrc: executed by bash(1) for non-login shells.
PS1='[\u@\h \W]\$ '
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# If not running interactively, don't do anything
case $- in *i*) ;; *) return ;; esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -z "$BASHRCSOURCED" ] && [ -f "/etc/bashrc" ]; then
  . /etc/bashrc && export BASHRCSOURCED="Y"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export path
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# append to the history file, don't overwrite it
shopt -s histappend
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# If set, the pattern "**" used in a pathname expansion context will match all files and zero or more directories and subdirectories.
#shopt -s globstar
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# make less more friendly for non-text input files, see lesspipe(1)
[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL=/bin/sh lesspipe)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Force colors
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  color_prompt=yes
  RESET="$(tput sgr0 2>/dev/null)"
  BLACK="$(printf '%b' "\033[0;30m")"
  RED="$(printf '%b' "\033[1;31m")"
  GREEN="$(printf '%b' "\033[0;32m")"
  YELLOW="$(printf '%b' "\033[0;33m")"
  BLUE="$(printf '%b' "\033[0;34m")"
  PURPLE="$(printf '%b' "\033[0;35m")"
  CYAN="$(printf '%b' "\033[0;36m")"
  WHITE="$(printf '%b' "\033[0;37m")"
  ORANGE="$(printf '%b' "\033[0;33m")"
  LIGHTRED="$(printf '%b' '\033[1;31m')"
  BG_GREEN="\[$(tput setab 2 2>/dev/null)\]"
  BG_RED="\[$(tput setab 9 2>/dev/null)\]"
else
  unset RESET
  unset BLACK
  unset RED
  unset GREEN
  unset YELLOW
  unset BLUE
  unset PURPLE
  unset CYAN
  unset WHITE
  unset ORANGE
  unset LIGHTRED
  unset BG_GREEN
  unset BG_RED
  color_prompt=no
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set 'man' colors
if [ "$color_prompt" = "yes" ]; then
  man() {
    env \
      LESS_TERMCAP_mb=$'\e[01;31m' \
      LESS_TERMCAP_md=$'\e[01;31m' \
      LESS_TERMCAP_me=$'\e[0m' \
      LESS_TERMCAP_se=$'\e[0m' \
      LESS_TERMCAP_so=$'\e[01;44;33m' \
      LESS_TERMCAP_ue=$'\e[0m' \
      LESS_TERMCAP_us=$'\e[01;32m' \
      command man "$@"
  }
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# git functions
__git_pull() { for d in "$@"; do printf '%-40s' "Pulling $d" && git -C "$d" pull; done; }
__git_push() { for d in "$@"; do printf '%-40s' "Pulling $d" && git -C "$d" push; done; }
__git_clone() {
  local dir="${2:-$HOME/Projects/$(echo "${1//*:\/\//}" | cut -d'.' -f1)/$(echo "${1//*:\/\//}" | awk -F'/' '{print $(NF-1)"/"$NF}')}"
  [ -d "$dir/.git" ] && printf '%-40s' "Pulling $dir" && git -C "$dir" pull || printf '%-40s' "cloning $1" && git clone "$1" "$dir" -q
  return $?
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# enable color support of ls and also add handy aliases
if [ -x "/usr/bin/dircolors" ]; then
  test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='grep -F --color=auto'
  alias egrep='grep -E --color=auto'
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# some more ls aliases
alias q='exit'
alias c='clear'
alias l='ls -CF'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -laA'
alias em='emacs -nw'
alias dd='dd status=progress'
alias cd..='cd ..'
alias pdw='pwd'
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# sudo aliases
alias _='sudo -n true && sudo'
alias _i='sudo -n true && sudo -i'
alias systemctl='sudo -n true && sudo \systemctl '
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
alias df='df -h'
alias free="free -mt"
alias wget="wget -c"
alias curl="curl -q -LSsf"
alias listusers="cut -d: -f1 /etc/passwd | sort -u"
alias listgroups="cut -d: -f1 /etc/group | sort -u"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Alias definitions.
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f "/usr/share/bash-completion/bash_completion" ]; then
    . "/usr/share/bash-completion/bash_completion"
  elif [ -f "/etc/bash_completion" ]; then
    . "/etc/bash_completion"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check if local bin folder exists and prepend it to $PATH if so
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=2124,2217
# Set the window title
set_custom_win_title() {
  local cmd_bin="" cmd_args="" window_format="" cmd="" BASEPWD=""
  cmd_bin="$(basename -- "$1")" && shift 1
  cmd_args="${@:1:20}" && shift $#
  cmd="| $cmd_bin $cmd_args"
  BASEPWD="$(realpath "$PWD")"
  window_format="$USER@$HOSTNAME"
  if [ -z "$cmd_bin" ] || echo "$cmd_bin $cmd_args" | grep -Eqi "starship|$SHELL|tmux|screen"; then
    cmd="| $(basename -- "$SHELL")"
  fi
  if [ "$PWD" = "$HOME" ]; then
    echo -ne "\033]0; 🏠 $window_format:~ $cmd\a" </dev/null
  else
    echo -ne "\033]0; 🏛️ $window_format:${BASEPWD//$HOME/~} $cmd\a" </dev/null
  fi
  trap 'set_custom_win_title ${BASH_COMMAND}' DEBUG
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# set prompt
if [ -n "$(type -P starship)" ]; then
  unset BASH_PROMPT PROMPT_COMMAND PS1 PS2 PS3 PS4
  export starship_precmd_user_func="history -r;set_custom_win_title"
  eval -- "$(starship init bash --print-full-init)"
  export PROMPT_COMMAND="${STARSHIP_PROMPT_COMMAND:-starship_precmd};history -a"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -r "$HOME/.config/bash/bash.local" ] && . "$HOME/.config/bash/bash.local"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# unset variables
unset color_prompt force_color_prompt
