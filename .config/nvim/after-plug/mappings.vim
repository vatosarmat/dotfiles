
noremap X J

"zt and zb are inconvinient
nnoremap <M-[> zt
nnoremap <M-i> zz
nnoremap <M-]> zb

"quickfix list mappings
nnoremap q <cmd>cnext<cr>
nnoremap <M-q> <cmd>cprevious<cr>

nnoremap ]t gt
nnoremap [t gT

"Macro, <Home> is C-m
nnoremap g<Home> q

"Handy block movement
nnoremap <expr><silent>K '<cmd>keepjumps normal! '.
  \(<sid>IsLineEmpty() ? '{}k' : <sid>IsLineEmpty(-1) ? 'k{}k' : '{j')."\<cr>"
xnoremap <expr><silent>K "\<cmd>keepjumps normal! ".
  \(<sid>IsLineEmpty() ? '{}k' : <sid>IsLineEmpty(-1) ? 'k{}k' : '{j')."\<cr>"
nnoremap <expr><silent>J '<cmd>keepjumps normal! '.
  \(<sid>IsLineEmpty() ? '}{j' : <sid>IsLineEmpty(+1) ? 'j}{j' : '}k')."\<cr>"
xnoremap <expr><silent>J "\<cmd>keepjumps normal! ".
  \(<sid>IsLineEmpty() ? '}{j' : <sid>IsLineEmpty(+1) ? 'j}{j' : '}k')."\<cr>"

"Handy line start/end
noremap <C-h> _
noremap <C-l> g_

"Handier than ,
nnoremap <M-;> ,

"More convinient register selector
nmap <C-y> "
xmap <C-y> "
nnoremap <M-C-y> <C-y>
nnoremap <M-C-e> <C-e>
xnoremap <M-C-y> <C-y>
xnoremap <M-C-e> <C-e>

"Redraw
nnoremap g_ <C-l>

nnoremap <silent>gg <cmd>keepjumps normal! gg<cr>
"When writing file from top to bottom it is more comfortable to have
"new lines appering in the middle of the screen
nnoremap <silent>G <cmd>keepjumps normal! Gzz<cr>


"Paste from vim to system clipboard
nnoremap <silent> <M-y> <cmd>let @+=@" \| let g:utils_options.yc = 1<cr>
nnoremap <M-C-y> <cmd>call <sid>ToggleRegtype()<cr>
function! s:ToggleRegtype() abort
  let urt = getregtype('"')
  if urt ==# 'v'
    call setreg('"', @", 'V')
  elseif urt ==# 'V'
    call setreg('"', @"[:-2], 'v')
  endif
endfunction

"Save file like in all other programs
nnoremap <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>

"yy - for string, Y - for rest of string, same with 'c' and 'd'
nnoremap Y y$

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


"Line in 'less' utility
nnoremap <silent> <M-u> :noh<CR>

nnoremap <expr> n g:utils_options.nz ? 'nzz' : 'n'
nnoremap <expr> N g:utils_options.nz ? 'Nzz' : 'N'

"Wipe buffer or close its window - all via 'q'
nnoremap <silent>Q <cmd>q<cr>
nnoremap <silent><C-q> <cmd>call <SID>Wipe()<cr>

function! s:Wipe()
  if empty(expand('#'))
    q
  else
    if &ft == 'help'
      "Try to locate prev help buffer. If no, just wipe this help and close
      "the window
      let cnr = bufnr()
      let prevNr = cnr
      let bufInfos = getbufinfo()
      for i in range(len(bufInfos))
        let nr = bufInfos[i].bufnr
        if nr == cnr
          break
        endif
        if getbufvar(nr, '&ft') == 'help'
          if nr < cnr
            let prevNr = nr
          endif
        endif
      endfor
      "No prev help buffer, wipe this
      if prevNr == cnr
        bw %
      else
        execute 'b' prevNr
        bw #
      endif
    else
      bp
      bw #
    endif
  endif
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

nnoremap <silent><M-C-h>  <cmd>vertical resize -5<cr>
nnoremap <silent><M-C-j>  <cmd>         resize -5<cr>
nnoremap <silent><M-C-k>  <cmd>         resize +5<cr>
nnoremap <silent><M-C-l>  <cmd>vertical resize +5<cr>

"Jump forward/back in split
nnoremap <C-w><C-o> <C-w>v<C-o>
nnoremap <C-w>O <C-w>s<C-o>
nnoremap <C-w><C-i> <C-w>v<C-i>
nnoremap <C-w>I <C-w>s<C-i>

"Pair braces and quotes in command line
cnoremap <M-9> ()<left>
cnoremap <M-'> ""<left>
cnoremap <M-[> []<left>
"rem
"Emacs keybindings in insert and command modes
"Line begin-end
inoremap <expr><C-a> getline('.')[0] == ' ' ? "\<Home>\<C-Right>" : "\<Home>"
inoremap <expr><C-e> pumvisible() ? "\<C-e>": "\<End>"
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
nnoremap <silent><M-f> :DiffOrig<cr>

function! mappings#NopDiff() abort
  nnoremap <buffer><M-f> <nop>
  nnoremap <buffer><M-d> <nop>
endfunction

"Easier merging
nnoremap <leader>gml <cmd>diffget LOCAL<cr>
nnoremap <leader>gmr <cmd>diffget REMOTE<cr>

"Diff, jump to the next hunk. With default 'c' it may be erroneously changed
nmap [w [czz
nmap ]w ]czz

"Comfy buffer switching
nnoremap <expr><silent> <M-n> &diff ? ":keepjumps norm ]c\<cr>" : ":bn\<cr>"
nnoremap <expr><silent> <M-p> &diff ? ":keepjumps norm [c\<cr>" : ":bp\<cr>"

"Replace last search pattern, i.e. '/' register content
nnoremap <M-r> :.,$s//<c-r>=utils#GetSearchPatternWithoutFlags()<cr>/gc<left><left><left>
xnoremap <M-r> :s///gc<left><left><left>

function! s:IsLineEmpty(...) abort
  return getline(line('.') + get(a:, '1', 0)) !~ '\S'
endfunction

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

  noremap w <cmd>call <sid>move_w()<cr>
  noremap b <cmd>call <sid>move_b()<cr>
  noremap e <cmd>call <sid>move_e()<cr>
  noremap s <cmd>call <sid>move_ge()<cr>

  noremap S gE
endfunction

call s:WordMotions()
