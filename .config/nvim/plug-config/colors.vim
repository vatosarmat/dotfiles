colorscheme nvcode

" hi! Normal guifg=#c5c8c6 guibg=#1e1e1e

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
hi! DiagnosticVirtualTextInfo guifg=#276180
hi! DiagnosticFloatingInfo    guifg=#4fc1ff
hi! DiagnosticSignInfo        guifg=#4fc1ff

hi! link NvimTreeLspDiagnosticsInfo DiagnosticSignInfo
"Hint
hi! DiagnosticVirtualTextHint guifg=#278027
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

hi! link CocErrorSign DiagnosticSignError
hi Pmenu guifg=#e6eeff
hi Comment gui=NONE cterm=NONE
hi Special gui=NONE cterm=NONE
hi CursorColumn guibg=#2b2b2b
hi CursorLine guibg=#2b2b2b
hi Visual guibg=#264f78
hi Search guibg=#613214
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

hi! QuickFixLine guibg=#3a3a3a

highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4

hi! link UfoFoldedBg CursorLine

"Normal text
hi! link TSText Normal
hi! TSStrong guifg=#e6eeff
hi! TSEmphasis guifg=#e6eeff
hi! TSTitle guifg=#e6eeff

"Just repeat with nocombine
hi! TSConstBuiltin guifg=#569cd6 gui=NONE,nocombine

"Just use non-builtin
hi! link TSTypeBuiltin TSType

"""""
"""""My improvements
"""""
hi! TSOperator guifg=#c5c8c6
hi! link TSPunctBracket TSOperator
hi! link TSPunctSpecial TSOperator
"Quotes are lang operators, not part of string
hi! link UPunctQuote TSPunctBracket
"
" hi! TSProperty guifg=#8fd1cc
hi! TSProperty guifg=#8abeb7
hi! TSAttribute guifg=#b9ca4a
" hi TSAttribute guibg=NONE guifg=#d7ba7d

"Braces. Better than rainbow
hi! UDeclarationBrace guifg=#4bc3ff
hi! UPatternBrace guifg=#c552c5
hi! UCallBrace guifg=#dc7c40
hi! USubscriptBrace guifg=#85b65f

"Keep colors, just add italic
hi! TSVariableBuiltin guifg=#9cdcfe gui=italic
hi! TSFuncBuiltin guifg=#dcdcaa gui=italic


