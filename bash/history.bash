#This is for history access from scripts
function history_config {
  HISTSIZE=
  HISTFILESIZE=
  HISTCONTROL=ignoreboth:erasedups
  #shellcheck disable=2140
  HISTIGNORE="ll":"cd *":"help *":"r":"exit":"history *":"fc *":"clr"
  HISTTIMEFORMAT="%F %T:%Z - "
}

function history_read {
  HISTFILE="$HOME/.bash_history"
  set -o history
}
