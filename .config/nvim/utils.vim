function! DotfilesShowUnsavedBuffers() abort
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
