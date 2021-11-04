let g:uopts = #{
  \ print_duration: 2000,
  \ }

"sv
"cl
let s:util_flags = #{
  \ nz: 0,
  \ hl: 1,
  \ }
" fe: 0,

let s:lsp_flags = #{
 \ ldu: 0,
 \ ldv: 0,
 \ laf: 1,
 \ }

function uopts#toggle(flag) abort
  let g:uopts[a:flag] = !g:uopts[a:flag]
  echom a:flag.' '.(g:uopts[a:flag] ? 'SET' : 'UNset')
endfunction

function s:MapAllFlags() abort
  for f in keys(s:util_flags)
    execute 'nnoremap' '<leader>o'.f
      \ printf('<cmd>call uopts#toggle("%s")<cr>', f)
  endfor
endfunction

call extend(s:util_flags, s:lsp_flags)
call extend(g:uopts, s:util_flags)
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