syn clear qfSeparator
syn match	qfSeparator	"|"

syn match functionIcon "\(| \)\@<=F" containedin=functionItem
syn region functionItem start="\(| \)\@<=F" end="$" oneline contains=functionIcon keepend
syn match variableIcon "\(| \)\@<=V" containedin=variableItem
syn region variableItem start="\(| \)\@<=V" end="$" oneline contains=variableIcon keepend
syn match constantIcon "\(| \)\@<=C" containedin=constantItem
syn region constantItem start="\(| \)\@<=C" end="$" oneline contains=constantIcon keepend
syn match propertyIcon "\(| \)\@<=P" containedin=propertyItem
syn region propertyItem start="\(| \)\@<=P" end="$" oneline contains=propertyIcon keepend
syn match classIcon "\(| \)\@<=" containedin=classItem
syn region classItem start="\(| \)\@<=" end="$" oneline contains=classIcon keepend
syn match interfaceIcon "\(| \)\@<=I" containedin=interfaceItem
syn region interfaceItem start="\(| \)\@<=I" end="$" oneline contains=interfaceIcon keepend

hi def link functionItem TSFunction
hi def link functionIcon SymbolIconFunction
hi def link variableItem TSVariable
hi def link variableIcon SymbolIconVariable
hi def link constantItem TSVariable
hi def link constantIcon SymbolIconConstant
hi def link propertyItem TSProperty
hi def link propertyIcon SymbolIconProperty
hi def link classItem TSType
hi def link classIcon SymbolIconClass
hi def link interfaceItem TSType
hi def link interfaceIcon SymbolIconInterface

hi! def link qfSeparator LineNr
