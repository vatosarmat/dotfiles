if exists("b:current_syntax")
  finish
endif

syn match functionIcon "" contained
syn region functionItem start="" end="\n" oneline contains=functionIcon
syn match variableIcon "✗" contained
syn region variableItem start="✗" end="\n" oneline contains=variableIcon

hi def link functionItem TSFunction
hi def link functionIcon SymbolIconFunction
hi def link variableItem TSVariable
hi def link variableIcon SymbolIconVariable

let b:current_syntax = "symbol_list"

