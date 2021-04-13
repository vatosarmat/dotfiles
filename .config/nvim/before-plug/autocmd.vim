augroup BeforePlug
  autocmd!

  autocmd BufAdd * call s:AddAny()

  autocmd FileType qf setlocal norelativenumber

  autocmd WinNew * let g:help_to_left = win_getid()
  autocmd BufWinEnter *.txt call s:OnBufWinEnterTxt()

  "Clear trailing spaces
  autocmd BufWritePre * %s/\s\+$//e

augroup END

function! s:AddAny() abort
  if !empty(&buftype)
    nnoremap <buffer><M-d> <nop>
    nnoremap <buffer><M-f> <nop>
  endif
endfunction

function! s:OnBufWinEnterTxt() abort
  if &buftype == 'help' && g:help_to_left == win_getid()
    wincmd L
  endif
endfunction

