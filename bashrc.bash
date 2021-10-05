#shellcheck shell=bash
#shellcheck disable=1090,1091,2155
stty -ixon werase undef
set -o ignoreeof
shopt -s histverify
shopt -s globstar
#shellcheck disable=2016
bind -x '"\C-w":echo -n "${READLINE_LINE}" | xsel -ib'
#shellcheck disable=2016
bind -x '"\ew":pwd | sed "s%$HOME%\$HOME%" | tr -d '"'"'\n'"'"' |  xsel -ib'

source "$HOME/.history.bash"
history_config

#LS_COLORS
eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

#prompt
# PS1='\[\033[01;38;2;162;151;216m\]\w\[\033[00m\]\$ '
PS1='\[\033[01;38;2;159;151;216m\]\w\[\033[00m\]\$ '
# PS1='\[\033[01;38;2;122;122;218m\]\w\[\033[00m\]\$ '

export EDITOR=nvim
export PAGER=less
#squeeze blank lines, long prompt, ANSI colors, quit if one screen, ignore-case, padding 10 lines
export LESS='-s -M -R -F -i -j10'
export MANPAGER="$PAGER"
export SYSTEMD_LESS="-M -R"
export BAT_PAGER="less -R"
export BAT_THEME="Visual Studio Dark+"
export FZF_DEFAULT_COMMAND="fd --type file --follow --no-ignore --hidden"
export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS="--reverse --height 55% --extended --bind='"
FZF_DEFAULT_OPTS+="ctrl-d:half-page-down,ctrl-u:half-page-up,"
FZF_DEFAULT_OPTS+="ctrl-alt-j:preview-down,ctrl-alt-k:preview-up,"
FZF_DEFAULT_OPTS+="ctrl-alt-i:select-all,"
FZF_DEFAULT_OPTS+="f2:toggle-preview,f3:toggle-preview-wrap,"
FZF_DEFAULT_OPTS+="alt-y:execute(echo -n '{}' | xsel -ib)'"
export FZF_CTRL_R_OPTS
FZF_CTRL_R_OPTS="--bind='alt-r:execute(source $HOME/.history.bash && history_config && history_read && history -d {1} && history -w)+reload(source $HOME/.history.bash && history_config && history_read && source "$HOME/.fzf.bash" && __fzf_history_source__ )'"
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/.ripgreprc"

export DEFAULT_IFS=\ $'\t'$'\n'
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
alias vim_update="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"

alias hcurl='curl -s -o /dev/null -D -'
alias r=". ranger"
alias l="lf"
alias g="git"
alias torh="transmission-remote"
alias torls="transmission-remote -l"
alias torad="transmission-remote --add"
alias vpnup="nmcli con up vpn99"
alias vpndown="nmcli con down vpn99"
alias ffmpeg='ffmpeg -hide_banner'
alias hd='hexdump'
alias hdh="hd -v -e '/1 \"%02X \"'"
alias ll='ls -lAh'

alias makel='make PREFIX="$HOME/.local"'
alias ghw="gh repo view --web"
alias tmzs='tmux__zero_session'
alias tmclr="rm .tmux/resurrect/*"
alias tso='tmux show -A'
alias tpv='tmux splitw -vdI &'
alias tph='tmux splitw -hdI &'
alias batc='bat --color=always'
alias luatp='lua -e '\''local p = require"pl.pretty"; p.dump(p.read(io.read()))'\'
alias cmg='cmake -BDebug -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=YES .'
alias cmb='cmake --build Debug'
alias cmr='cmake --build Debug && ./Debug/main'
alias cmig='mkdir Release && cd Release && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" .. && ccmake .'
alias reddit='xsel -ob | sed "s/^/    /" | xsel -ib'

