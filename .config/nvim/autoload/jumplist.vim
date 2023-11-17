"Motions around Vim built-in jumplist
"w:jumplist_last_buf_jump_dir = NEXT|PREV|MATE
"
" Navigation functions: NextBuf, PrevBuf, AnotherBuf
" They all eventually call BufJump
"
" Variables:
" - w:jumplist_last_buf_jump_dir - for function AnotherBuf
" - w:buffer_skip - make BufJump skip this file


function! jumplist#NextBuf(quiet = 0) abort
  return s:BufJump('NEXT', a:quiet)
endfunction

function! jumplist#PrevBuf(quiet = 0) abort
  return s:BufJump('PREV', a:quiet)
endfunction

function! jumplist#MateBuf(quiet = 0) abort
  let w:jumplist_last_buf_jump_dir = 'MATE'
endfunction

" repeat last move, i.e. move in the same direction
function! jumplist#AnotherBuf(quiet = 0) abort
  if w:jumplist_last_buf_jump_dir == 'MATE'
    lua require 'buffer_navigation'.cycle_mate_bufs()
  else
    "If not moved, change direction
    if !s:BufJump(w:jumplist_last_buf_jump_dir, a:quiet)
      let w:jumplist_last_buf_jump_dir = w:jumplist_last_buf_jump_dir == 'NEXP' ? 'PREV' : 'NEXT'
      call s:BufJump(w:jumplist_last_buf_jump_dir, a:quiet)
    endif
  endif
endfunction

" skip this buf, jump to another one
function! jumplist#Exclude(buf_name = 0) abort
  "exclude file by name
  if a:buf_name
    let w:buffer_skip[a:buf_name] = 1
  else
    "exclude currently opened file
    if getbufvar(bufnr(), '&buftype') == ''
      let buf_name = expand('%:p')
      let w:buffer_skip[buf_name] = 1
      call jumplist#AnotherBuf()
    endif
  endif
endfunction

" Init w: variables
" remove buffer from skip list if it is opened
function! jumplist#BufWinEnter() abort
  if !exists('w:buffer_skip')
    let w:buffer_skip = #{}
    let w:jumplist_last_buf_jump_dir = 'PREV'
    clearjumps
  endif

  let buf_name = expand('%:p')
  if has_key(w:buffer_skip, buf_name)
    call remove(w:buffer_skip, buf_name)
  endif
endfunction

"This literally just executes <C-i> or <C-o> for the amount of times required
"to get the farthest next or the nearest prev, skipping buffer_skip
function! s:BufJump(dir, quiet = 0) abort
  let [jumps, pos] = getjumplist()
  let current_buf = bufnr()
  let cmd = ''

  "Buffer exists, it is a file, it is not in skiplist
  function! IsJumpable(bnr)
    return bufexists(a:bnr) &&
      \ getbufvar(a:bnr, '&buftype') == '' &&
      \ !has_key(w:buffer_skip, fnamemodify(bufname(a:bnr), ':p'))
  endfunction

  function! Farthest(a, jmp_item, offset) closure
    let nr = a:jmp_item.bufnr
    if nr != current_buf && IsJumpable(nr)
      "
      let a:a[nr] = a:offset
    endif
    return a:a
  endfunction
  "Farthest offset of each buffer after the pos in the jumplist
  "@type - Record<bufnr, farthest offset in jumplist relative to pos>
  let after_bufs = utils#Reduce(jumps[pos+1:], function('Farthest'), #{})

  if a:dir == 'NEXT' && len(after_bufs) > 0
    "to the closest buf, i.e. closest position among the buf-farthest positions
    let count = min(values(after_bufs))
    let cmd = string(count+1)."\<C-i>"
  elseif a:dir == 'PREV' && pos > 0
    let after_bufs[current_buf] = 0
    "to the closest buf which doesn't appear after
    let [_, found] = utils#FindLast(jumps[:pos-1], {v,_ -> IsJumpable(v.bufnr) && !has_key(after_bufs, v.bufnr)} )
    if found >= 0
      let cmd = string(pos-found)."\<C-o>"
    endif
  endif

  if cmd != ''
    "Clear 'No buf to jump' message
    execute 'normal!' cmd
    let w:jumplist_last_buf_jump_dir = a:dir
    return 1
  else
    if !a:quiet
      call utils#Print('WarningMsg', 'No ', [a:dir, 'LspDiagnosticsSignInformation'], ' buf to jump')
    endif
    return 0
  endif
endfunction
