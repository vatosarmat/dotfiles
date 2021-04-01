"Help abbrevs
cnoreabbrev hq h quickref
cnoreabbrev he h eval.txt

"Other abbrevs
" noreabbrev hit tabe \| so $VIMRUNTIME/syntax/hitest.vim
cnoreabbrev svrc source $MYVIMRC
cnoreabbrev mm messages

"Commands
command! -nargs=1 -complete=command Redir silent call <sid>Redir(<f-args>)
command! DiffOrig silent call<sid>DiffOrig()

"Implementations
function! s:Redir(cmd) abort
  "Redirect the output of a Vim or external command into a scratch buffer
  "Doesn't highlight syntax and if manually set ft - becames laggy
  let output = execute(a:cmd)
  tabnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, "\n"))
endfunction

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
