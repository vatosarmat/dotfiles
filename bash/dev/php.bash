alias pa="php artisan"

function php__completion {
  source <(composer completion)
  source <(laravel completion)
  # source <(php artisan completion)
}
