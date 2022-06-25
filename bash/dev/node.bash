#shellcheck disable=2155

function node__ng_completion {
  source <(ng completion script)
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

function node__tsgrep {
  pgrep -fa tsserver.js | sed -E 's%^.+\s+(.+typescript)/lib/tsserver\.js.+$%\1%' | while IFS= read -r d; do
    jq -r '.version' "$d/package.json"
  done
}

function node__sortdeps {
  jq '.dependencies=(.dependencies | to_entries | sort | from_entries)' package.json | sponge package.json
}

function node__updeps {
  # Expect package.json in the current dir
  local package_name
  if ! package_name="$(jq -r '.name' package.json)"; then
    return 1
  fi

  declare -a cmd_install_dev
  declare -a cmd_install_prod
  local package_json_path
  if [[ "$1" = "-w" ]]; then
    local subpackage="${2-}"
    test "$subpackage" || {
      echo 'workspace subpackage name expected' >&2
      return 1
    }
    local workspace_info_json="$(yarn --silent workspaces info --json)"
    jq -r --arg package_name "$package_name" 'keys | map(ltrimstr("@"+$package_name+"/")) | .[]' <<< "$workspace_info_json" |
      grep -Fqx "$subpackage" || {
      echo 'No such subpackage in the workspace!' >&2
      return 1
    }
    package_json_path="$(jq -r \
      --arg package_name "$package_name" \
      --arg subpackage "$subpackage" \
      '.["@"+$package_name+"/"+$subpackage].location' <<< "$workspace_info_json")/package.json"

    cmd_install_dev=("yarn" "workspace" "@${package_name}/${subpackage}" "add" "--dev")
    cmd_install_prod=("yarn" "workspace" "@${package_name}/${subpackage}" "add")
  else
    if [[ -r "yarn.lock" ]]; then
      cmd_install_dev=("yarn" "add" "--dev")
      cmd_install_prod=("yarn" "add")
    else
      cmd_install_prod=("npm" "install" "--save-prod")
      cmd_install_dev=("npm" "install" "--save-dev")
    fi
    package_json_path="package.json"
  fi

  #shellcheck disable=2016
  local jq_filter='keys | map(select(startswith("@"+$package_name+"/")|not)+"@latest") | .[]'
  declare -ar deps_dev="($(
    jq -r --arg package_name "$package_name" "try .devDependencies | $jq_filter" \
      < "$package_json_path"
  ))"
  declare -ar deps_prod="($(
    jq -r --arg package_name "$package_name" "try .dependencies | $jq_filter" \
      < "$package_json_path"
  ))"

  test "${deps_dev[0]}" && "${cmd_install_dev[@]}" "${deps_dev[@]}"
  test "${deps_prod[0]}" && "${cmd_install_prod[@]}" "${deps_prod[@]}"
}