#Not actually aliasses but usefull commands to remember
alias cevt='cat -evt'
#dd is not like echo, it requires file
alias binecho="dd of=/dev/stdout count=1 status=none <<< "
alias fodiff="vim -d  <(fc-match JetBrainsMono --format '%{charset}' | tr ' ' '\n') <(fc-match 'JetBrainsMono NerdFont' --format '%{charset}' | tr ' ' '\n')"
alias notif="while inotifywait -q -q -e modify pg.lua ; do lua pg.lua; done"
alias color8='printf "\e[40;37m 0 \e[41;36m 1 \e[42;35m 2 \e[43;34m 3 \e[44;33m 4 \e[45;32m 5 \e[46;31m 6 \e[47;30m 7 \e[m\n"'
alias file_loop='find "$INFODIR" -type f | while read file ; do'

alias ghus="gh__search"
alias ghuc="gh__cache"
alias x='xsel -ob'

source z

#Functions

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

function cl {
  #shellcheck disable=2164
  cd "$@"
  ll
}

function zl {
  z "$@"
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

function apt__lsppa {
  find /etc/apt/ -name \*.list | while IFS=$'\n' read -r file; do
    # echo "$RED$file$SGR0"
    # Extract from between 'dev ' and 'start_of_comment or end of line'
    grep --color=never -Po "(?<=^deb\s).*?(?=#|$)" "$file" | while read -r entry; do
      host=$(echo "$entry" | cut -d/ -f3)
      user=$(echo "$entry" | cut -d/ -f4)
      ppa=$(echo "$entry" | cut -d/ -f5)
      # printf "%-32s%-48s%-48s\n" "$host" "$ppa" "$user"
      if [[ "ppa.launchpad.net" = "$host" ]]; then
        echo "ppa:$user/$ppa"
      else
        echo "$entry"
      fi
    done
  done
}

#rg
function rg__pick {
  test -n "$1" || {
    echo "No input string" >&2
    return 1
  }

  #file:line:content
  #shellcheck disable=2016
  fzfSelected=$(rg --color always --line-number --no-heading --smart-case "$1" |
    fzf --ansi --delimiter=':' --preview-window '+{2}/4' --preview \
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

function tmux__zs {
  tmux \
    new-session -s 0 \; \
    new-window -n dotfiles -t 0 -c ~/dotfiles \; send-keys vimd C-m \; select-window -t 1 \; \
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

#neovim
function v {
  local project_markers="README README.md README.rst package.json CMakeLists.txt Cargo.toml"
  for f in $project_markers; do
    if [[ -f "$f" ]]; then
      nvim -i '.shada' "$f"
      return
    fi
  done
  echo "No project marker found: $project_markers"
}

function lsp_log {
  local cmd=''
  # declare -ar pass=()
  declare -ar block=('"textDocument/publishDiagnostics"' '"$/progress"' '"$/status/report"')
  if [[ "$1" == '-f' ]]; then
    cmd="tail -f"
  else
    cmd="cat"
  fi
  declare -a block_args=()
  for b in "${block[@]}"; do
    block_args+=('-e' "$b")
  done
  $cmd "$HOME/.cache/nvim/lsp.log" |
    grep --line-buffered -Fv "${block_args[@]}" |
    sed --unbuffered -E -f "$HOME/.config/nvim/misc/lsp_log.sed" |
    bat --color=always --pager=never --style=plain -l lua
  # grep -F -e '"rpc.send.payload"' -e '"decoded"'
}

function cmake_uninstall {
  #shellcheck disable=2002
  cat install_manifest.txt | xargs rm
  #shellcheck disable=2002
  cat install_manifest.txt | xargs -L1 dirname | xargs rmdir -p
}

function pdf_extract_range {
  # better method
  # pdftk infile.pdf cat first-last output outfile.pdf
  local OPTS=$(getopt --option f:l: --long first:last: -n "${FUNCNAME[0]}" -- "$@")
  eval set -- "$OPTS"

  while (($# > 0)); do
    case $1 in
      -f | --first)
        local -i first=$2
        shift 2
        ;;
      -l | --last)
        local -i last=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "Unexpected argument $1"
        exit 1
        ;;
    esac
  done
  #We've shifted to the parameter which is expected to be a pdf file name
  local source_pdf="$(realpath "$1")"
  local source_pdf_basename="$(basename --suffix='.pdf' "$source_pdf")"
  local result_pdf="${source_pdf%/*}/${source_pdf_basename}_${first}-${last}.pdf"
  # echo "source_pdf: $source_pdf"
  # echo "result_pdf: $result_pdf"

  if ! { [[ "$first" =~ [[:digit:]]+ ]] && ((first > 0)); }; then
    echo "-f $first is not a number >0!" >&2
    return 1
  fi
  if ! { [[ "$last" =~ [[:digit:]]+ ]] && ((last >= first)); }; then
    echo "-l $last is not a number >= $first!" >&2
    return 1
  fi
  if ! [[ "$(file --dereference --brief --mime-type "$source_pdf")" == "application/pdf" ]]; then
    echo "$source_pdf not a PDF file!" >&2
    return 1
  fi

  local temp_dir="$(mktemp -d)"
  local page_pattern="$temp_dir/$(basename --suffix='.pdf' "$source_pdf")_page_%d.pdf"
  local page_num_pos=${#page_pattern}
  ((page_num_pos -= 5))

  if pdfseparate -f "$first" -l "$last" "$source_pdf" "$page_pattern"; then
    #shellcheck disable=2046
    #shellcheck disable=2012
    pdfunite $(echo "$temp_dir"/* | tr ' ' '\n' | sort --numeric-sort --key="1.${page_num_pos}" | tr '\n' ' ') "$result_pdf"
  fi
  rm -rf "$temp_dir"
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

#set lu_path and lua_cpath according to selected dir
#replace old one
#none
function isl {
  local -r versions_prefix="$HOME/.lua/versions"
  local dir=""
  #shellcheck disable=2012
  if dir="$(
    {
      ls "$versions_prefix"
      echo "none"
    } | fzf
  )"; then
    #remove prev
    local new_path=":$PATH"
    new_path="${new_path/":$versions_prefix/"+([!\/])"/bin"/}"
    new_path="${new_path#:}"

    if [[ "$dir" = "none" ]]; then
      export PATH="$new_path"
      unset LUA_PATH
      unset LUA_CPATH
    else
      #append new
      export PATH="$versions_prefix/$dir/bin:$new_path"

      local lua_path="" lua_cpath=""
      IFS=\;
      for path in $(luarocks path --lr-path); do
        if [[ "$path" = "$versions_prefix/$dir"/* ]]; then
          lua_path="$lua_path;$path"
        fi
      done
      for path in $(luarocks path --lr-cpath); do
        if [[ "$path" = "$versions_prefix/$dir"/* ]]; then
          lua_cpath="$lua_cpath;$path"
        fi
      done
      IFS="$DEFAULT_IFS"
      export LUA_PATH="${lua_path#;}"
      export LUA_CPATH="${lua_cpath#;}"
    fi
  fi
}

function path_remove {
  local dirs=""
  if dirs="$(fzf --multi <<< "${PATH//:/$'\n'}")"; then
    local path=":$PATH"
    while IFS= read -r line; do
      path="${path/":$line"/}"
    done <<< "$dirs"
    export PATH="${path#:}"
  fi
}

function node__fd_modules_with_submodules {
  fd -p -g "$PWD/*/node_modules/*" -x dirname '{//}' | sort -u
}

function node__fd_symlinks {
  fd -t l -H
}

function node__fd_multihard {
  find . -links +2 -not -type d
}

function node__fd_count_dups {
  if [[ "$1" = [12] ]]; then
    local sort_key="${1}"
  else
    local sort_key="1"
  fi
  fd -t f '^package.json$' -x jq -rj 'if .name and .version  then .name+":"+.version+"\n" else empty end' {} | sort | uniq -c | grep -v '^\s\+1\s' | sort --key="${sort_key}"
}

function node__fd_dup_users {
  #shellcheck disable=2016
  fd --min-depth 4 -t f '^package.json$' -x sh -c 'jq -erj '"'"'if .name then .name+":"+.version else empty end'"'"' {} && dirname "  $(dirname {//})"' | sort
}

BASH_LIBS="gh/lib.bash tpa/lib.bash"
for f in $BASH_LIBS; do
  source "$HOME/dotfiles/bash/$f"
done

[ -f ~/dotfiles_priv/bashrc.bash ] && source ~/dotfiles_priv/bashrc.bash
