nnoremap <silent><M-d> :Gvdiffsplit! HEAD<cr>
cnoreabbrev G G \| execute "resize" string(&lines * 0.3)
cnoreabbrev hg h fugitive

augroup PlugFugitive
  autocmd!
  autocmd BufEnter fugitive:///* set bufhidden=wipe
  autocmd FileType fugitive call s:TypeFugitive()
augroup END

function! s:TypeFugitive() abort
  nnoremap <silent><buffer><M-d> :call <sid>ToggleWinSize()<cr>
  nnoremap <silent><buffer>cc  :vert Git commit \| call utils#ShowUnsavedBuffers()<cr>
endfunction

function! s:ToggleWinSize() abort
  if !exists("b:dfWinSmall") || !b:dfWinSmall
    execute "resize" string(&lines * 0.3)
    let b:dfWinSmall = 1
  else
    execute "resize" string(&lines * 0.5)
    let b:dfWinSmall = 0
  endif
endfunction
