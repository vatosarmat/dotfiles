"abbrevs
cnoreabbrev hq h quickref
cnoreabbrev hg h fugitive
cnoreabbrev hf h fzf-vim
cnoreabbrev hc h coc-nvim.txt
cnoreabbrev he h eval.txt
cnoreabbrev ht h \| Helptags

" noreabbrev hit tabe \| so $VIMRUNTIME/syntax/hitest.vim
cnoreabbrev cr CocRestart
cnoreabbrev svrc source $MYVIMRC
cnoreabbrev mm messages

"commands
command! -nargs=1 -complete=command Redir silent call <sid>Redir(<f-args>)
command! DiffOrig silent call<sid>DiffOrig()
command! -bang -nargs=* Rga call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, <bang>0)

"functions
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
