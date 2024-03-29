#shellcheck disable=1091,2155

### bash, readline
stty -ixon werase undef
set -o ignoreeof
shopt -s histverify
shopt -s globstar
#shellcheck disable=2016
# bind -x '"\C-w":echo -n "${READLINE_LINE}" | xsel -ib'
bind -x '"\C-w":echo -n "${READLINE_LINE}" | wl-copy'
#shellcheck disable=2016
# bind -x '"\ew":pwd | sed "s%$HOME%\$HOME%" | tr -d '"'"'\n'"'"' |  xsel -ib'
bind -x '"\ew":pwd | sed "s%$HOME%\$HOME%" | tr -d '"'"'\n'"'"' |  wl-copy'
# bind -x '"\C-l\C-k":clear;clear'
#shellcheck disable=2016
bind '"\emfl":"(IFS=$''\\n''; for line in ; do echo $line; done)\e4\eb\e2\C-b"'

### history
source "$HOME/dotfiles/bash/history.bash"
history_config

### LS_COLORS and other colors
eval "$(dircolors -b)"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export JQ_COLORS='0;31:0;39:0;39:0;39:0;32:1;39:1;39'

### prompt
if "$HOME/dotfiles/bin/is_workstation"; then
  #'[bold;foreground-color;rgb;R;G;B]working directory[reset]$ '
  PS1='\[\e[01;38;2;159;151;216m\]\w\[\e[00m\]\$ '
else
  PS1='\[\e[01;38;2;159;151;216m\]${SHORT_HOSTNAME:-$"HOSTNAME"}:\w\[\e[00m\]\$ '
fi

### Less
#squeeze blank lines, long prompt, ANSI colors, quit if one screen, ignore-case, padding 10 lines
export LESS='-s -M -R -F -i -j10'
export SYSTEMD_LESS="-M -R -i"
BOLD=$(tput bold)
# RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
SGR0=$(tput sgr0)
export BOLD
export BLUE
export CYAN
export SGR0
export LESS_TERMCAP_md
export LESS_TERMCAP_us
export LESS_TERMCAP_ue
LESS_TERMCAP_md="${BOLD}${BLUE}" # begin bold
LESS_TERMCAP_us="$CYAN"          # begin underline
LESS_TERMCAP_ue="$SGR0"          # reset underline

### misc
export DEFAULT_IFS=\ $'\t'$'\n'
export EDITOR=vim
export PAGER=less
export MANPAGER="$PAGER"

### Aliases
alias clr='clear;clear'
###### systemctl
alias sc="sudo systemctl"
alias scn="sudo systemctl --no-pager"
alias scu="systemctl --user"
alias scun="systemctl --user --no-pager"

###### tmux
alias tmclr="rm .tmux/resurrect/*"
alias tso='tmux show -A'
alias tpv='tmux splitw -vdI &'
alias tph='tmux splitw -hdI &'

###### intalation from sources
alias makel='make PREFIX="$HOME/.local"'
alias cmig='mkdir Release && cd Release && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" .. && ccmake .'

###### other abbrevs
alias ls='ls --color=auto'
alias ll='ls -lAh'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias hd='hexdump'
alias hdh="hd -v -e '/1 \"%02X \"'"

alias r="source /usr/bin/ranger"
alias ffmpeg='ffmpeg -hide_banner'
alias cevt='cat -evt'

###### microscripts
alias sbrc='source "$HOME/.bashrc"'
alias ppath='echo -e "${PATH//:/\\n}"'
# alias tmpl='mktemp /tmp/XXXXXX.log | tr -d '"'"'\n'"'"' | xsel -ib'
alias tmpl='mktemp /tmp/XXXXXX.log | tr -d '"'"'\n'"'"' | wl-copy'
alias hcurl='curl -s -o /dev/null -D -'
alias cul='curl -L'

### Functions

function has_cmd {
  type -t "$1" > /dev/null
}

function bytes {
  local -r hd_args=(-v -e '/1 "%02X "')
  if [[ "$#" = "0" ]]; then
    #input on stdin
    hd "${hd_args[@]}"
  elif [[ -r "$1" ]]; then
    #filename passed as arg
    hd "${hd_args[@]}" "$1"
  else
    #value passed as arg
    echo -n "$1" | hd "${hd_args[@]}"
  fi
  echo
}

function cod {
  if [[ "$#" = "0" ]]; then
    # local a="$(xsel -ob)"
    local a="$(wl-paste)"
    printf "%s    %x" "$a" "'$a"
  else
    printf %x "'$1"
  fi
  echo
}

