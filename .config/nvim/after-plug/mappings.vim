
function! s:Misc() abort
  " nnoremap <leader>g <cmd>set operatorfunc=<SID>GrepOperator<cr>g@
  " xnoremap <leader>g <cmd>call <SID>GrepOperator(visualmode())<cr>

  " function! s:GrepOperator(type)
  "     let saved_unnamed_register = @@

  "     if a:type ==# 'v'
  "         normal! `<v`>y
  "     elseif a:type ==# 'char'
  "         normal! `[v`]y
  "     else
  "         return
  "     endif

  "     silent execute "grep! -R " . shellescape(@@) . " ."
  "     copen

  "     let @@ = saved_unnamed_register
  " endfunction

  "Macro, <Home> is C-m
  nnoremap <Home> q

  "Where is cursor
  nnoremap <C-g> <cmd>echo nvim_treesitter#statusline(#{indicator_size: &columns })<cr>

  "Redraw
  nnoremap g_ <C-l>

  "Toggle search highlight
  nnoremap <silent> <M-u> <cmd>noh<CR>

  "Useful before reviewing delta and commit
  nnoremap <silent><leader>iub :call utils#ShowUnsavedBuffers()<cr>

  "Syntax element under cursor
  nnoremap <silent><leader>isn :echo synIDattr(synID(line("."), col("."), 1), "name")<cr>

  nnoremap <leader>itl :lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))<cr>

  "Terminal normal mode
  tnoremap <c-o> <C-\><C-n>

  "Easier merging
  nnoremap <leader>gml <cmd>diffget LOCAL<cr>
  nnoremap <leader>gmr <cmd>diffget REMOTE<cr>

  "Toggle fold
  nnoremap <C-f> za
endfunction

