
augroup FtSpecific
  autocmd!
  autocmd BufAdd * call s:AddAny()

  autocmd FileType sh call s:TypeSh()
  autocmd FileType haskell call s:TypeHaskell()
  autocmd FileType lisp call s:TypeLisp()
  autocmd FileType fugitive call s:TypeFugitive()

  autocmd BufEnter *.txt call s:EnterTxt()
  autocmd BufEnter fugitive:///* call s:EnterFugitive()
augroup END

function! s:AddAny() abort
  if &buftype != ''
    nnoremap <buffer><M-d> <nop>
    nnoremap <buffer><M-f> <nop>
  endif
endfunction

function! s:EnterTxt() abort
  if &buftype == 'help'
    wincmd L
  endif
endfunction

function! s:EnterFugitive() abort
  set bufhidden=wipe
endfunction

"FileType
function! s:TypeFugitive() abort
  nnoremap <silent><buffer><M-d> :call <sid>ToggleWinSize()<cr>
  nnoremap <silent><buffer>cc  :vert Git commit \| call DotfilesShowUnsavedBuffers()<cr>
endfunction

function! s:TypeSh() abort
  let b:surround_{char2nr("p")} = "$(\r)"
  let b:surround_{char2nr("s")} = "${\r}"
endfunction

function! s:TypeHaskell() abort
  xmap <buffer> sf s<C-f>
  cnoreabbrev <buffer> lfix !hlint --refactor --refactor-options="--inplace" '%:p'
endfunction

function! s:TypeLisp() abort
  xmap <buffer> sf s<C-f>
  let b:coc_pairs_disabled = ["'"]
endfunction

"Implementations
function! s:ToggleWinSize() abort
  if !exists("b:dfWinSmall") || !b:dfWinSmall
    execute "resize" string(&lines * 0.3)
    let b:dfWinSmall = 1
  else
    execute "resize" string(&lines * 0.5)
    let b:dfWinSmall = 0
  endif
endfunction
