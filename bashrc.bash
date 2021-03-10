stty -ixon
set -o ignoreeof

shopt -s histverify
HISTSIZE=
HISTFILESIZE=
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls *":"cd *":"man *":"help *"
HISTTIMEFORMAT="%F %T:%Z - "
#PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1='\[\033[01;34m\]\w\[\033[00m\]\$ '
export EDITOR=nvim
export PAGER=less
export LESS='-s -M -R -I -j10 +Gg'
export MANPAGER="$PAGER"
export SYSTEMD_LESS="-M -R"
export BAT_PAGER=""
export FZF_DEFAULT_COMMAND="command find -L . -mindepth 1 \( -path '*/\.git' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \) -prune -o -type f -print -o -type l -print 2> /dev/null | cut -b3-"
export FZF_DEFAULT_OPTS="--reverse --height 55% --extended --bind alt-f:half-page-down,alt-b:half-page-up"
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/.ripgreprc"

#export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
#export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
#export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
#export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
#export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;36m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

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

alias perl_info='perl -V'
alias perl_cpan='perl -MCPAN -Mlocal::lib -e shell'

alias ebrc='$EDITOR "$HOME/.bashrc_custom"'
alias sbrc='source "$HOME/.bashrc_custom"'
alias ebrchs='$EDITOR "$HOME/.bashrc_host-specific"'
alias sbrchs='source "$HOME/.bashrc_host-specific"'
alias ebp='$EDITOR "$HOME/.profile_custom"'
alias sbp='source "$HOME/.profile_custom"'
alias etmc='$EDITOR "$HOME/.tmux.conf"'
alias ealc='$EDITOR "$HOME/.config/alacritty/alacritty.yml"'

alias info='info --vi-keys'
alias hcurl='curl -s -o /dev/null -D -'
alias hgrep='history | grep'
alias r=". ranger"
alias l="lf"
alias tcls="rm .tmux/resurrect/*"
alias torh="transmission-remote"
alias torls="transmission-remote -l"
alias torad="transmission-remote --add"
alias vpnup="nmcli con up vpn99"
alias vpndown="nmcli con down vpn99"

alias gisi="git status --ignored"
alias lbat='BAT_PAGER="less ${LESS}" bat'
alias makel='make PREFIX="$HOME/.local"'
alias ghw="gh repo view --web"
alias fodiff="vim -d  <(fc-match JetBrainsMono --format '%{charset}' | tr ' ' '\n') <(fc-match 'JetBrainsMono NerdFont' --format '%{charset}' | tr ' ' '\n')"

alias ghus="gh__search"
alias ghuc="gh__cache"


#escapes

t_bold=$(tput bold)
t_norm=$(tput sgr0)

#Functions

function __faketty {
    script -qfc "$(printf "%q " "$@")" /dev/null
}

#compare binary files
function bindiff {
  test -n "$1" || { echo "No input files" >&2; return 1; }
  test -n "$2" || { echo "No second input file" >&2; return 1; }
  diff -u --color=always <(xxd "$1") <(xxd "$2")
}

#add filed or directory to dotfiles
function dotfiles__mv {
  test -n "$1" || { echo "No file or directory name" >&2; return 1; }
  expandedArg="$(realpath "${1}")"
  if ! { [ -f "$expandedArg" ] || [ -d "$expandedArg" ]; }; then
    echo "No such file or directory" >&2;
    return 1;
  fi
  test -h "$1" && { echo "Symlink already created" >&2; return 1; }

  pushd "$HOME" >/dev/null
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
  popd >/dev/null
}
complete -fd dotfiles__mv

#List package executables
function dpkg__lsexe {
  test -n "$1" || { echo "No package name" >&2; return 1; }
  dpkg -L $1 | while read filePath; do test -x "$filePath" -a -f "$filePath" && echo "$filePath"; done
}

#Sort dependencies in package.json
function yarn__sortdeps {
  jq '.dependencies=(.dependencies | to_entries | sort | from_entries)' package.json | sponge package.json
}

#Check if string may be used as alias
function apt__search {
  test -n "$1" || { echo "No name to search" >&2; return 1; }
  apt search -n "\b$1\b"
}

#rg
function __rg__pick_preview {
  #$1 is FILE:LINE  CONTENT
  #$FZF_PREVIEW_LINES
  IFS=: read -r file line rest <<< "$1"
  let start=$line-$FZF_PREVIEW_LINES/4
  test $start -ge 1 || start="1"
  #let end=$line+10
  bat "$file" -f -H $line -r $start: --terminal-width $FZF_PREVIEW_COLUMNS
}
export -f __rg__pick_preview

function rg__pick {
  test -n "$1" || { echo "No input string" >&2; return 1; }

  fzfSelected=$(rg --color always -in --no-heading "$1" | fzf --ansi --preview "__rg__pick_preview {}")
  fzfResult="$?"

  if [ "$fzfResult" = "0" -a -n "$fzfSelected" ]; then
    subl "${fzfSelected%:*}"
  fi
}

#font
function font__ls_chars {
  font_pattern=${1}
  test -n "$font_pattern" || { echo "font_pattern must be first argument" >&2; return 1; }

  rows_count=${2:-1}
  (( rows_count >= 1 && rows_count <= 10 )) || { echo "rows_count must be [1;10]" >&2; return 1; }

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
