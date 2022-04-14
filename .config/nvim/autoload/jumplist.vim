


function! jumplist#InitWindow() abort
  let w:jumplist_exclude = #{}
  let w:jumplist_last_buf_jump_dir = 'PREV'
  clearjumps
endfunction

function! jumplist#NextBuf(quiet = 0) abort
  return s:BufJump('NEXT', a:quiet)
endfunction

function! jumplist#PrevBuf(quiet = 0) abort
  return s:BufJump('PREV', a:quiet)
endfunction

function! jumplist#AnotherBuf(quiet = 0) abort
  if !s:BufJump(w:jumplist_last_buf_jump_dir, a:quiet)
    let w:jumplist_last_buf_jump_dir = a:dir == 'NEXP' ? 'PREV' : 'NEXT'
    call s:BufJump(w:jumplist_last_buf_jump_dir, a:quiet)
  endif
endfunction

function! jumplist#Exclude() abort
  let bnr = bufnr()

  call jumplist#AnotherBuf()

  if getbufvar(bnr, '&buftype') == ''
    let w:jumplist_exclude[bnr] = 1
  endif
endfunction

function! jumplist#BufWinEnter() abort
  if !exists('w:jumplist_exclude')
    call jumplist#InitWindow()
  endif

  let bnr = bufnr()
  if has_key(w:jumplist_exclude, bnr)
    call remove(w:jumplist_exclude, bnr)
  endif
endfunction

function! s:BufJump(dir, quiet = 0) abort
  let [jumps, pos] = getjumplist()
  let current_buf = bufnr()
  let cmd = ''

  function! IsJumpable(bnr)
    return bufexists(a:bnr) &&
      \ getbufvar(a:bnr, '&buftype') == '' &&
      \ !has_key(w:jumplist_exclude, a:bnr)
  endfunction

  function! Fatherst(a, jmp_item, offset) closure
    let nr = a:jmp_item.bufnr
    if nr != current_buf && IsJumpable(nr)
      "
      let a:a[nr] = a:offset
    endif
    return a:a
  endfunction
  "Farthest offset of each buffer after the pos in the jumplist
  let after_bufs = utils#Reduce(jumps[pos+1:], function('Fatherst'), #{})

  if a:dir == 'NEXT' && len(after_bufs) > 0
    "to the closest buf
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
