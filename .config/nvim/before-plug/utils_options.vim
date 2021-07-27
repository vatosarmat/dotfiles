let g:utils_options = #{}

let s:utils_flags = #{
  \ nz: 0,
  \ hl: 0,
  \ }

let s:lsp_flags = #{
 \ ldu: 0,
 \ ldv: 0,
 \ laf: 1,
 \ }

function s:MapAllFlags() abort
  for f in keys(s:utils_flags)
    execute 'nnoremap' '<leader>o'.f
      \ printf('<cmd>let g:utils_options.%s=!g:utils_options.%s \| echom "%s ".(g:utils_options.%s ? "SET" : "UNset" )<cr>', f, f, f, f)
  endfor
endfunction

call extend(s:utils_flags, s:lsp_flags)
call extend(g:utils_options, s:utils_flags)
call s:MapAllFlags()

"The options useful when iterating through many similarly highlighted search
"results - Vim unfortunately highlights 'current' result and all the others in
"the same way
"In routine workflow it distracts
nnoremap <silent> <leader>ocl :set cul! cuc!<CR>

let s:scroll_view = 1
function s:ScrollViewToggle() abort
  if s:scroll_view
    ScrollViewDisable
  else
    ScrollViewEnable
  endif
  let s:scroll_view = !s:scroll_view
endfunction
nnoremap <silent> <leader>osv <cmd>call <SID>ScrollViewToggle()<cr>
