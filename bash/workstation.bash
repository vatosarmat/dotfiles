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

source "$NVIM_EXTRA/lua/project_local/$(realpath --relative-to="$HOME" "$PWD")/.bashrc" 2> /dev/null
