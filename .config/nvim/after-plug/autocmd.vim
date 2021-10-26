let g:autocmd#last_win_new = -1

augroup BeforePlug
  autocmd!
  autocmd TextYankPost * call s:TextYankPost()

  autocmd BufAdd * if !empty(&buftype) | call mappings#NopDiff() | endif

  autocmd FileType qf setlocal norelativenumber | call mappings#FtQf()
  autocmd FileType help call docfavs#Init()

  "Move help window right
  autocmd WinNew * call s:OnWinNew()
  autocmd BufWinEnter *.txt call s:OnBufWinEnterTxt()

  autocmd DiffUpdated * call s:HighlightDiffConflictMarker()
  autocmd DirChanged * call s:OnDirChanged()
  "C-x C-e
  autocmd VimEnter /tmp/bash-* exe "normal!" "ggO#shellcheck shell=bash\<cr>" | startinsert
  autocmd VimEnter * call s:OnVimEnter()

  autocmd BufRead,BufNewFile *.json,.prettierrc set filetype=jsonc

  autocmd BufWinEnter * call s:UserStateWinEnter()
  autocmd WinClosed * diffupdate! | call s:UserStateWinClosed(expand('<afile>'))

  "Clear trailing spaces
  autocmd BufWritePre * if g:uopts.laf | call s:TrimLines() | endif
augroup END

function! s:OnVimEnter() abort
  call s:HighlightDiffConflictMarker()
  call project_type#Guess()
  call fzf#ProjectType()
  "M-n M-p navigate through jump-list
  clearjumps
endfunction

function! s:OnDirChanged() abort
  if v:event.scope == 'global'
    call project_type#Guess()
    call fzf#ProjectType()
  endif
endfunction

function! s:UserStateWinClosed(winid) abort
  if g:ustate.qf_window == a:winid
    let g:ustate.qf_window = 0
  elseif has_key(g:ustate.loclist_windows, a:winid)
    call remove(g:ustate.loclist_windows, a:winid)
  endif
endfunction

function! s:UserStateWinEnter() abort
  if &buftype == 'quickfix'
    let id = win_getid()
    if getwininfo(id)[0].loclist == 1
      let g:ustate.loclist_windows[id] = 1
    else
      let g:ustate.qf_window = id
    endif
  endif
endfunction

function! s:TextYankPost() abort
  if v:event.regname != '+'
    let g:ustate.yank_clipboard = 0
  endif
  silent! lua vim.highlight.on_yank {higroup="YankHighlight", timeout=1000}
endfunction

function! s:OnBufWinEnterTxt() abort
  "Move each new help window right if no other help windows
  if g:uopts.hl &&
    \ win_getid() == g:autocmd#last_win_new &&
    \ &buftype == 'help' &&
    \ !exists('w:help_moved') &&
    \ utils#Find(tabpagebuflist(), {bnr -> bnr!=bufnr() && getbufvar(bnr, '&filetype') == 'help'})[1] == -1
        let w:help_moved = 1
        wincmd L
  endif
endfunction

function! s:OnWinNew() abort
  "M-n M-p navigate through jump-list
  clearjumps

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



