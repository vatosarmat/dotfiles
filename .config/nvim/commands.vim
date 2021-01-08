cnoreabbrev h vert h
cnoreabbrev hc vert h coc-nvim.txt

cnoreabbrev evrc tabe $MYVIMRC
cnoreabbrev svrc source $MYVIMRC
cnoreabbrev etmc tabe $HOME/.tmux.conf

cnoreabbrev mm messages

cnoreabbrev G G \| execute "resize" string(&lines * 0.27)

function! s:Redir(cmd) abort
  "Redirect the output of a Vim or external command into a scratch buffer
  "Doesn't highlight syntax and if manually set ft - becames laggy
  let output = execute(a:cmd)
  tabnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, "\n"))
endfunction
command! -nargs=1 -complete=command Redir silent call <sid>Redir(<f-args>)

function! s:DiffOrig() abort
  if &buftype != ""
    return 0
  endif
  let filetype = &filetype
  let bname = "orig://".expand("%:p")
  execute "lefta" "vs" bname
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal bufhidden=wipe
  let &filetype=filetype
  1,$d_ | read ++edit # | 0d_
  setlocal nomodifiable
diffthis | wincmd p | diffthis
endfunction
command! DiffOrig silent call<sid>DiffOrig()
