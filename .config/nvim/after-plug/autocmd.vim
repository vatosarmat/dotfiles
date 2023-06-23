let g:autocmd#last_win_new = -1

augroup ConfigMain
  autocmd!
  autocmd TextYankPost * call s:TextYankPost()

  autocmd BufAdd * call s:OnBufAdd()

  autocmd FileType qf setlocal norelativenumber
  autocmd FileType help call docfavs#Init()

  autocmd WinNew * call s:OnWinNew()
  autocmd BufWinEnter *.txt call s:OnBufWinEnterTxt()
  autocmd BufWinEnter * call s:OnBufWinEnter()

  autocmd DiffUpdated * call s:HighlightDiffConflictMarker()
  autocmd DirChanged * call s:OnDirChanged()
  "C-x C-e
  autocmd VimEnter /tmp/bash-* ++once exe "normal!" "ggO#shellcheck shell=bash\<cr>" | startinsert
  autocmd VimEnter * ++once call s:OnVimEnter()

  autocmd BufRead,BufNewFile *.json,.prettierrc set filetype=jsonc

  autocmd WinClosed * diffupdate! | call s:UserStateWinClosed(expand('<afile>'))
augroup END

function! s:OnBufWinEnter() abort
  " echom 'OnBufWinEnter '.expand('<afile>')

  "Sometimes FileType is missing, set ft if have it
lua << END
  local afile = vim.fn.expand('<afile>')
  local abuf = tonumber(vim.fn.expand('<abuf>'))
  local ft = vim.bo[abuf].ft
  local buftype = vim.bo[abuf].buftype
  if afile ~= '' and ft ~= '' and buftype == '' then
    vim.defer_fn(function()
      vim.bo[abuf].ft = ft
    end, 1000);
  end
END

  "...
  if &buftype == 'quickfix'
    let id = win_getid()
    if getwininfo(id)[0].loclist == 1
      let g:ustate.loclist_windows[id] = 1
    else
      let g:ustate.qf_window = id
    endif
  endif

  "...
  call jumplist#BufWinEnter()

  "Get rid of ^M. Other ways don't work.
  if char2nr(getline(1)[-1:-1]) == 13
    e ++ff=dos
  endif

  "Force buffer names to be relative paths
  execute 'cd' getcwd()

  "DAP
lua << END
vim.schedule(function()
  local dap = require"dap"
  local shortmap = require 'shortmap'
  local session =dap.session()
  if session then
    shortmap.enable('debug')
  end
end
)
END
endfunction

function! s:OnBufAdd() abort
  " echom 'BufAdd'
endfunction

function! s:OnVimEnter() abort
  call s:HighlightDiffConflictMarker()
  lua require 'project'.configure()
endfunction

function! s:OnDirChanged() abort
  if v:event.scope == 'global'
    lua require 'project'.configure()
  endif
endfunction

function! s:UserStateWinClosed(winid) abort
  if g:ustate.qf_window == a:winid
    let g:ustate.qf_window = 0
  elseif has_key(g:ustate.loclist_windows, a:winid)
    call remove(g:ustate.loclist_windows, a:winid)
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
  if g:UOPTS.hl &&
    \ win_getid() == g:autocmd#last_win_new &&
    \ &buftype == 'help' &&
    \ !exists('w:help_moved') &&
    \ utils#Find(tabpagebuflist(), {bnr -> bnr!=bufnr() && getbufvar(bnr, '&filetype') == 'help'})[1] == -1
        let w:help_moved = 1
        wincmd L
  endif
endfunction

function! s:OnWinNew() abort
  "...
  let g:autocmd#last_win_new = win_getid()
endfunction

function! s:HighlightDiffConflictMarker() abort
  if &diff && !exists('w:conflict_markers_match')
    let w:conflict_markers_match = matchadd('DiffConflictMarker','^\(<<<<<<<\|=======\|>>>>>>>\||||||||\).*$', 9999)
  endif
endfunction
