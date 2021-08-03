"Help abbrevs
cnoreabbrev vh vert help
cnoreabbrev ht Helptags
cnoreabbrev hq h quickref
cnoreabbrev he h eval.txt

"Other abbrevs
" noreabbrev hit tabe \| so $VIMRUNTIME/syntax/hitest.vim
cnoreabbrev svrc source $MYVIMRC
cnoreabbrev mm messages

cnoreabbrev lpi lua print(vim.inspect())<left><left>

"Commands
command! -nargs=1 -complete=command Redir silent call <sid>Redir(<f-args>)
command! DiffOrig silent call<sid>DiffOrig()

" Pass channel as first arg, and string as second
command! -nargs=+ TermPrint call <sid>TermPrint(<f-args>)

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

nnoremap <M-t> <C-W>v:term<cr>:echo &channel<cr>

function! s:TermPrint(chan, ...) abort
  let dd = 'dd of=/dev/stdout count=1 status=none'
  let data = ''

  if a:0 == 2
    let color = a:1 "0-7
    let str = a:2
    let data = printf("\e[3%dm%s\e[m", color, str)
  elseif a:0 == 4
    let r = a:1
    let g = a:2
    let b = a:3
    let str = a:4
    let data = printf("\e[38;2;%d;%d;%dm%s\e[m", r, g, b, str)
  endif

  if empty(data)
    echoerr "Invalid number or arguments"
    return
  endif

  call chansend(str2nr(a:chan), dd."\n".data."\n")
endfunction
