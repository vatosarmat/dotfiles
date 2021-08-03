let g:autocmd#last_win_new = -1

augroup BeforePlug
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="YankHighlight", timeout=1000}

  autocmd BufAdd * if !empty(&buftype) | call mappings#NopDiff() | endif

  autocmd FileType qf setlocal norelativenumber
  autocmd FileType help call docfavs#Init()
  autocmd FileType typescript call s:KeywordMovements()
  autocmd FileType rust call s:KeywordMovements()
  autocmd FileType vim call s:KeywordMovements()
  autocmd FileType lua call s:KeywordMovements()

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
  autocmd BufWritePre * call s:TrimLines()
augroup END

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

function! s:RightExcl() abort
  return getline('.')[col('.'):]
endfunction

function! s:RightIncl() abort
  return getline('.')[col('.')-1:]
endfunction

function! s:LeftExcl() abort
  return getline('.')[:col('.')-2]
endfunction

function! s:LeftIncl() abort
  return getline('.')[:col('.')-1]
endfunction

function! s:KeywordMovements() abort
  function! s:move_w() abort
    let ri = s:RightIncl()
    "Cursor pos
    let prevChar = ri[0]
    for i in range(1, len(ri))
      let char = ri[i]
      if prevChar !~ '\k' && char =~ '\k'
        execute 'normal!' (i).'l'
        return
      endif
      let prevChar = char
    endfor

    normal! g_
  endfunction

  function! s:move_e() abort
    let re = s:RightExcl()
    "Right after cursor pos
    let prevChar = re[0]
    for i in range(1, len(re))
      let char = re[i]
      if prevChar =~ '\k' && char !~ '\k'
        execute 'normal!' (i).'l'
        return
      endif
      let prevChar = char
    endfor

    normal! g_
  endfunction

  function! s:move_b() abort
    let le = s:LeftExcl()
    let ll = len(le)
    "Left before cursor pos
    let nextChar = le[ll-1]
    for i in range(1, ll)
      let char = le[ll-1-i]
      if char !~ '\k' && nextChar =~ '\k'
        execute 'normal!' (i).'h'
        return
      endif
      let nextChar = char
    endfor

    normal! _
  endfunction

  function! s:move_ge() abort
    let li = s:LeftIncl()
    let ll = len(li)
    "Cursor pos
    let nextChar = li[ll-1]
    for i in range(1, ll)
      let char = li[ll-1-i]
      if char =~ '\k' && nextChar !~ '\k'
        execute 'normal!' (i).'h'
        return
      endif
      let nextChar = char
    endfor

    normal! _
  endfunction

  nnoremap w <cmd>call <sid>move_w()<cr>
  nnoremap b <cmd>call <sid>move_b()<cr>
  nnoremap e <cmd>call <sid>move_e()<cr>
  nnoremap ge <cmd>call <sid>move_ge()<cr>
  xnoremap w <cmd>call <sid>move_w()<cr>
  xnoremap b <cmd>call <sid>move_b()<cr>
  xnoremap e <cmd>call <sid>move_e()<cr>
  xnoremap ge <cmd>call <sid>move_ge()<cr>
endfunction