function cl {
  #shellcheck disable=2164
  cd "$@"
  ll
}

function mc {
  mkdir "$1"
  #shellcheck disable=2164
  cd "$1"
}

function __faketty {
  script -qfc "$(printf "%q " "$@")" /dev/null
}

#compare binary files
function bindiff {
  test -n "$1" || {
    echo "No input files" >&2
    return 1
  }
  test -n "$2" || {
    echo "No second input file" >&2
    return 1
  }
  diff -u --color=always <(xxd "$1") <(xxd "$2")
}

#add filed or directory to dotfiles
function dotfiles__mv {
  test -n "$1" || {
    echo "No file or directory name" >&2
    return 1
  }
  expandedArg="$(realpath "${1}")"
  if ! { [ -f "$expandedArg" ] || [ -d "$expandedArg" ]; }; then
    echo "No such file or directory" >&2
    return 1
  fi
  test -h "$1" && {
    echo "Symlink already created" >&2
    return 1
  }

  #shellcheck disable=2164
  pushd "$HOME" > /dev/null
  src=$(realpath --relative-to="$HOME" "$expandedArg")
  dirName=$(dirname "$src")
  baseName=$(basename "$src")

  if [ "$dirName" = "." ]; then
    dstDirName="$HOME/dotfiles"
  else
    dstDirName="$HOME/dotfiles/$dirName"
  fi

  mkdir -p "$dstDirName"
  mv "$src" "$dstDirName" && ln -s -T "$dstDirName/$baseName" "$src"
  #shellcheck disable=2164
  popd > /dev/null
}
complete -fd dotfiles__mv

function tmux__list_options {
  local range
  case $1 in
    -s)
      range='/^ {5}Available server options/,/^ {5}Available session options/p'
      ;;
    -e)
      range='/^ {5}Available session options/,/^ {5}Available window options/p'
      ;;
    -w)
      range='/^ {5}Available window options/,/^ {5}Available pane options/p'
      ;;
    -p)
      range='/^ {5}Available pane options/,/^[A-Z]/p'
      ;;
    *)
      range='/^ {5}Available server options/,/^[A-Z]/p'
      ;;
  esac
  man -P cat tmux | sed -En "$range" | grep -E --color=never '^ {5}[a-z]'
}

#stdin input expected
function conf__pick {
  if [[ ! "${1-}" =~ [[:alnum:]_-] ]]; then
    echo "At least one string key expected" >&2
    return 1
  fi

  # local delim=':'
  # awk --assign delim="$delim" 'BEGIN {
  awk 'BEGIN {
    for (i=1; i<ARGC; i++) {
      key=ARGV[i];
      key_order[i-1] = key
      map[key] = "";
    }
    ARGC=1;
  }
  #Not a comment
  !/^#/ {
    key = $1;
    if(key in map) {
      map[key] = $2;
    }
  }
  END {
    for(i in key_order) {
      print map[key_order[i]];
    }
  }' "$@"
  #| cut -c 2-
}

function conf__read {
  read -r -d '' "$@" < <(conf__pick "$@")
}

function lines {
  #from-to
  #point,around
  local range="$1"
  local sed_arg
  if [[ "$range" = *,* ]]; then
    local point="${range%,*}"
    local delta="${range#*,}"
    sed_arg="$((point - delta)),$((point + delta))p;$((point + delta + 1))q"
  elif [[ "$range" = *-* ]]; then
    local last="${range#*-}"
    sed_arg="${range/-/,}p;$((last + 1))q"
  else
    echo "lines range required"
    return 1
  fi
  local file="$2"
  if ! [[ -r "$file" ]]; then
    file="-"
  fi
  sed -n "$sed_arg" "$file"
}

function cmake_uninstall {
  xargs rm < install_manifest.txt
  xargs -L1 dirname < install_manifest.txt | xargs rmdir -p
}

function proc_env {
  local pid="$1"
  if ! ((pid > 0)); then
    echo "PID expected to be a positive number" >&2
    return 1
  fi

  tr '\0' '\n' < "/proc/$pid/environ"
}

function is_ubuntu {
  [[ "$(type -t lsb_release > /dev/null && lsb_release -i | cut -f 2-)" = "Ubuntu" ]]
}

function stopwatch {
  start=$(date +%s)
  while true; do
    time="$(($(date +%s) - start))"
    printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
  done
}

source "$HOME/dotfiles/bash/fancy_tools.bash"
"$HOME/dotfiles/bin/is_workstation" &&
  source "$HOME/dotfiles/bash/workstation.bash"
is_ubuntu &&
  source "$HOME/dotfiles/bash/ubuntu.bash"
