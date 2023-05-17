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

  #endpoint
  local endpoint
  if [[ "$TELEGRAM_API_ENDPOINT" ]]; then
    endpoint="$TELEGRAM_API_ENDPOINT"
  elif [[ -r ".env" ]]; then
    endpoint="$(dotenv__read TELEGRAM_API_ENDPOINT)"
  fi
  if [[ ! "$endpoint" ]]; then
    endpoint="https://api.telegram.org"
  fi

  # For -X POST --data '{...}' need '-H' 'Content-Type: application/json'

  echo curl -sS "${endpoint}/bot${token}/${method}" "$@" >&2
  if [[ "$no_jq" ]]; then
    curl -sS "${endpoint}/bot${token}/${method}" "$@"
  else
    curl -sS "${endpoint}/bot${token}/${method}" "$@" | jq
  fi

}

# complete -W "now tomorrow never" dothis

alias tgc="telegram__call"
