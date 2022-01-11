function! utils#ShowUnsavedBuffers() abort
  let unsavedBuffers = []
  for buf in getbufinfo({'bufmodified':1})
    if !empty(buf['name']) && empty(getbufvar(buf['bufnr'], '&buftype'))
      call add(unsavedBuffers, [buf['bufnr'], buf['name']])
    endif
  endfor
  if len(unsavedBuffers) > 0
    let leftPad = '    '
    echohl ErrorMsg
    echom 'Unsaved buffers:'
    echohl None
    for [nr,name] in unsavedBuffers
      echom leftPad.nr.' '.name
    endfor
  else
    echom 'All buffers saved'
  endif
endfunction

function! utils#Reduce(array, oper, accumInit) abort
  let accum = a:accumInit
  let i = 0
  let l = len(a:array)
  while i < l
    let accum = a:oper(accum, a:array[i], i)
    let i += 1
  endwhile
  return accum
endfunction

function! utils#Find(array, pred) abort
  let i = 0
  let l = len(a:array)
  while i < l
    let v = a:array[i]
    if a:pred(v, i)
      return [v, i]
    endif
    let i += 1
  endwhile

  return [0, -1]
endfunction

function! utils#FindLast(array, pred) abort
  let l = len(a:array)
  let i = l - 1
  while i >= 0
    let v = a:array[i]
    if a:pred(v, i)
      return [v, i]
    endif
    let i -= 1
  endwhile

  return [0, -1]
endfunction

function! utils#Min(array, cmp) abort
  let ret = [a:array[0], 0]
  let i = 1
  let l = len(a:array)
  while i < l
    let v = a:array[i]
    if cmp(v, ret)
      ret = [v,i]
    endif
    let i+=1
  endwhile
  return ret
endfunction

function! utils#MatchStrAll(str, pat) abort
  let l:res = []
  call substitute(a:str, a:pat, '\=add(l:res, submatch(0))', 'g')
  return l:res
endfunction

function! utils#ListToDictKeys(list, oper, dictInit) abort
  let dictResult = deepcopy(a:dictInit)

  for item in a:list
    let dictResult[item] = a:oper(dictResult , item)
  endfor

  return dictResult
endfunction

function! utils#GetSearchPatternWithoutFlags() abort
  return matchlist(@/, '\v^%(\\V|\\v|\\\<){,2}(.{-})%(\\\>)?$')[1]
endfunction

function! utils#GetCursorChar() abort
  return getline('.')[col('.') - 1]
endfunction

function! utils#GetCursorOff() abort
  return line2byte(line('.')) + col('.') - 2
endfunction

function! utils#GetHlAttr(hl, attr) abort
  return synIDattr(synIDtrans(hlID(a:hl)), a:attr, 'gui')
endfunction

let g:utils#color8 = #{
  \ black: "\e[30m",
  \ red: "\e[31m",
  \ green: "\e[32m",
  \ yellow: "\e[33m",
  \ blue: "\e[34m",
  \ magenta: "\e[35m",
  \ cyan: "\e[36m",
  \ white: "\e[37m",
  \ }

let g:utils#color_reset = "\e[m"

function! utils#Cnoreabbrev(from, to) abort
  function! s:ExpandAbbrev(lhs, rhs) abort
    return getcmdtype() == ':' && getcmdline() == a:lhs ? a:rhs : a:lhs
  endfunction
  execute 'cnoreabbrev' '<expr>' a:from printf('<sid>ExpandAbbrev(''%s'', ''%s'')',a:from, a:to )
endfunction

function! utils#Print(dflt, ...) abort
  for chunk in a:000
    let tp = type(chunk)
    if tp == v:t_list
      let [str,hl] = chunk
      execute 'echohl' hl
      echon str
    elseif tp == v:t_string
      execute 'echohl' a:dflt
      echon chunk
    else
      echoerr 'Invalid chunk type: '.tp
    endif
  endfor
  echohl None

  function! Clear(tid) closure
    echo
  endfunction

  call timer_stop(g:ustate.print_clear_timer)
  let g:ustate.print_clear_timer = timer_start(g:UOPTS.print_duration, function('Clear'))
endfunction

function! utils#Warning(...) abort
  call call(function('utils#Print'), insert(deepcopy(a:000), 'WarningMsg'))
endfunction

function! utils#Error(...) abort
  call call(function('utils#Print'), insert(deepcopy(a:000), 'ErrorMsg'))
endfunction

function! utils#LineCol() abort
  let [b,l,c,o,w] = getcurpos()
  return [l, c]
endfunction

function! utils#TrimBufLines() abort
  if g:UOPTS.laf
    let save_cursor = getpos(".")
    keeppatterns keepjumps %s/\s\+$//e
    call setpos('.', save_cursor)
  endif
endfun

function! utils#IsLineEmpty(line) abort
  return getline(a:line) !~ '\S'
endfunction
