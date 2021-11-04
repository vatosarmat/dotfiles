
noremap X J

"zt and zb are inconvinient
nnoremap <M-i> zt
nnoremap <M-o> zz
nnoremap <M-[> zb

"quickfix list mappings
nnoremap <C-M-N> <cmd>call <sid>QflistStep(1)<cr>
nnoremap <C-M-P> <cmd>call <sid>QflistStep(0)<cr>

"loclist mappings
nnoremap <C-M-j> <cmd>call <sid>QflistStep(1, 1)<cr>
nnoremap <C-M-k> <cmd>call <sid>QflistStep(0, 1)<cr>

function! s:QflistStep(next, loc = 0) abort
  if a:next
    let edge = 'LAST'
    let cmd = a:loc ? 'lafter' : 'cnext' "'cafter'
  else
    let edge = 'FIRST'
    " let cmd = a:loc ? 'lprev' :
    let cmd = a:loc ? 'lbefore' : 'cprev' "'cbefore'
  endif
  try
    "Clear first/last item warning
    execute cmd
  catch /E42/
    call utils#Print('WarningMsg', 'No qflist available')
  catch /E776/
    call utils#Print('WarningMsg', 'No loclist available')
  catch /E553/
    call utils#Print('WarningMsg', [edge, 'LspDiagnosticsSignInformation'], ' item')
  endtry
  if g:uopts.nz
    if a:loc
      call win_gotoid(getloclist(0, #{winid: 0 }).winid) | normal! zz
    else
      call win_gotoid(g:ustate.qf_window) | normal! zz
    endif
    wincmd p
    normal! zz
  endif
endfunction

function! s:QflistRemoveCurrentItem() abort
  let qf_info = getqflist(#{items: 0, idx: 0, context: 0})
  let prev_pos = getpos('.')
  if type(qf_info.context) == v:t_dict
    let context = qf_info.context
  else
    let context = #{ change_list: [] }
  endif

  if mode() == 'V'
    let start_idx = line('v')
    let end_idx = line('.')
    if start_idx > end_idx
      let [start_idx, end_idx] = [end_idx, start_idx]
    else
      let prev_pos[1] -= (end_idx - start_idx)
    endif
  else
    let start_idx = line('.')
    let end_idx = start_idx + v:count1 - 1
  endif

  let new_change = #{
    \ items: remove(qf_info.items, start_idx - 1, end_idx - 1),
    \ start_idx: start_idx,
    \ end_idx: end_idx}

  echom context
  let context.change_list = add(context.change_list, new_change)

  let list_cursor = qf_info.idx
  if start_idx <= list_cursor
    "Keep list cursor on the some entry
    let removed_before_cursor = (min([end_idx, list_cursor]) - start_idx)
    let list_cursor -= removed_before_cursor
  endif

  call setqflist([],  'r', #{items: qf_info.items, idx: list_cursor, context: context})
  "Clear visual
  call feedkeys("\<ESC>")
  call setpos('.', prev_pos)
endfunction

function! s:QflistRestore() abort
  let qf_info = getqflist(#{items: 0, idx: 0, context: 0})
  let prev_pos = getpos('.')
  let context = qf_info.context
  if empty(context) || !has_key(context, 'change_list') || len(context.change_list) < 1
    call utils#Print('WarningMsg', 'No removed items to restore')
    return
  endif

  let last_change = remove(context.change_list, -1)
  call extend(qf_info.items, last_change.items, last_change.start_idx - 1 )

  call setqflist([],  'r', #{items: qf_info.items, idx: qf_info.idx, context: context})
  call setpos('.', prev_pos)
endfunction

function! mappings#FtQf() abort
  nnoremap <buffer> dd <cmd>call <sid>QflistRemoveCurrentItem()<cr>
  xnoremap <buffer> d <cmd>call <sid>QflistRemoveCurrentItem()<cr>
  nnoremap <buffer> u <cmd>call <sid>QflistRestore()<cr>
endfunction

nnoremap ]t gt
nnoremap [t gT

"Macro, <Home> is C-m
nnoremap g<Home> q

"Handy paragraph movement
function! s:IsLineEmpty(line) abort
  return getline(a:line) !~ '\S'
endfunction

function! s:move_paragraph(forward) abort
  if a:forward
    let offset = 1
    let Fold_near = function('foldclosed')
    let Fold_far = function('foldclosedend')
    let direct_par = '}'
    let reverse_par = '{'
    let direct_char = 'j'
    let reverse_char = 'k'
  else
    let offset = -1
    let Fold_near = function('foldclosedend')
    let Fold_far = function('foldclosed')
    let direct_par = '{'
    let reverse_par = '}'
    let direct_char = 'k'
    let reverse_char = 'j'
  endif

  "Pass through all the adjacent folds
  let start = line('.')
  let non_fold = start
  let fend = Fold_far(non_fold)
  while fend != -1
    let non_fold = fend + offset
    let fend = Fold_far(non_fold)
  endwhile

  if start != non_fold
    execute 'keepjumps' string(non_fold)
  endif

  if s:IsLineEmpty(non_fold)
    execute 'keepjumps' 'normal!' direct_par
    let fstart = Fold_near('.')
    if fstart == -1
      execute 'keepjumps' 'normal!' reverse_par.direct_char
    else
      execute 'keepjumps' string(fstart)
    endif
  else
    if s:IsLineEmpty(line('.') + offset)
      execute 'keepjumps' 'normal!' direct_char.direct_par
      let fstart = Fold_near('.')
      if fstart == -1
        execute 'keepjumps' 'normal!' reverse_par.direct_char
      else
        execute 'keepjumps' string(fstart)
      endif
    else
      "Here must be loop to go through fold inside text
      execute 'keepjumps' 'normal!' direct_par.reverse_char
    endif
  endif
endfunction

nnoremap <silent>K <cmd>call <sid>move_paragraph(0)<cr>
xnoremap <silent>K <cmd>call <sid>move_paragraph(0)<cr>
nnoremap <silent>J <cmd>call <sid>move_paragraph(1)<cr>
xnoremap <silent>J <cmd>call <sid>move_paragraph(1)<cr>

" nnoremap <expr><silent>K '<cmd>keepjumps normal! '.
"   \(<sid>IsLineEmpty() ? '{}k' : <sid>IsLineEmpty(-1) ? 'k{}k' : '{j')."\<cr>"
" xnoremap <expr><silent>K "\<cmd>keepjumps normal! ".
"   \(<sid>IsLineEmpty() ? '{}k' : <sid>IsLineEmpty(-1) ? 'k{}k' : '{j')."\<cr>"

" nnoremap <expr><silent>J '<cmd>keepjumps normal! '.
"   \(<sid>IsLineEmpty() ? '}{j' : <sid>IsLineEmpty(+1) ? 'j}{j' : '}k')."\<cr>"
" xnoremap <expr><silent>J "\<cmd>keepjumps normal! ".
"   \(<sid>IsLineEmpty() ? '}{j' : <sid>IsLineEmpty(+1) ? 'j}{j' : '}k')."\<cr>"

"function! BlockUp() abort
"  if s:IsLineEmpty()
"    keepjumps normal! {}k
"  endif

"  " Maybe enough to ask IsLineEmpy count folds?

"  "If -1 line is empty - just go to it and same jump
"  "But that doesn't work if we are on fold
"  "This may not work if we are on fold
"endfunction

"Handy line start/end
noremap <C-h> _
noremap <C-l> g_

"Handier than ,
nnoremap <M-;> ,

nnoremap <C-g> <cmd>echo nvim_treesitter#statusline(#{indicator_size: &columns })<cr>

"More convinient register selector
nmap q "
xmap q "
nnoremap <M-C-y> <C-y>
nnoremap <M-C-e> <C-e>
xnoremap <M-C-y> <C-y>
xnoremap <M-C-e> <C-e>

"Redraw
nnoremap g_ <C-l>

" nnoremap <silent>gg <cmd>keepjumps normal! gg<cr>
" nnoremap <silent>G <cmd>keepjumps normal! Gzz<cr>
nnoremap <silent>G Gzz

"Paste from vim to system clipboard
nnoremap <silent> <M-y> <cmd>let @+=@" \| let g:ustate.yank_clipboard = 1<cr>
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
nnoremap <leader>zy <cmd>let @+=expand('%').':'.line('.')<cr>
nnoremap <leader>z<M-y> <cmd>let @+=getcwd()<cr>

function! s:YankFileLine() abort
  let @+ = linenr()
endfunction

"No overwrite paste and change
nnoremap c "_c
xnoremap c "_c

nnoremap p ]p
nnoremap P ]P

function! s:PasteOver() abort
  execute 'normal!' '"_d"'.v:register.( col('.')+1==col('$') ? 'p' : 'P')
endfunction
xnoremap p <cmd>call <sid>PasteOver()<cr>

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


nnoremap <silent> <M-u> <cmd>noh<CR>

nnoremap n <cmd>call <sid>Jump('n')<cr>
nnoremap N <cmd>call <sid>Jump('N')<cr>

" function s:NoJump(cmd) abort
function s:Jump(cmd) abort
  try
    " execute 'keepjumps' 'normal!' a:cmd
    execute 'normal!' a:cmd
    if g:uopts.nz
      normal! zz
    endif
  catch /E384/
    call utils#Print('ErrorMsg', 'TOP ', [@/, 'LspDiagnosticsSignInformation'])
  catch /E385/
    call utils#Print('ErrorMsg', 'BOTTOM ', [@/, 'LspDiagnosticsSignInformation'])
  endtry
endfunction

"Wipe buffer or close its window - all via 'q'
nnoremap <silent>Q <cmd>q<cr>
nnoremap <silent><C-q> <cmd>call <SID>Wipe()<cr>

function! s:Wipe()
  let cnr = bufnr()
  "if empty(expand('#'))
  "  q
  "else
  "  if &ft == 'help'
  "    "Try to locate prev help buffer. If no, just wipe this help and close
  "    "the window
  "    let prevNr = cnr
  "    let bufInfos = getbufinfo()
  "    for i in range(len(bufInfos))
  "      let nr = bufInfos[i].bufnr
  "      if nr == cnr
  "        break
  "      endif
  "      if getbufvar(nr, '&ft') == 'help'
  "        if nr < cnr
  "          let prevNr = nr
  "        endif
  "      endif
  "    endfor
  "    "No prev help buffer, wipe this
  "    if prevNr == cnr
  "      bw %
  "    else
  "      execute 'b' prevNr
  "      bw #
  "    endif
  "  else
      if !s:BufJump('NEXT', 1)
        call s:BufJump('PREV', 1)
      endif
      execute 'bwipe' cnr
    " endif
  " endif
endfunction

"Useful before reviewing delta and commit
nnoremap <silent><leader>iub :call utils#ShowUnsavedBuffers()<cr>

"Syntax element under cursor
nnoremap <silent><leader>isn :echo synIDattr(synID(line("."), col("."), 1), "name")<cr>

nnoremap <leader>itl :lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))<cr>

"Global marks are more useful
function! s:RemapMarks() abort
  for i in range(char2nr('a'), char2nr('z'))
    let a = nr2char(i)
    let A = toupper(a)
    execute 'nnoremap' 'm'.a 'm'.A
    execute 'nnoremap' ''''.a ''''.A
    execute 'nnoremap' 'm'.A 'm'.a
    execute 'nnoremap' ''''.A ''''.a
  endfor
endfunction
call s:RemapMarks()

"Terminal normal mode
tnoremap <c-o> <C-\><C-n>

"Easier windows navigation with arrows remapped to 'hjkl' in terminal emulator
nnoremap <Left>  <C-w>h
nnoremap <Down>  <C-w>j
nnoremap <Up>    <C-w>k
nnoremap <Right> <C-w>l

nnoremap <silent><M-H>  <cmd>vertical resize -5<cr>
nnoremap <silent><M-J>  <cmd>         resize -5<cr>
nnoremap <silent><M-K>  <cmd>         resize +5<cr>
nnoremap <silent><M-L>  <cmd>vertical resize +5<cr>

"Jump forward/back in split
" nnoremap <C-w><C-o> <C-w>v<C-o>
" nnoremap <C-w>O <C-w>s<C-o>
" nnoremap <C-w><C-i> <C-w>v<C-i>
" nnoremap <C-w>I <C-w>s<C-i>
"Open window dup in a new tab
nnoremap <C-w>t <C-w>v<C-w>T

"Pair braces and quotes in command line
cnoremap <M-9> ()<left>
cnoremap <M-'> ""<left>
cnoremap <M-[> []<left>
"rem
"Emacs keybindings in insert and command modes
"Line begin-end
inoremap <expr><C-a> getline('.')[0] == ' ' ? "\<Home>\<C-Right>" : "\<Home>"
" inoremap <C-e> <End> this mapped in lsp
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

"Sentence and paragraph motions shouldn't be tossed jump stack
nnoremap <silent>} :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent>{ :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

"Diff buffer with last saved state
" nnoremap <silent><M-f> :DiffOrig<cr>

function! mappings#NopDiff() abort
  " nnoremap <buffer><M-f> <nop>
  nnoremap <buffer><M-d> <nop>
endfunction

"Easier merging
nnoremap <leader>gml <cmd>diffget LOCAL<cr>
nnoremap <leader>gmr <cmd>diffget REMOTE<cr>

"Diff, jump to the next hunk. With default 'c' it may be erroneously changed
nmap [w [czz
nmap ]w ]czz

"Comfy buffer switching
nnoremap <silent> <M-n> <cmd>call <sid>Next()<cr>
nnoremap <silent> <M-p> <cmd>call <sid>Prev()<cr>

function! s:BufJump(dir, quiet = 0) abort
  let [jumps, pos] = getjumplist()
  let current_buf = bufnr()
  let cmd = ''

  function! Oper(a, jmp_item, offset) closure
    let nr = a:jmp_item.bufnr
    "If it is there maybe we should jumpt to it instead of exclude?
    "No, it is <Buf>Jump after all
    if nr != current_buf && bufexists(nr) && getbufvar(nr, '&buftype') == ''
      let a:a[nr] = a:offset
    endif
    return a:a
  endfunction
  ""Max offset of each buffer after current in jumplist
  let after_bufs = utils#Reduce(jumps[pos+1:], function('Oper'), #{})

  if a:dir == 'NEXT' && len(after_bufs) > 0
    let count = min(values(after_bufs))
    let cmd = string(count+1)."\<C-i>"
  elseif a:dir == 'PREV' && pos > 0
    let after_bufs[current_buf] = 0
    " echo after_bufs
    let [_, found] =  utils#FindLast(jumps[:pos-1], {v,_ -> bufexists(v.bufnr) && !has_key(after_bufs, v.bufnr)} )
    if found >= 0
      let cmd = string(pos-found)."\<C-o>"
    endif
  endif
  if cmd != ''
    "Clear 'No buf to jump' message
    execute 'normal!' cmd
    return 1
  else
    if !a:quiet
      call utils#Print('WarningMsg', 'No ', [a:dir, 'LspDiagnosticsSignInformation'], ' buf to jump')
    endif
    return 0
  endif
endfunction

"Use jumps list or record history in ustate instead of dummy bnext bprev
function! s:Next() abort
  if &diff
    keepjumps normal! ]c
    if g:uopts.nz
      normal! zz
    endif
  else
    call s:BufJump('NEXT')
  endif
endfunction

function! s:Prev() abort
  if &diff
    keepjumps normal! [c
    if g:uopts.nz
      normal! zz
    endif
  else
    call s:BufJump('PREV')
  endif
endfunction

"Replace last search pattern, i.e. '/' register content
nnoremap <M-r> :.,$s//<c-r>=utils#GetSearchPatternWithoutFlags()<cr>/gc<left><left><left>
xnoremap <M-r> :s///gc<left><left><left>

function! s:WordMotions() abort
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

  function! s:move_w() abort
    let count = 0
    let ri = s:RightIncl()
    "Cursor pos
    let prevChar = ri[0]
    for i in range(1, len(ri))
      let char = ri[i]
      if prevChar !~ '\k' && char =~ '\k'
        let count += 1
        if count == v:count1
          execute 'normal!' (i).'l'
          return
        endif
      endif
      let prevChar = char
    endfor

    "Jump to the line end if no suitable char found
    normal! g_
  endfunction

  function! s:move_e() abort
    let count = 0
    let re = s:RightExcl()
    "Right after cursor pos
    let prevChar = re[0]
    for i in range(1, len(re))
      let char = re[i]
      if prevChar =~ '\k' && char !~ '\k'
        let count += 1
        if count == v:count1
          "Make inclusive
          let m = mode(1)
          if m == 'no'
            let i = i + 1
          endif
          execute 'normal!' (i).'l'
          return
        endif
      endif
      let prevChar = char
    endfor

    normal! g_
  endfunction

  function! s:move_b() abort
    let count = 0
    let le = s:LeftExcl()
    let ll = len(le)
    "Left before cursor pos
    let nextChar = le[ll-1]
    for i in range(1, ll)
      let char = le[ll-1-i]
      if char !~ '\k' && nextChar =~ '\k'
        let count += 1
        if count == v:count1
          execute 'normal!' (i).'h'
          return
        endif
      endif
      let nextChar = char
    endfor

    normal! _
  endfunction

  function! s:move_ge() abort
    let count = 0
    let li = s:LeftIncl()
    let ll = len(li)
    "Cursor pos
    let nextChar = li[ll-1]
    for i in range(1, ll)
      let char = li[ll-1-i]
      if char =~ '\k' && nextChar !~ '\k'
        let count += 1
        if count == v:count1
          execute 'normal!' (i).'h'
          return
        endif
      endif
      let nextChar = char
    endfor

    normal! _
  endfunction

  nnoremap w <cmd>call <sid>move_w()<cr>
  nnoremap b <cmd>call <sid>move_b()<cr>
  nnoremap e <cmd>call <sid>move_e()<cr>
  nnoremap s <cmd>call <sid>move_ge()<cr>
  xnoremap w <cmd>call <sid>move_w()<cr>
  xnoremap b <cmd>call <sid>move_b()<cr>
  xnoremap e <cmd>call <sid>move_e()<cr>
  xnoremap s <cmd>call <sid>move_ge()<cr>
  onoremap w <cmd>call <sid>move_w()<cr>
  onoremap b <cmd>call <sid>move_b()<cr>
  onoremap e <cmd>call <sid>move_e()<cr>
  onoremap s <cmd>call <sid>move_ge()<cr>

  nnoremap S gE
  xnoremap S gE
  onoremap S gE
endfunction

call s:WordMotions()

"Folds
nnoremap <M-f> za
