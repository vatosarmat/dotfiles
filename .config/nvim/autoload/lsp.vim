function! s:Foo() abort
  function! Handler(...) abort
    let lc = utils#LineCol()
    if b:lsp_definition_pos == lc
      cclose
    endif
    unlet b:lsp_definition_pos
  endfunction
  if exists('b:lsp_definition_timer')
    call timer_stop(b:lsp_definition_timer)
  endif
  let b:lsp_definition_timer = timer_start(1, function('Handler'))
endfunction

function! lsp#DefinitionList(items) abort

  call setqflist([], ' ', #{
    \title: 'Definitions',
    \items: a:items
    \})

  copen
  wincmd p

  try
    cbefore
  catch /E553/
    try
      cafter
    catch /E553/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      cfirst
    endtry
  catch /E42/
    try
      cafter
    catch /E553/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      cfirst
    catch /E42/
      let b:lsp_definition_pos = utils#LineCol()
      autocmd BufWinEnter <buffer> ++once call s:Foo()
      cfirst
    endtry
  endtry

endfunction

function! lsp#SymbolListOpen(path) abort
  if g:UOPTS.lsl
    lopen
    let w:symbol_navigation_path = a:path
    wincmd p
  endif
endfunction

function! lsp#Lbefore() abort
  try
    lbefore
  catch /E42\|E553/
    lafter
  endtry
endfunction

function! lsp#Lafter() abort
  try
    lafter
  catch /E42\|E553/
    lbefore
  endtry
endfunction

