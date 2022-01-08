syn clear qfSeparator
syn match	qfSeparator	"|"

let s:symbol_icons = luaeval('service.lsp.symbol_icons')

function! s:SymbolItem(kind, iconHl, nameHl, detailHl = 'Normal') abort
  let icon = s:symbol_icons[toupper(a:kind[0]).a:kind[1:]]
  let iconPat = printf('"\(| \)\@<=%s"', icon)
  let namePat = printf('"\(| %s\)\@<=\s\+\S\+"', icon)
  let nameSyn = a:kind.'Name'
  let detailSyn = a:kind.'Detail'

  execute
    \ 'syn' 'region' detailSyn
    \ 'matchgroup='.a:iconHl 'start='.iconPat 'end="$"'
    \ 'oneline' 'contains='.nameSyn 'keepend'

  execute 'syn' 'match' nameSyn namePat
  execute 'hi' 'def' 'link' nameSyn a:nameHl
  execute 'hi' 'def' 'link' detailSyn a:detailHl
endfunction

" syn match functionIcon "\(| \)\@<=F"
" syn region functionDetail matchgroup=SymbolIconFunction start="\(| \)\@<=F" end="$" oneline contains=functionName keepend
" syn match functionName "\(| F\)\@<=\s\+\S\+"
" hi def link functionName TSFunction
" hi def link functionDetail Normal

call s:SymbolItem('function', 'SymbolIconFunction', 'TSMethod', 'TSType')
call s:SymbolItem('method', 'SymbolIconFunction', 'TSFunction', 'TSType')
call s:SymbolItem('constructor', 'SymbolIconFunction', 'TSConstructor', 'TSType')

call s:SymbolItem('variable', 'SymbolIconVariable', 'TSVariable', 'TSType')
call s:SymbolItem('constant', 'SymbolIconVariable', 'TSVariable', 'TSType')
call s:SymbolItem('property', 'SymbolIconVariable', 'TSProperty', 'TSType')
call s:SymbolItem('field', 'SymbolIconVariable', 'TSField', 'TSType')
call s:SymbolItem('enumMember', 'SymbolIconVariable', 'TSProperty')

call s:SymbolItem('namespace', 'SymbolIconClass', 'TSNamespace')
call s:SymbolItem('interface', 'SymbolIconClass', 'TSType')
call s:SymbolItem('class', 'SymbolIconClass', 'TSType', 'TSKeyword')
call s:SymbolItem('struct', 'SymbolIconClass', 'TSType', 'TSKeyword')
call s:SymbolItem('object', 'SymbolIconClass', 'TSType', 'TSKeyword')
call s:SymbolItem('enum', 'SymbolIconClass', 'TSType', 'TSKeyword')

hi! def link qfSeparator LineNr
