[ -f ~/dotfiles_priv/profile.bash ] && source ~/dotfiles_priv/profile.bash
PATH="$(echo $PATH | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')"
