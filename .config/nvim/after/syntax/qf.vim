if get(get(b:,'loclist_context', #{}), 'type', -1) != 'symbol_list'
  finish
end

syn clear qfSeparator
syn match	qfSeparator	"|"

let s:lsp_ui_symbol = luaeval('_U.lsp.ui.symbol')

"syn-group for has_children-icon
execute 'syn' 'match' 'qfHasChildren' '"'.s:lsp_ui_symbol['has_children']['icon'].'"'

function! s:SymbolItem(kind) abort
  let item = s:lsp_ui_symbol[a:kind]
  " let iconPat = printf('"\(| \)\@<=%s"', item.icon)
  " let namePat = printf('"\(| %s\)\@<=\s\+\S\+"', item.icon)
  " Icon in the beginning of the line
  let iconPat = printf('"^%s"', item.icon)
  " non-space stuff that comes after icon and 1+ space
  let namePat = printf('"%s\@<=\s\+\S\+"', item.icon)
  let nameSyn = a:kind.'Name'
  let detailSyn = a:kind.'Detail'

  "syn-groupd for whole line except nameSyn and has_children-icon
  execute
    \ 'syn' 'region' detailSyn
    \ 'matchgroup='.item['hl_icon'] 'start='.iconPat 'end="$"'
    \ 'oneline' 'contains='.nameSyn.',qfHasChildren' 'keepend'

  "syn-group for nameSyn
  execute 'syn' 'match' nameSyn namePat

  execute 'hi!' 'def' 'link' nameSyn item['hl_name']
  execute 'hi!' 'def' 'link' detailSyn has_key(item, 'hl_detail') ? item['hl_detail'] : 'Normal'

  "Get 'fg' from hl_xxx, 'bg' from StatusLine
  execute 'hi!' 'StatusLine'.item['hl_icon']
    \ 'guifg='.utils#GetHlAttr(item['hl_icon'], 'fg')
    \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

  execute 'hi!' 'StatusLine'.item['hl_name']
    \ 'guifg='.utils#GetHlAttr(item['hl_name'], 'fg')
    \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

  execute 'hi!' 'StatusLineNC'.item['hl_icon']
    \ 'guifg='.utils#GetHlAttr(item['hl_icon'], 'fg')
    \ 'guibg='.utils#GetHlAttr('StatusLineNC', 'bg')

  execute 'hi!' 'StatusLineNC'.item['hl_name']
    \ 'guifg='.utils#GetHlAttr(item['hl_name'], 'fg')
    \ 'guibg='.utils#GetHlAttr('StatusLineNC', 'bg')
endfunction

" syn match functionIcon "\(| \)\@<=F"
" syn region functionDetail matchgroup=SymbolIconFunction start="\(| \)\@<=F" end="$" oneline contains=functionName keepend
" syn match functionName "\(| F\)\@<=\s\+\S\+"
" hi def link functionName TSFunction
" hi def link functionDetail Normal

call s:SymbolItem('Function')
call s:SymbolItem('Method')
call s:SymbolItem('Constructor')

call s:SymbolItem('Variable')
call s:SymbolItem('Constant')
call s:SymbolItem('Property')
call s:SymbolItem('Field')
call s:SymbolItem('EnumMember')

call s:SymbolItem('Module')
call s:SymbolItem('Namespace')
call s:SymbolItem('Interface')
call s:SymbolItem('Class')
call s:SymbolItem('Struct')
call s:SymbolItem('Object')
call s:SymbolItem('Enum')
call s:SymbolItem('TypeParameter')

hi! def link qfSeparator LineNr
hi! qfHasChildren guifg=#3bc03d
