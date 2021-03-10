cnoreabbrev hq h quickref
cnoreabbrev hg h fugitive
cnoreabbrev hc h coc-nvim.txt
cnoreabbrev ht h \| Helptags
noreabbrev hit tabe \| so $VIMRUNTIME/syntax/hitest.vim

cnoreabbrev reh !hlint --refactor --refactor-options="--inplace" '%:p'
cnoreabbrev cr CocRestart


augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
augroup END

cnoreabbrev svrc source $MYVIMRC
cnoreabbrev mm messages

function! s:GitStatusOrUnsavedBuffers() abort
  let unsavedBuffers = []
  for buf in getbufinfo({'bufmodified':1})
    if !empty(buf['name']) && empty(getbufvar(buf['bufnr'], '&buftype'))
      call add(unsavedBuffers, [buf['bufnr'], buf['name']])
    endif
  endfor
  if len(unsavedBuffers) > 0
    let leftPad = '    '
    echom 'Unsaved buffers:'
    for [nr,name] in unsavedBuffers
      echom leftPad.nr.' '.name
    endfor
  else
    Git | execute "resize" string(&lines * 0.27)
  endif
endfunction
command! G call<sid>GitStatusOrUnsavedBuffers()

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
