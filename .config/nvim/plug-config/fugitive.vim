nnoremap <silent><leader>gs <cmd>G \| execute "resize" string(&lines * 0.3)<cr>
nnoremap <silent><leader>gi <cmd>:Gvdiffsplit! :%<cr>
nnoremap <silent><leader>gg <cmd>call <sid>Cmd()<cr>
nnoremap <silent><leader>gt <cmd>Gvdiffsplit! HEAD \| Gvdiffsplit! :%<cr>

cnoreabbrev hg h fugitive

augroup PlugFugitive
  autocmd!
  autocmd BufEnter fugitive:///* set bufhidden=wipe
  " autocmd BufWinEnter fugitive:///*/.git//0/* call s:IndexBufWinEnter()
  " autocmd BufUnload fugitive:///*/.git//0/* call s:IndexBufUnload()
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

function! s:IndexBufWinEnter() abort
  let wcBuf = matchstr(expand('<afile>'), '\(/.git//0/\)\@<=.\+')
  " let bi = 'fugitive:///home/igor/dotfiles/.git//0/.config/nvim/plug-config/fugitive.vim'
  echom "NEW INDEX BUF! for ".wcBuf
endfunction

function! s:IndexBufUnload() abort
  echom "UNLOAD index buf"
endfunction

function! s:Cmd() abort
  if !&buftype
    Gvdiffsplit! HEAD
  else
    call utils#Warning('No DIFF for non-file buf')
  endif
endfunction
