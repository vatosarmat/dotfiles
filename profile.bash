PATH="$HOME/dotfiles/bin:$PATH"
PATH="$(echo "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')"
