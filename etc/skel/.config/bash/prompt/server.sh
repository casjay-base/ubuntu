# Set ps2 and ps4
PS2="⚡ "
PS4="$(tput cr 2>/dev/null && tput cuf 6 2>/dev/null && printf "${GREEN}+%s ($LINENO) +" " $RESET")"

# set title
__ps1_set_title() { echo -ne "${USER}@${HOSTNAME}:${PWD//$HOME/\~}"; }

# prompt prev exit status
__ps1_promp_command() { local retVal=$? && history -a && history -r && return $retVal; }

# set default prompt
PROMPT_COMMAND="__ps1_set_title;__ps1_promp_command"
