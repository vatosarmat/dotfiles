function telegram__call {
  #this parameter must be first
  local no_jq=
  if [[ "$1" = "--no-jq" ]]; then
    no_jq="1"
    shift
  fi

  #method
  local method="$1"
  shift

  #token
  local token
  if [[ "$TELEGRAM_BOT_TOKEN" ]]; then
    token="$TELEGRAM_BOT_TOKEN"
  # elif [[ -r ".token" ]]; then
  #   token="$(< .token)"
  elif [[ -r ".env" ]]; then
    token="$(dotenv__read TELEGRAM_BOT_TOKEN)"
  fi
  if [[ ! "$token" ]]; then
    echo 'TELEGRAM_BOT_TOKEN is missing' >&2
    return 1
  fi

  local base_url
  if [[ "$TELEGRAM_BASE_URL" ]]; then
    base_url="$TELEGRAM_BASE_URL"
  elif [[ -r ".env" ]]; then
    base_url="$(dotenv__read TELEGRAM_BASE_URL)"
  fi
  if [[ ! "$base_url" ]]; then
    base_url="https://api.telegram.org"
  fi

  # For -X POST --data '{...}' need '-H' 'Content-Type: application/json'

  echo curl -sS "${base_url}/bot${token}/${method}" "$@" >&2
  if [[ "$no_jq" ]]; then
    curl -sS "${base_url}/bot${token}/${method}" "$@"
  else
    curl -sS "${base_url}/bot${token}/${method}" "$@" | jq
  fi

}

# complete -W "now tomorrow never" dothis

alias tgc="telegram__call"
