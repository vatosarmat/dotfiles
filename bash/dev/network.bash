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
    GET | POST | PATCH | PUT | DELETE | OPTIONS)
      method="$1"
      shift
      ;;
  esac

  local no_jq=
  if [[ "$1" = "--no-jq" ]]; then
    no_jq="1"
    shift
  fi

  local -a headers=('-H' 'Accept: application/json')
  case "$method" in
    POST | PATCH | PUT)
      headers+=('-H' 'Content-Type: application/json')
      ;;
  esac

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

  if [[ "$method" = "OPTIONS" ]]; then
    curl -i -X OPTIONS "$url" "$@"
    echo
    return
  fi

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
alias cuopt='__curl OPTIONS'

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

function db__mysql_reset {
  local name="$1"
  if [[ ! "$name" ]]; then
    echo "db name expected" >&2
    return 1
  fi

  shift

  mysql << SQL
DROP USER IF EXISTS '$name'@'localhost';
DROP DATABASE IF EXISTS $name;

CREATE USER '$name'@'localhost' IDENTIFIED WITH mysql_native_password BY '123';
CREATE DATABASE $name;
GRANT ALL PRIVILEGES ON $name.* TO '$name'@'localhost';
SQL

  if (($# > 0)); then
    local seed_file="$1"
    mysql -u "$name" --password='123' "$name" < "$seed_file"
  fi

}
