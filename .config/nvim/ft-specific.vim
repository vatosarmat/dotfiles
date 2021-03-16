
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

" Impl
function! s:ToggleWinSize() abort
  if !exists("b:dotfiles_win_small") || !b:dotfiles_win_small
    execute "resize" string(&lines * 0.27)
    let b:dotfiles_win_small = 1
  else
    execute "resize" string(&lines * 0.5)
    let b:dotfiles_win_small = 0
  endif
endfunction
