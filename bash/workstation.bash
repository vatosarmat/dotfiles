#!/bin/bash
#shellcheck disable=1091,2155

function tmux__zs {
  tmux \
    new-session -s 0 -n d \; send-keys vimd C-j \; new-window -n m
}

source "$HOME/dotfiles/bash/dev/utils.bash"
source "$HOME/dotfiles/bash/gh/lib.bash"
source "$HOME/dotfiles/bash/tpa/lib.bash"
source "$HOME/dotfiles/bash/playground.bash"
source "$HOME/dotfiles/bash/dev/nvim.bash"
source "$HOME/dotfiles/bash/dev/node.bash"
source "$HOME/dotfiles/bash/dev/cpp.bash"
source "$HOME/dotfiles/bash/dev/php.bash"
source "$HOME/dotfiles/bash/dev/network.bash"
source "$HOME/dotfiles/bash/dev/db.bash"
source "$HOME/dotfiles/bash/dev/docker.bash"
source "$HOME/dotfiles/bash/dev/telegram.bash"
source "$HOME/dotfiles/bash/dev/git.bash"

function __dotfiles__project_local {
  local -r project_dotfiles="$NVIM_EXTRA/lua/project_local/$(realpath --relative-to="$HOME" "$PWD")"

  # if project directory exists
  if [[ ! -d "$project_dotfiles" ]]; then
    return
  fi

  # should be same as .git path
  export PROJECT_PATH="$PWD"

  # setup env
  source "$project_dotfiles/.bashrc" 2> /dev/null

  # add binaries to PATH
  for bin_dir in "$project_dotfiles/.bin" "$PROJECT_PATH/node_modules/.bin"; do
    if [[ -d "$bin_dir" ]]; then
      PATH="$bin_dir:$PATH"
    fi
  done
  PATH="$(echo "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')"
}

__dotfiles__project_local
