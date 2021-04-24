#shellcheck shell=bash
__TPA_CACHE_FILE="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.cache"

function __tpa__validate_exe {
  # name, in Dist
  # $1 should be an existing exe file
  [[ -n "$1" ]] || { echo "Exe file name required" >&2; return 1; }
  [[ "$(realpath "$1")" = "$HOME/Dist/"* ]] || { echo "Exe file must be located in $HOME/Dist" >&2; return 1; }
}

function tpa__symlink_install {
  #$1 - required, exe file to install
  #$2 - optional, symlink name
  __tpa__validate_exe "$1" || return 1
  exe_file="$1"

  if [[ -n "$2" ]]; then
    symlink_name="$2"
  else
    exe_rel_path="$(realpath --relative-to="$HOME/Dist" "$exe_file")"
    symlink_name="${exe_rel_path%%/*}"
  fi
  ln -s "$(realpath --relative-to="$HOME/.local/bin" "$exe_file")" "$HOME/.local/bin/$symlink_name"
  chmod +x "$exe_file"

  if [[ -s "$__TPA_CACHE_FILE" ]]; then
    #shellcheck disable=1003
    sed 'a\'"$symlink_name" < "$__TPA_CACHE_FILE" | sort -u | sponge "$__TPA_CACHE_FILE"
  else
    echo "$symlink_name" > "$__TPA_CACHE_FILE"
  fi
}

function tpa__symlink_uninstall {
  # $1 should be prog name aka symlink
  symlink_abs_path="$(which "$1")"
  which_status="$?"
  [[ "$which_status" = "0" && -L "$symlink_abs_path" ]] || { echo "Symlink from PATH required" >&2; return 1; }
  symlink_name="$1"

  exe_file="$(readlink -f "$symlink_abs_path")"
  __tpa__validate_exe "$exe_file" || return 1

  rm "$symlink_abs_path"
  chmod -x "$exe_file"

  grep -v "$symlink_name" < "$__TPA_CACHE_FILE" | sort -u | sponge "$__TPA_CACHE_FILE"
}

function __tpa__symlink_uninstall_completions {
  if [[ -s "$__TPA_CACHE_FILE" ]]; then
    #I don't want to bother with completion for now
    COMPREPLY=($(compgen -W "$(<"$__TPA_CACHE_FILE")" -- "${COMP_WORDS[1]}"))
  fi
}

complete -F __tpa__symlink_uninstall_completions tpa__symlink_uninstall
