
function tmux__pane_has_process {
  #1 - process name
  test -n "$1" || { echo "No process name" >&2; return 1; }
  pattern='^[^TXZ ]+ +'"${1}"'$'
  ps -o state= -o comm= -t "$(tmux display-message -p '#{pane_tty}')" | grep -iqE "$pattern"
}

function tmux__ranger_to_vim {
  tmux__pane_has_process 'ranger' || return 0
  tmux send-keys 'y'
  sleep .01
  tmux send-keys 'p'
  tmux select-pane -L
  tmux__pane_has_process 'n?vim' || return 0
  tmux send-keys ':tabe ' C-r '*' C-m
}
