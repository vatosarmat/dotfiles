" Redirect the output of a Vim or external command into a scratch buffer
" Doesn't highlight syntax and if manually set ft - becames laggy
function! Redir(cmd) abort
  let output = execute(a:cmd)
  tabnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, "\n"))
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<f-args>)


function! Cop(dirPath) abort
  if !exists("t:root")
    tabnew
    let t:root = a:dirPath
  endif
  execute "CocCommand explorer" t:root
endfunction

command! -nargs=? -complete=dir Cop silent call Cop(<f-args>)

