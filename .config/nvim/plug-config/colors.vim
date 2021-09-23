colorscheme nvcode

hi StatusLine guifg=#abb2bf ctermfg=249 guibg=#000000 ctermbg=236 gui=NONE cterm=NONE
hi StatusLineNC guifg=#5c6370 ctermfg=241 guibg=#191919 ctermbg=NONE gui=NONE cterm=NONE
hi! link Folded Normal

"Error
hi! LspDiagnosticsVirtualTextError guifg=#f44747
hi! link LspDiagnosticsFloatingError LspDiagnosticsVirtualTextError
hi! LspDiagnosticsSignError guifg=#f41d1d
hi! link NvimTreeLspDiagnosticsError LspDiagnosticsSignError
"Warning
hi! link NvimTreeLspDiagnosticsWarning LspDiagnosticsSignWarning
"Information
hi! LspDiagnosticsVirtualTextInformation guifg=#4fc1ff
hi! link LspDiagnosticsSignInformation LspDiagnosticsVirtualTextInformation
hi! link LspDiagnosticsFloatingInformation LspDiagnosticsVirtualTextInformation
hi! link NvimTreeLspDiagnosticsInformation LspDiagnosticsSignInformation
"Hint
hi! LspDiagnosticsVirtualTextHint guifg=#3bc03d
hi! link LspDiagnosticsSignHint LspDiagnosticsVirtualTextHint
hi! link LspDiagnosticsFloatingHint LspDiagnosticsVirtualTextHint
hi! link NvimTreeLspDiagnosticsHint LspDiagnosticsSignHint

execute 'highlight!' 'User1'
  \ 'guifg='.utils#GetHlAttr('LspDiagnosticsSignError', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User2'
  \ 'guifg='.utils#GetHlAttr('LspDiagnosticsSignWarning', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User3'
  \ 'guifg='.utils#GetHlAttr('LspDiagnosticsSignInformation', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')
execute 'highlight!' 'User4'
  \ 'guifg='.utils#GetHlAttr('LspDiagnosticsSignHint', 'fg')
  \ 'guibg='.utils#GetHlAttr('StatusLine', 'bg')

hi! link TSTypeBuiltin TSType
hi! link CocErrorSign LspDiagnosticsSignError
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
