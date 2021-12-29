function! s:Foo() abort
  function! Handler(...) abort
    let lc = utils#LineCol()
    if b:lsp_definition_pos == lc
      lclose
    endif
    unlet b:lsp_definition_pos
  endfunction
  if exists('b:lsp_definition_timer')
    call timer_stop(b:lsp_definition_timer)
  endif
  let b:lsp_definition_timer = timer_start(1, function('Handler'))
endfunction

function! lsp#DefinitionList(items) abort

  call setloclist(0, [], ' ', #{
    \title: 'Definitions',
    \items: a:items
    \})

  lopen
  wincmd p

  try
    lbefore
  catch /E553/
    try
      lafter
    catch /E553/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      lfirst
    endtry
  catch /E42/
    try
      lafter
    catch /E553/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      lfirst
    catch /E42/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      lfirst
    endtry
  endtry

endfunction

function! lsp#SymbolList() abort
  lopen
  wincmd p
  try
    lbefore
  catch /E42/
    try
      lafter
    catch /E42/
    endtry
  endtry
endfunction
