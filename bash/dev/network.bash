#curl
# alias cuget='curl -L -X GET -H "Content-Type: application/json"'
# alias cupost='curl -L -X POST -H "Content-Type: application/json"'
# alias cupatch='curl -L -X PATCH -H "Content-Type: application/json"'
# alias cuput='curl -L -X PUT -H "Content-Type: application/json"'

#
# __curl [METHOD] URL [...CURL_ARGS]
#
function __curl {
  local method=
  case "$1" in
    GET | POST | PATCH | PUT | DELETE)
      method="$1"
      shift
      ;;
  esac

  local no_jq=
  if [[ "$1" = "--no-jq" ]]; then
    no_jq="1"
    shift
  fi

  local -a headers=('-H' 'Content-Type: application/json')
  if [[ -r ".token" ]]; then
    headers+=('-H' 'Authorization: Bearer '"$(< .token)")
  fi

  local url=
  if [[ -r ".host" ]]; then
    url="$(< .host)/$1"
  else
    url="$1"
  fi
  shift

  if [[ "$no_jq" ]]; then
    curl --no-progress-meter --compressed -L -X "$method" "${headers[@]}" "$url" "$@"
  else
    curl --no-progress-meter --compressed -L -X "$method" "${headers[@]}" "$url" "$@" | jq
  fi
}

alias cuget='__curl GET'
alias cupost='__curl POST'
alias cupatch='__curl PATCH'
alias cuput='__curl PUT'
alias cudel='__curl DELETE'

# function cuget {
#   curl -L -X GET -H "Content-Type: application/json"
# }
#
# function cupost {
#   curl -L -X POST -H "Content-Type: application/json"
# }
# function cupatch {
#   curl -L -X PATCH -H "Content-Type: application/json"
#
# }
# function cudelete {
#   curl -L -X GET -H "Content-Type: application/json"
#
# }
