#shellcheck shell=bash
#shellcheck disable=1090
stty -ixon
set -o ignoreeof
shopt -s histverify

HISTSIZE=
HISTFILESIZE=
HISTCONTROL=ignoreboth:erasedups
#shellcheck disable=2140
HISTIGNORE="ll *":"cd *":"help *":"r":"exit"
HISTTIMEFORMAT="%F %T:%Z - "
#PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1='\[\033[01;34m\]\w\[\033[00m\]\$ '
export EDITOR=nvim
export PAGER=less
export LESS='-s -M -R -F -i -j10'
export MANPAGER="$PAGER"
export SYSTEMD_LESS="-M -R"
export BAT_PAGER="less -R"
export BAT_THEME="Visual Studio Dark+"
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden --exclude .git"
export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS="--reverse --height 55% --extended"
FZF_DEFAULT_OPTS+=" --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,f2:toggle-preview,f3:toggle-preview-wrap'"
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/.ripgreprc"

BOLD=$(tput bold)
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

#Aliases
#Sys-admin things first, application least
alias netdevs='inxi -Nxxx'
alias islogin='shopt -q login_shell && echo "yes" || echo "no"'
alias ppath='echo -e "${PATH//:/\\n}"'
alias upa='update-alternatives'
alias supa='sudo update-alternatives'
alias sc="systemctl"
alias scn="systemctl --no-pager"
alias scu="systemctl --user"
alias scun="systemctl --user --no-pager"
alias apt_lsppa="apt policy"

alias perl_info='perl -V'
alias perl_cpan='perl -MCPAN -Mlocal::lib -e shell'

alias sbrc='source "$HOME/.bashrc"'
alias vimi='vim -i .shada'
alias vimd="cd ~/dotfiles ; vim -i .shada bashrc.bash"

alias info='info --vi-keys'
alias hcurl='curl -s -o /dev/null -D -'
alias r=". ranger"
alias l="lf"
alias g="git"
alias torh="transmission-remote"
alias torls="transmission-remote -l"
alias torad="transmission-remote --add"
alias vpnup="nmcli con up vpn99"
alias vpndown="nmcli con down vpn99"

alias makel='make PREFIX="$HOME/.local"'
alias ghw="gh repo view --web"
alias tmzs='tmux__zero_session'
alias tmclr="rm .tmux/resurrect/*"
alias tso='tmux show -A'

#Not actually aliasses but usefull commands to remember
#dd is not like echo, it requires file
alias binecho="dd of=/dev/stdout count=1 status=none <<< "
alias fodiff="vim -d  <(fc-match JetBrainsMono --format '%{charset}' | tr ' ' '\n') <(fc-match 'JetBrainsMono NerdFont' --format '%{charset}' | tr ' ' '\n')"
alias notif="while inotifywait -q -q -e modify pg.lua ; do lua pg.lua; done"
alias color8='printf "\e[40;37m 0 \e[41;36m 1 \e[42;35m 2 \e[43;34m 3 \e[44;33m 4 \e[45;32m 5 \e[46;31m 6 \e[47;30m 7 \e[m\n"'

alias ghus="gh__search"
alias ghuc="gh__cache"

#Functions

function __faketty {
  script -qfc "$(printf "%q " "$@")" /dev/null
}

function watch_input_source {
  gsettings monitor org.gnome.desktop.input-sources mru-sources | cut -d\' -f4
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
#shellcheck disable=2164
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
  popd > /dev/null
}
complete -fd dotfiles__mv

#List package executables
function dpkg__lsexe {
  test -n "$1" || {
    echo "No package name" >&2
    return 1
  }
  dpkg -L "$1" | while read -r filePath; do test -x "$filePath" -a -f "$filePath" && echo "$filePath"; done
}

#List package files
function dpkg__lsf {
  test -n "$1" || {
    echo "No package name" >&2
    return 1
  }
  w="${2:-48}"
  p=""
  for f in $(dpkg -L "$1" | sort); do
    if [[ "$f" != "$p"* ]] && [[ "$p" != "/." ]]; then
      printf "%-${w}s    %s\n" "$p" "$(file -bi "$p")"
    fi
    p=$f
  done
  printf "%-${w}s   %s\n" "$p" "$(file -bi "$p")"
}

#Sort dependencies in package.json
function yarn__sortdeps {
  jq '.dependencies=(.dependencies | to_entries | sort | from_entries)' package.json | sponge package.json
}

#Check if string may be used as alias
function apt__search {
  test -n "$1" || {
    echo "No name to search" >&2
    return 1
  }
  apt search -n "\b$1\b"
}

#rg
function rg__pick {
  test -n "$1" || {
    echo "No input string" >&2
    return 1
  }

  #file:line:content
  #shellcheck disable=2016
  fzfSelected=$(rg --color always --line-number --no-heading --smart-case "$1" \
    | fzf --ansi --delimiter=':' --preview-window '+{2}/4' --preview \
      'bat {1} --wrap=character --color=always --highlight-line {2} --terminal-width ${FZF_PREVIEW_COLUMNS}')
  fzfResult="$?"

  if [ "$fzfResult" = "0" ] && [ -n "$fzfSelected" ]; then
    #shellcheck disable=2034
    IFS=: read -r file line content <<< "$fzfSelected"
    ((start = line - 8))
    test "$start" -ge 1 || start="1"
    vim "$file" +"$start"
  fi
}

#tmux
function tmux__zero_session {
  tmux \
    new-session -s 0 \; \
    new-window -d -n misc -t 0 \; \
    new-window -n dotfiles -t 2 -c ~/dotfiles \; send-keys vimd C-m \; select-window -t 1 \; \
    rename-window main
}

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

#font
function font__ls_chars {
  font_pattern=${1}
  test -n "$font_pattern" || {
    echo "font_pattern must be first argument" >&2
    return 1
  }

  rows_count=${2:-1}
  ((rows_count >= 1 && rows_count <= 10)) || {
    echo "rows_count must be [1;10]" >&2
    return 1
  }

  fc-match --format='%{family}\n' "$font_pattern"
  for range in $(fc-match --format='%{charset}\n' "$font_pattern"); do
    for n in $(seq "0x${range%-*}" "0x${range#*-}"); do
      printf "%x\n" "$n"
    done
  done | while read -r n_hex; do
    count=$((count + 1))
    char="\U$n_hex"
    printf "%5s %b" "$n_hex" "$char"
    if [ $((count % rows_count)) = 0 ]; then
      printf "\n"
    else
      printf "%4s" " "
    fi
  done
  printf "\n"
}

BASH_LIBS="gh/lib.bash tpa/lib.bash"
for f in $BASH_LIBS; do
  source "$HOME/dotfiles/bash/$f"
done

[ -f ~/dotfiles_priv/bashrc.bash ] && source ~/dotfiles_priv/bashrc.bash
