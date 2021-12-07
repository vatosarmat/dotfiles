colorscheme nvcode

hi StatusLine guifg=#abb2bf ctermfg=249 guibg=#000000 ctermbg=236 gui=NONE cterm=NONE
hi StatusLineNC guifg=#5c6370 ctermfg=241 guibg=#191919 ctermbg=NONE gui=NONE cterm=NONE
hi! link Folded Normal

"Error
hi! DiagnosticVirtualTextError guifg=#a01212
hi! DiagnosticFloatingError    guifg=#f44747
hi! DiagnosticSignError        guifg=#f41d1d

hi! link NvimTreeLspDiagnosticsError DiagnosticSignError
"Warn
hi! DiagnosticVirtualTextWarn guifg=#a05200
hi! DiagnosticFloatingWarn    guifg=#ff8800
hi! DiagnosticSignWarn        guifg=#ff8800

hi! link NvimTreeLspDiagnosticsWarning DiagnosticSignWarn
"Information
hi! DiagnosticVirtualTextInfo guifg=#4fc1ff
hi! DiagnosticFloatingInfo    guifg=#4fc1ff
hi! DiagnosticSignInfo        guifg=#4fc1ff

hi! link NvimTreeLspDiagnosticsInfo DiagnosticSignInfo
"Hint
hi! DiagnosticVirtualTextHint guifg=#3bc03d
hi! DiagnosticFloatingHint    guifg=#3bc03d
hi! DiagnosticSignHint        guifg=#3bc03d

hi! link NvimTreeLspDiagnosticsHint DiagnosticSignHint

execute 'highlight!' 'User1'
  \ 'guifg='.utils#GetHlAttr('DiagnosticSignError', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User2'
  \ 'guifg='.utils#GetHlAttr('DiagnosticSignWarn', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User3'
  \ 'guifg='.utils#GetHlAttr('DiagnosticSignInfo', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User4'
  \ 'guifg='.utils#GetHlAttr('DiagnosticSignHint', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

hi LspReferenceText guibg=#3a3a3a
hi LspReferenceRead guibg=#304030
hi LspReferenceWrite guibg=#502842

hi! link TSTypeBuiltin TSType
hi! link CocErrorSign DiagnosticSignError
hi Pmenu guifg=#e6eeff
hi Comment gui=NONE cterm=NONE
hi Special gui=NONE cterm=NONE
hi CursorColumn guibg=#2b2b2b
hi CursorLine guibg=#2b2b2b
hi Visual guibg=#264f78
hi Search guibg=#613214
hi CocHighlightText guibg=#3a3a3a
hi YankHighlight guibg=#1d3a3a

hi DiffAdd guifg=NONE guibg=#151e00
hi DiffDelete guifg=NONE guibg=#101010
hi DiffChange guifg=NONE gui=NONE guibg=#01181e
hi DiffText guifg=NONE guibg=#1e0000
hi DiffConflictMarker guibg=#666666 guifg=#000000

hi ScrollView guibg=#000000

"For git signs
execute 'highlight!' 'User5' 'guifg=#727c5d' 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User6' 'guifg=#76959d' 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User7' 'guifg=#946f71' 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

hi DapBreakpointLine guibg=#100010
hi DapBreakpointSign guifg=#d098f4
hi DapStoppedLine guibg=#400040
hi DapStoppedSign guifg=#9e1cf4
execute 'highlight!' 'User8'
  \ 'guifg='.utils#GetHlAttr('DapStoppedSign', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

"Symbol_list
hi SymbolIconFunction guifg=#c0c000
hi SymbolIconVariable guifg=#0080c0
hi SymbolIconClass guifg=#008064

hi! link NvimTreeIndentMarker Normal
