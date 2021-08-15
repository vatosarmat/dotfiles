let g:autocmd#last_win_new = -1

augroup BeforePlug
  autocmd!
  autocmd TextYankPost * call s:TextYankPost()

  autocmd BufAdd * if !empty(&buftype) | call mappings#NopDiff() | endif

  autocmd FileType qf setlocal norelativenumber
  autocmd FileType help call docfavs#Init()

  "Move help window right
  autocmd WinNew * call s:OnWinNew()
  autocmd BufWinEnter *.txt call s:OnBufWinEnterTxt()

  autocmd DiffUpdated * call s:HighlightDiffConflictMarker()
  autocmd VimEnter * call s:HighlightDiffConflictMarker()
  "C-x C-e
  autocmd VimEnter /tmp/bash-* exe "normal!" "ggO#shellcheck shell=bash\<cr>" | startinsert

  autocmd BufRead,BufNewFile *.json set filetype=jsonc

  autocmd WinClosed * diffupdate!

  "Clear trailing spaces
  autocmd BufWritePre * if g:utils_options.laf | call s:TrimLines() | endif
augroup END

function! s:TextYankPost() abort
  if v:event.regname != '+'
    let g:utils_options.yc = 0
  endif
  silent! lua vim.highlight.on_yank {higroup="YankHighlight", timeout=1000}
endfunction

function! s:OnBufWinEnterTxt() abort
  "Move each new help window right if no other help windows
  if g:utils_options.hl &&
    \ win_getid() == g:autocmd#last_win_new &&
    \ &buftype == 'help' &&
    \ !exists('w:help_moved') &&
    \ utils#Find(tabpagebuflist(), {bnr -> bnr!=bufnr() && getbufvar(bnr, '&filetype') == 'help'})[1] == -1
        let w:help_moved = 1
        wincmd L
  endif
endfunction

function! s:OnWinNew() abort
  let g:autocmd#last_win_new = win_getid()
endfunction

function! s:HighlightDiffConflictMarker() abort
  if &diff && !exists('w:conflict_markers_match')
    let w:conflict_markers_match = matchadd('DiffConflictMarker','^\(<<<<<<<\|=======\|>>>>>>>\||||||||\).*$', 9999)
  endif
endfunction

function! s:TrimLines()
  let save_cursor = getpos(".")
  keeppatterns keepjumps %s/\s\+$//e
  call setpos('.', save_cursor)
endfun



