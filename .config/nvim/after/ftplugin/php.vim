" set iskeyword+=$
setl tabstop=4 softtabstop=4 shiftwidth=4

autocmd BufWritePre <buffer> call utils#Retab()
