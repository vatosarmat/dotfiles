#shellcheck shell=bash
#shellcheck disable=1091
[ -f ~/dotfiles_priv/profile.bash ] && source "$HOME/dotfiles_priv/profile.bash"
PATH="$(echo "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')"
