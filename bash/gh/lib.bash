#shellcheck shell=bash
function __gh__prompt_repo_action {
  repo=${1##+( )}
  while true; do
    read -rn 1 -p "\e[1m${repo}\e[m - [\e[1mw\e[m]eb, [\e[1mv\e[m]iew, [\e[1mr\e[m]elease? " act;
    echo -e "\n"

    case $act in
      w|W)
        gh repo view --web "$repo"
        break
        ;;
      v|V)
        gh repo view "$repo"
        break
        ;;
      r|R)
        gh__releases "$repo"
        break
        ;;
    esac
  done
  cache_file="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.cache"
  #shellcheck disable=1003
  sed '$a\'"${repo}" < "$cache_file" | sort -u | sponge "${cache_file}"
}

function gh__cache {
  q="$*"
  cache_file="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.cache"

  fzfSelected=$(fzf --query "$q" < "$cache_file")
  fzfStatus="$?"

  if [ "$fzfStatus" = "0" ] && [ -n "$fzfSelected" ]; then
    __gh__prompt_repo_action "$fzfSelected"
  fi
}

function __gh__assets {
  repo="$1"
  tag="$2"
  fieldSep=$'\ua0'

  fzfSelected=$(gh api repos/"${repo}"/releases/tags/"${tag}" | \
    jq --arg F__ "$fieldSep" '.assets | map( .name +
      $F__ + (.size |
        if .>1000000 then (./1000000)|floor|tostring+" M"
        elif .>1000 then (./1000)|floor|tostring+" K"
        else .|tostring+" B" end))[]' -r | \
    awk -v FS="$fieldSep" -v OFS="$fieldSep" '{ print sprintf("%-32s", $1), $2}' | \
    fzf --nth=1,2 --delimiter="$fieldSep" -m )
  fzfStatus="$?"

  if [ "$fzfStatus" = "0" ] && [ -n "$fzfSelected" ]; then
    path="$HOME/Dist/${repo#*/}/$tag"
    mkdir -p "$path"
    asset_args=$(echo "$fzfSelected" | awk -F "$fieldSep" '{ r=r" -p "$1 } END{ print r }')
    #shellcheck disable=2086
    gh release download -R "$repo" $asset_args -D "$path"
  fi
}

function gh__releases {
  test -n "$1" || { echo "No GitHub repo" >&2; return 1; }

  #Check case-insensitively
  shopt -s nocasematch
  [[ "$1" =~ ^[a-z\._0-9-]+/[a-z\._0-9-]+$ ]]
  matchStatus="$?"
  shopt -u nocasematch
  test "$matchStatus" = "0" || { echo "Argument doesn't look like a GitHub repo" >&2; return 1; }

  fzfSelected=$(gh release list -R "$1" | fzf )
  fzfStatus="$?"

  if [ "$fzfStatus" = "0" ] && [ -n "$fzfSelected" ]; then
    #shellcheck disable=2034
    IFS=$'\t' read -r title comment tag rest<<< "$fzfSelected"
    __faketty gh release view -R "$1" "$tag" | $PAGER
    __gh__assets "$1" "$tag"
  fi
}

function gh__search {
  test -n "$1" || { echo "No search query" >&2; return 1; }
  fieldSep=$'\ua0'
  q="$*"

  fzfSelected=$(gh api search/repositories?q="${q// /+}" | \
    jq --arg F__ "$fieldSep" '.items | sort_by(.stargazers_count) | reverse |
        map(.owner.login + "/" + .name +
            $F__+ "\u2b50" + (.stargazers_count | tostring) +
            $F__+ .description)[]' -r | \
    awk -v FS="$fieldSep" -v OFS="$fieldSep" '{ print sprintf("%8s", $2), sprintf("  %s", $1), $3}' | \
    fzf --with-nth=1,2 --nth=2,3 --delimiter="$fieldSep" \
        --preview 'echo {3}' --preview-window wrap)
  fzfStatus="$?"

  if [ "$fzfStatus" = "0" ] && [ -n "$fzfSelected" ]; then
    #shellcheck disable=2034
    IFS="$fieldSep" read -r stars repo rest <<< "$fzfSelected"
    __gh__prompt_repo_action "$repo"
  fi
}

