#shellcheck shell=bash
__TPA_CACHE_FILE="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.cache"
__TPA_BIN_DIR="$HOME/.local/bin"
__TPA_MAN_DIR="$HOME/.local/share/man"

function __tpa__validate_exe {
  # name, in Dist
  # $1 should be an existing exe file
  [[ -s "$1" ]] || {
    echo "Exe file name required" >&2
    return 1
  }
  [[ "$(realpath "$1")" = "$HOME/Dist/"* ]] || {
    echo "Exe file must be located in $HOME/Dist" >&2
    return 1
  }
}

function tpa__symlink_install {
  #$1 - required, exe file to install
  #$2 - optional, man page
  #-l - optional, symlink name for exe file
  #--dry - don't create links, print paths

  #Parse and validate args
  local OPTS
  OPTS=$(getopt -o l: --long link-name:,dry -n "${FUNCNAME[0]}" -- "$@")
  eval set -- "$OPTS"

  while (($# > 0)); do
    case $1 in
      --dry)
        local dry="1"
        shift
        ;;
      -l | --link-name)
        local link_name=$2
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

  __tpa__validate_exe "$1" || return 1
  local exe_file="$1"
  local man_file="$2"

  #Create link on exe
  if [[ -z "$link_name" ]]; then
    local link_name
    link_name="$(basename "$exe_file")"
    link_name="${link_name%.*}"
  fi
  local exe_link_path="$__TPA_BIN_DIR/$link_name"

  if [[ "$dry" ]]; then
    echo "  exe: $exe_link_path" >&2
  else
    ln -s "$(realpath --relative-to="$__TPA_BIN_DIR" "$exe_file")" "$exe_link_path"
    chmod +x "$exe_file"
  fi

  #If have man, create link on it
  if [[ -s "$man_file" && "$man_file" = *.[0-9] ]]; then
    local ext="${man_file##*.}"
    local man_subdir="man${ext}"
    local man_link_path
    man_link_path="$__TPA_MAN_DIR/$man_subdir/$(basename "$man_file")"
    if [[ "$dry" ]]; then
      echo "  man: $man_link_path" >&2
    else
      ln -s "$(realpath --relative-to="$__TPA_MAN_DIR/$man_subdir" "$man_file")" "$man_link_path"
    fi
  fi

  #Add to 'cache' file, maybe better call it 'registry'
  local entry="$exe_link_path"
  if [[ "$man_link_path" ]]; then
    entry="$entry:$man_link_path"
  fi
  if [[ "$dry" ]]; then
    echo "cache: $entry" >&2
  else
    if [[ -s "$__TPA_CACHE_FILE" ]]; then
      #shellcheck disable=1003
      sed 'a\'"$entry" < "$__TPA_CACHE_FILE" | sort -u | sponge "$__TPA_CACHE_FILE"
    else
      echo -e "$entry" > "$__TPA_CACHE_FILE"
    fi
  fi
}

function tpa__symlink_uninstall {
  # $1 should be prog name aka symlink
  local symlink_path
  symlink_path="$(which "$1")"
  local which_status="$?"
  [[ "$which_status" = "0" && -L "$symlink_path" ]] || {
    echo "Symlink from PATH required" >&2
    return 1
  }

  local exe_file
  exe_file="$(readlink -f "$symlink_path")"
  __tpa__validate_exe "$exe_file" || return 1

  rm "$symlink_path"
  chmod -x "$exe_file"

  local entry
  entry=$(grep "$symlink_path" < "$__TPA_CACHE_FILE")

  if [[ "$entry" ]]; then
    (
      IFS=:
      for link in $entry; do
        [[ "$link" != "$symlink_path" ]] && rm "$link"
      done
    )
    grep -v "$entry" < "$__TPA_CACHE_FILE" | sort -u | sponge "$__TPA_CACHE_FILE"
  fi
}

function tpa__ls {
  local line
  for line in $(< "$__TPA_CACHE_FILE"); do
    local l=${line#"$__TPA_BIN_DIR/"}
    echo "${l%%:*}"
  done
}

function __tpa__symlink_uninstall_completions {
  if [[ -s "$__TPA_CACHE_FILE" ]]; then
    #I don't want to bother with completion for now
    COMPREPLY=($(compgen -W "$(tpa__ls)" -- "${COMP_WORDS[1]}"))
  fi
}

complete -F __tpa__symlink_uninstall_completions tpa__symlink_uninstall
