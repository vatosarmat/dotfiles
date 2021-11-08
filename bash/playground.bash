#shellcheck disable=2155
alias notif="while inotifywait -q -q -e modify pg.lua ; do lua pg.lua; done"
alias file_loop='find "$INFODIR" -type f | while read file ; do'
alias binecho="dd of=/dev/stdout count=1 status=none <<< "
alias reddit='xsel -ob | sed "s/^/    /" | xsel -ib'
alias luatp='lua -e '\''local p = require"pl.pretty"; p.dump(p.read(io.read()))'\'
alias perl_info='perl -V'
alias perl_cpan='perl -MCPAN -Mlocal::lib -e shell'
alias netdevs='inxi -Nxxx'
alias islogin='shopt -q login_shell && echo "yes" || echo "no"'
alias color8='printf "\e[40;37m 0 \e[41;36m 1 \e[42;35m 2 \e[43;34m 3 \e[44;33m 4 \e[45;32m 5 \e[46;31m 6 \e[47;30m 7 \e[m\n"'
alias fodiff="vim -d  <(fc-match JetBrainsMono --format '%{charset}' | tr ' ' '\n') <(fc-match 'JetBrainsMono NerdFont' --format '%{charset}' | tr ' ' '\n')"

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

function watch_input_source {
  gsettings monitor org.gnome.desktop.input-sources mru-sources | cut -d\' -f4
}

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
