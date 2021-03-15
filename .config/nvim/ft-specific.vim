
augroup FtSpecific
  autocmd!
  autocmd FileType sh call s:Sh()
  autocmd FileType haskell call s:Haskell()
  autocmd FileType lisp call s:Lisp()

  autocmd BufEnter *.txt call s:DotTxt()
augroup END

function! s:DotTxt() abort
  if &buftype == 'help'
    wincmd L
  endif
endfunction

function! s:Sh() abort
  let b:surround_{char2nr("p")} = "$(\r)"
  let b:surround_{char2nr("s")} = "${\r}"
endfunction

function! s:Haskell() abort
  xmap <buffer> sf s<C-f>
  cnoreabbrev <buffer> lfix !hlint --refactor --refactor-options="--inplace" '%:p'
endfunction

function! s:Lisp() abort
  xmap <buffer> sf s<C-f>
  let b:coc_pairs_disabled = ["'"]
endfunction
