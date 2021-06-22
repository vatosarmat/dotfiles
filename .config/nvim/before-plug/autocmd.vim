let g:autocmd#last_win_new = -1

augroup BeforePlug
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="YankHighlight", timeout=1000}

  autocmd BufAdd * if !empty(&buftype) | call mappings#NopDiff() | endif

  autocmd FileType qf setlocal norelativenumber
  autocmd FileType help if expand('%:t') == 'eval.txt' | call docfavs#Init() | endif
  autocmd FileType typescript call s:TypescriptMovements()

  "Move help window right
  autocmd WinNew * call s:OnWinNew()
  autocmd BufWinEnter *.txt call s:OnBufWinEnterTxt()

  autocmd DiffUpdated * call s:HighlightDiffConflictMarker()
  autocmd VimEnter * call s:HighlightDiffConflictMarker()

  autocmd BufRead,BufNewFile *.json set filetype=jsonc

  autocmd WinClosed * diffupdate!

  "Clear trailing spaces
  autocmd BufWritePre * call s:TrimLines()
augroup END

function! s:OnBufWinEnterTxt() abort
  if win_getid() == g:autocmd#last_win_new && &buftype == 'help' && !exists('w:help_moved')
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

function! s:TypescriptMovements()
  function! s:TypescriptWord(move)
    let posBefore = utils#GetCursorOff()
    execute 'normal!' a:move
    let posAfter = utils#GetCursorOff()
    while posBefore != posAfter && utils#GetCursorChar() !~ '\k'
      execute 'normal!' a:move
      let posBefore = posAfter
      let posAfter = utils#GetCursorOff()
    endwhile
  endfunction

  nnoremap w <cmd>call <SID>TypescriptWord('w')<cr>
  nnoremap b <cmd>call <SID>TypescriptWord('b')<cr>
  nnoremap e <cmd>call <SID>TypescriptWord('e')<cr>
endfunction

