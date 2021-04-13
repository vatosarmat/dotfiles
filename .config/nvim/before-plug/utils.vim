function! utils#ShowUnsavedBuffers() abort
  let unsavedBuffers = []
  for buf in getbufinfo({'bufmodified':1})
    if !empty(buf['name']) && empty(getbufvar(buf['bufnr'], '&buftype'))
      call add(unsavedBuffers, [buf['bufnr'], buf['name']])
    endif
  endfor
  if len(unsavedBuffers) > 0
    let leftPad = '    '
    echom 'Unsaved buffers:'
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

function! utils#ListToDictKeys(list, oper, dictInit) abort
  let dictResult = deepcopy(a:dictInit)

  for item in a:list
    let dictResult[item] = a:oper(dictResult , item)
  endfor

  return dictResult
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
