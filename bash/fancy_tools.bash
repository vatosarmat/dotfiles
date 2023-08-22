#bat, fd, fzf, rg, z

if has_cmd bat; then
  export BAT_PAGER="less -R"
  export BAT_THEME="Visual Studio Dark+"
  alias batc='bat --color=always'
fi

if has_cmd fd; then
  alias fd='fd --hidden --no-ignore-parent --exclude .git'
fi

if has_cmd fzf; then
  if has_cmd fd; then
    # defaultCommand = `set -o pipefail; command find -L . -mindepth 1 \( -path '*/\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \) -prune -o -type f -print -o -type l -print 2> /dev/null | cut -b3-`
    export FZF_DEFAULT_COMMAND="find -type f"
  else
    export FZF_DEFAULT_COMMAND="fd --type file --follow --no-ignore --hidden"
  fi
  export FZF_DEFAULT_OPTS
  FZF_DEFAULT_OPTS="--reverse --height 55% --extended --bind='"
  FZF_DEFAULT_OPTS+="ctrl-d:half-page-down,ctrl-u:half-page-up,"
  FZF_DEFAULT_OPTS+="ctrl-alt-j:preview-down,ctrl-alt-k:preview-up,"
  FZF_DEFAULT_OPTS+="ctrl-alt-i:select-all,"
  FZF_DEFAULT_OPTS+="f2:toggle-preview,f3:toggle-preview-wrap,f4:toggle-sort,"
  # FZF_DEFAULT_OPTS+="alt-y:execute(echo -n '{}' | xsel -ib)'"
  FZF_DEFAULT_OPTS+="alt-y:execute(echo -n '{}' | wl-copy)'"
  export FZF_CTRL_R_OPTS
  FZF_CTRL_R_OPTS="--bind='alt-r:execute(source $HOME/dotfiles/bash/history.bash && history_config && history_read && history -d {1} && history -w)+reload(source $HOME/dotfiles/bash/history.bash && history_config && history_read  && __fzf_history_source__ )'"
  source "$HOME/dotfiles/bash/fzf/key-bindings.bash"
fi

if has_cmd rg; then
  export RIPGREP_CONFIG_PATH="$HOME/dotfiles/.ripgreprc"
fi

if has_cmd z; then
  function zl {
    z "$@"
    ll
  }
fi