function! s:Motions() abort
  "zt and zb are inconvinient
  nnoremap <M-i> zt
  nnoremap <M-o> zz
  nnoremap <M-Tab> zb
  xnoremap <M-i> zt
  xnoremap <M-o> zz
  xnoremap <M-Tab> zb

  "
  nnoremap <M-C-y> <C-y>
  nnoremap <M-C-e> <C-e>
  xnoremap <M-C-y> <C-y>
  xnoremap <M-C-e> <C-e>

  "Handy paragraph movements
  noremap <silent>K <cmd>call motion#Paragraph('backward')<cr>
  " xnoremap <silent>K <cmd>call motion#Paragraph('backward')<cr>
  " nnoremap <silent>J <cmd>call motion#Paragraph('forward')<cr>
  noremap <silent>J <cmd>call motion#Paragraph('forward')<cr>

  "Builtin sentence and paragraph motions shouldn't be tossed jump stack
  nnoremap <silent>} :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
  nnoremap <silent>{ :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

  "Handy line start/end
  noremap <C-a> _
  noremap <C-e> g_

  "Handier than ,
  nnoremap <M-;> ,

  " nnoremap <silent>gg <cmd>keepjumps normal! gg<cr>
  " nnoremap <silent>G <cmd>keepjumps normal! Gzz<cr>
  nnoremap <silent>G Gzz

  "Search
  nnoremap n <cmd>call <sid>Jump('n')<cr>
  nnoremap N <cmd>call <sid>Jump('N')<cr>

  " function s:NoJump(cmd) abort
  function s:Jump(cmd) abort
    try
      " execute 'keepjumps' 'normal!' a:cmd
      execute 'normal!' a:cmd
      call uopts#nzz()
    catch /E384/
      call utils#Print('ErrorMsg', 'TOP ', [@/, 'LspDiagnosticsSignInformation'])
    catch /E385/
      call utils#Print('ErrorMsg', 'BOTTOM ', [@/, 'LspDiagnosticsSignInformation'])
    endtry
  endfunction

  "Global marks are more useful
  function! s:RemapMarks() abort
    for i in range(char2nr('a'), char2nr('z'))
      let a = nr2char(i)
      let A = toupper(a)
      execute 'nnoremap' ','.a 'm'.A
      execute 'nnoremap' ''''.a ''''.A
      execute 'nnoremap' ','.A 'm'.a
      execute 'nnoremap' ''''.A ''''.a
    endfor
  endfunction
  call s:RemapMarks()
endfunction

function! s:Edit() abort
  noremap X J

  "Indent
  inoremap <C-l> <C-o>==
  nnoremap <C-l> ==
  xnoremap <C-l> =

  "More convinient register selector
  nnoremap q "
  xnoremap q "

  "Easier paste in insert mode
  inoremap <C-r>r <C-r>"
  inoremap <C-r><C-r> <C-r>"
  inoremap <C-r>" <C-r>r

  "Paste from vim to system clipboard
  nnoremap <silent> <M-y> <cmd>let @+=@" \| let g:ustate.yank_clipboard = 1<cr>

  "Charwise-linewise
  nnoremap <M-q> <cmd>call <sid>ToggleRegtype()<cr>
  function! s:ToggleRegtype() abort
    let urt = getregtype('"')
    if urt ==# 'v'
      call setreg('"', @", 'V')
    elseif urt ==# 'V'
      call setreg('"', trim(@"), 'v')
    endif
  endfunction

  "Save file like in all other programs
  nnoremap <silent> <C-s> :w<cr>
  inoremap <silent> <C-s> <Esc>:w<cr>

  "yy - for string, Y - for rest of string, same with 'c' and 'd'
  nnoremap Y y$

  "Yank file name and line num
  nnoremap <leader>yl <cmd>let @+=expand('%').':'.line('.')<cr>
  nnoremap <leader>yc <cmd>let @+=getcwd()<cr>

  "No overwrite paste and change
  nnoremap c "_c
  xnoremap c "_c
  nnoremap C "_C
  xnoremap C "_C

  nnoremap p ]p
  nnoremap P ]P

  function! s:PasteOver() abort
    execute 'normal!' '"_d"'.v:register.( col('.')+1==col('$') ? 'p' : 'P')
  endfunction
  xnoremap p <cmd>call <sid>PasteOver()<cr>

  "Replace last search pattern, i.e. '/' register content
  nnoremap <M-r> :.,$s//<c-r>=utils#GetSearchPatternWithoutFlags()<cr>/gc<left><left><left>
  xnoremap <M-r> :s//<c-r>=utils#GetSearchPatternWithoutFlags()<cr>/gc<left><left><left>

  "Replace very magic pattern
  nnoremap <M-/> :.,$s/\v//gc<left><left><left><left>
  xnoremap <M-/> :s/\v//gc<left><left><left><left>

  function! s:GetVisualSelection() abort
    let [_, _, start,_] = getpos('v')
    let [_, _, end,_] = getpos('.')

    return getline('.')[start-1:end-1]
  endfunction

  function! s:ReplaceSelection() abort
    let str = s:GetVisualSelection()
    call feedkeys(":\<C-u>".printf('%%s/\v%s/%s/gc', str, str)."\<left>\<left>\<left>")
  endfunction

  xnoremap <M-C-r> <cmd>call <sid>ReplaceSelection()<cr>
endfunction

function s:InsertLikeEmacs() abort
  "Line begin-end
  inoremap <expr><C-a> getline('.')[0] == ' ' ? "\<Home>\<C-Right>" : "\<Home>"
  inoremap <C-e> <End>
  cnoremap <C-a> <Home>
  cnoremap <C-e> <End>
  "Word backward-forward
  inoremap <M-b> <C-Left>
  inoremap <M-f> <C-Right>
  cnoremap <M-f> <C-Right>
  cnoremap <M-b> <C-Left>
  "Delete char forward
  inoremap <C-d> <Del>
  cnoremap <C-d> <Del>
  "Delete word backward-forward
  inoremap <M-BS> <C-w>
  inoremap <M-d> <C-o>de
  cnoremap <M-BS> <C-w>
  "Delete line end
  inoremap <C-k> <C-o>d$
  "Undo
  inoremap <C-_> <C-o>u
endfunction

function! s:Windows() abort
  "Jump forward/back in split
  " nnoremap <C-w><C-o> <C-w>v<C-o>
  " nnoremap <C-w>O <C-w>s<C-o>
  " nnoremap <C-w><C-i> <C-w>v<C-i>
  " nnoremap <C-w>I <C-w>s<C-i>

  "Open window dup in a new tab
  nnoremap <C-w>t <C-w>v<C-w>T

  nnoremap ]t gt
  nnoremap [t gT

  "Easier windows navigation with arrows remapped to 'hjkl' in terminal emulator
  nnoremap <Left>  <C-w>h
  nnoremap <Down>  <C-w>j
  nnoremap <Up>    <C-w>k
  nnoremap <Right> <C-w>l

  nnoremap <silent><M-H>  <cmd>vertical resize -5<cr>
  nnoremap <silent><M-J>  <cmd>         resize -5<cr>
  nnoremap <silent><M-K>  <cmd>         resize +5<cr>
  nnoremap <silent><M-L>  <cmd>vertical resize +5<cr>
endfunction

function! s:BufferNavigation() abort
  "Comfy buffer switching
  nnoremap <silent> <M-n> <cmd>call <sid>Mn()<cr>
  nnoremap <silent> <M-p> <cmd>call <sid>Mp()<cr>
  nnoremap <C-M-o> <cmd>lua require 'buffer_navigation'.cycle_mate_bufs()<cr>
  nnoremap g<C-M-o> <cmd>lua require 'buffer_navigation'.clear_mate_bufs()<cr>

  "Wipe buffer or close its window - all via 'q'
  nnoremap <silent>Q <cmd>q<cr>
  nnoremap <silent><M-Q> <cmd>call <SID>Wipe()<cr>
  nnoremap <silent><C-q> <cmd>call jumplist#Exclude()<cr>

  function! s:Mn() abort
    if &diff
      keepjumps normal! ]c
      call uopts#nzz()
    elseif &buftype == ''
      call jumplist#NextBuf()
    endif
  endfunction

  function! s:Mp() abort
    if &diff
      keepjumps normal! [c
      call uopts#nzz()
    elseif &buftype == ''
      call jumplist#PrevBuf()
    endif
  endfunction

  function! s:Wipe()
    let cnr = bufnr()
    call jumplist#AnotherBuf(1)
    execute 'bwipe' cnr
  endfunction
endfunction

function s:QfList() abort
  "quickfix list mappings
  nnoremap <C-M-N> <cmd>call qflist#Step(1)<cr>
  nnoremap <C-M-P> <cmd>call qflist#Step(0)<cr>

  "loclist mappings
  nnoremap <C-M-j> <cmd>call qflist#Step(1, 1)<cr>
  nnoremap <C-M-k> <cmd>call qflist#Step(0, 1)<cr>

  nnoremap <leader>ql <cmd>lopen \| wincmd L \| vertical resize 40 \|wincmd p<CR>
endfunction

function s:QfListBuffer() abort
  nnoremap <buffer> dd <cmd>call qflist#RemoveCurrentItem()<cr>
  xnoremap <buffer> d <cmd>call qflist#RemoveCurrentItem()<cr>
  nnoremap <buffer> u <cmd>call qflist#Restore()<cr>
endfunction

function s:InsertHelpers() abort
  inoremap <M-o> $
  inoremap <M-.> ->
  inoremap <M-;> =>
  inoremap <M-t> $this->
endfunction

call s:Misc()
call s:Motions()
call s:Edit()
call s:InsertLikeEmacs()
call s:Windows()
call s:BufferNavigation()
call s:QfList()
call s:InsertHelpers()

augroup Mappings
  autocmd FileType qf call s:QfListBuffer()
augroup END
