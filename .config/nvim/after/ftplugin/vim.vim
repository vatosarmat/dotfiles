setlocal formatoptions-=c

autocmd BufWritePre <buffer> call utils#TrimBufLines()
