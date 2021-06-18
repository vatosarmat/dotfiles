#!/bin/bash

function _tmux__table_bind {
  #1 - table
  #2 - key
  #3 - command
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "3 arguments required" >&2
    return 1
  fi
  table="$1"
  key="$2"
  cmd="$3"' ; switch-client -T '"$1"

  tmux bind-key -T "$table" "$key" "$cmd"
}

function _tmux__table_switch_bind {
  #1 - table
  #2 - key
  #3 - command
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "3 arguments required" >&2
    return 1
  fi
  table="$1"
  key="$2"
  cmd="$3"' ; switch-client -T '"$1"

  tmux bind-key "$key" "$cmd ; refresh-client" \; bind-key -T "$table" "$key" "$cmd"
}

function bind_command {
  _tmux__table_bind 'COMMAND' "$1" "$2"
}

function bind_switch_command {
  _tmux__table_switch_bind 'COMMAND' "$1" "$2"
}

tmux bind-key -T 'COMMAND' 'Any' 'switch-client'

#Resize
bind_switch_command 'Left' 'resize-pane -L 5'
bind_switch_command 'Down' 'resize-pane -D 5'
bind_switch_command 'Up' 'resize-pane -U 5'
bind_switch_command 'Right' 'resize-pane -R 5'
bind_switch_command 'H' 'resize-pane -L'
bind_switch_command 'J' 'resize-pane -D'
bind_switch_command 'K' 'resize-pane -U'
bind_switch_command 'L' 'resize-pane -R'
bind_command 'Z' 'resize-pane -Z'
bind_command 'E' 'select-layout -E'

#Select
bind_switch_command 'h' 'select-pane -L'
bind_switch_command 'j' 'select-pane -D'
bind_switch_command 'k' 'select-pane -U'
bind_switch_command 'l' 'select-pane -R'
bind_switch_command 'n' 'next-window'
bind_switch_command 'p' 'previous-window'

#Split/unsplit/move panes
bind_switch_command 'c' 'new-window'
bind_switch_command 'v' 'split-window -h -c "#{pane_current_path}" -l 45%'
bind_switch_command 's' 'split-window -v -c "#{pane_current_path}"'
# bind_command 'q' 'if-shell -F "#{?#{==:#{pane_current_command},bash},1,}" dispaly display'
bind_command 'x' 'display-panes "swap-pane -t %%"'

bind_command 'q' 'if-shell -F "#{?#{==:#{pane_current_command},bash},1,}" { kill-pane } { confirm-before -p "kill-pane #P? (y/n)" kill-pane }'
#Miscellaneous
bind_command ':' 'command-prompt'
