#!/bin/bash

function _tmux__table_bind {
  local table="prefix" switch_to="root"
  local OPTIND OPTARG OPTERR opt
  while getopts "T:s:" opt; do
    case $opt in
      [T])
        local table="$OPTARG"
        ;;
      [s])
        local switch_to="$OPTARG"
        ;;
      *) ;;
    esac
  done
  shift $((OPTIND - 1))

  local key="${1:?"Key is required"}"
  local cmd="${2:?"Cmd is required"}"

  if [[ "$switch_to" != "root" ]]; then
    cmd="$cmd ; switch-client -T $switch_to"
  fi

  if [[ "$switch_to" != "root" && "$table" != "$switch_to" ]]; then
    cmd="$cmd ; refresh-client"
  fi

  tmux bind-key -T "$table" "$key" "$cmd"
}

function bind_command {
  _tmux__table_bind -T 'COMMAND' -s 'COMMAND' "$1" "$2"
}

function bind_switching_command {
  _tmux__table_bind -s 'COMMAND' "$1" "$2"
  _tmux__table_bind -T 'COMMAND' -s 'COMMAND' "$1" "$2"
}

tmux bind-key -T 'COMMAND' 'Any' 'switch-client'

bind_command ',' 'command-prompt -I "#W" "rename-window '"'"'%%'"'"'"'

#Resize
bind_switching_command 'Left' 'resize-pane -L 5'
bind_switching_command 'Down' 'resize-pane -D 5'
bind_switching_command 'Up' 'resize-pane -U 5'
bind_switching_command 'Right' 'resize-pane -R 5'
bind_switching_command 'H' 'resize-pane -L'
bind_switching_command 'J' 'resize-pane -D'
bind_switching_command 'K' 'resize-pane -U'
bind_switching_command 'L' 'resize-pane -R'
bind_command 'z' 'resize-pane -Z'
bind_command 'E' 'select-layout -E'

#Select
bind_switching_command 'h' 'select-pane -L'
bind_switching_command 'j' 'select-pane -D'
bind_switching_command 'k' 'select-pane -U'
bind_switching_command 'l' 'select-pane -R'
bind_switching_command 'n' 'next-window'
bind_switching_command 'p' 'previous-window'

#Split/unsplit/move panes
bind_switching_command 'c' 'new-window'
bind_switching_command 'v' 'split-window -h -c "#{pane_current_path}" -l 45%'
bind_switching_command 's' 'split-window -v -c "#{pane_current_path}"'
# bind_command 'q' 'if-shell -F "#{?#{==:#{pane_current_command},bash},1,}" dispaly display'
bind_command 'x' 'display-panes "swap-pane -t %%"'

bind_command 'C-h' 'display-panes -d 10000 "move-pane -bh -t %%"'
bind_command 'C-j' 'display-panes -d 10000 "move-pane -v -t %%"'
bind_command 'C-k' 'display-panes -d 10000 "move-pane -bv -t %%"'
bind_command 'C-l' 'display-panes -d 10000 "move-pane -h -t %%"'
bind_command 'M-C-h' 'display-panes -d 10000 "move-pane -fbh -t %%"'
bind_command 'M-C-j' 'display-panes -d 10000 "move-pane -fv -t %%"'
bind_command 'M-C-k' 'display-panes -d 10000 "move-pane -fbv -t %%"'
bind_command 'M-C-l' 'display-panes -d 10000 "move-pane -fh -t %%"'
bind_command 'u' 'select-layout -o'

bind_command 'q' 'if-shell -F "#{?#{==:#{pane_current_command},bash},1,}" { kill-pane } { confirm-before -p "kill-pane #P? (y/n)" kill-pane }'
#Miscellaneous
bind_command ':' 'command-prompt'
