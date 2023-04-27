alias pa="php artisan"
alias phc="php composer.phar"

function php__completion {
  source <(composer completion)
  source <(laravel completion)
  # source <(php artisan completion)
}
