function php__laravel_completion {
  # source <(composer completion)
  # source <(laravel completion)
  local temp="$(mktemp)"

  if php artisan completion > "$temp"; then
    source "$temp"
    complete -F _sf_artisan pa
  fi
}
