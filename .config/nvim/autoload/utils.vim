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
  for item in a:array
    let accum = a:oper(accum, item)
  endfor

  return accum
endfunction

function! utils#Find(array, cb) abort
  for i in range(len(a:array))
    let v = a:array[i]
    if a:cb(v, i)
      return [v, i]
    endif
  endfor

  return [0, -1]
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

