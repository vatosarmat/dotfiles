#shellcheck disable=2155

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

function node__tsgrep {
  pgrep -fa tsserver.js | sed -E 's%^.+\s+(.+typescript)/lib/tsserver\.js.+$%\1%' | while IFS= read -r d; do
    jq -r '.version' "$d/package.json"
  done
}

function node__sortdeps {
  jq '.dependencies=(.dependencies | to_entries | sort | from_entries)' package.json | sponge package.json
}

function node__updeps {
  # Take dir as param or use current dir
  local pacjson="$(realpath "${1:-.}/package.json")"
  if ! [[ -f "$pacjson" ]]; then
    echo 'Expected to get path as parameter or to be run in a directory with package.json' >&2
    return 1
  fi
  local pacdir="$(dirname "$pacjson")"
  if [[ -f "$pacdir/yarn.lock" ]]; then
    # declare -ar cmd_remove=("yarn" "remove")
    declare -ar cmd_install=("yarn" "add")
  else
    # declare -ar cmd_remove=("npm" "uninstall" "--save")
    declare -ar cmd_install=("npm" "install" "--save-prod")
  fi
  # readarray -t deps_prod < <(jq --raw-output '.dependencies | keys | .[]' < "$pacjson")
  # "${cmd_remove[@]}" "${deps[@]}"
  # "${cmd_install[@]}" "${deps_prod[@]}"

  jq --raw-output '.dependencies | keys | map(.+"@latest") | .[]' < "$pacjson" |
    tr '\n' ' ' |
    xargs "${cmd_install[@]}"
}
