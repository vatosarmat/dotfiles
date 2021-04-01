augroup BeforePlug
  "Clear trailing spaces
  autocmd BufWritePre * %s/\s\+$//e
augroup END

