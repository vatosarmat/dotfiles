let g:coc_global_extensions = ['coc-json', 'coc-flow', 'coc-vimlsp', 'coc-marketplace',
  \'coc-pairs', 'coc-explorer', 'coc-prettier', 'coc-snippets', 'coc-clangd',
  \'coc-tsserver', 'coc-eslint', 'coc-python',
  \'coc-sh', 'coc-diagnostic', 'coc-go', 'coc-rust-analyzer']

"Various 'go to' actions
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"Function and clss text objects for operator and visual modes
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

"If has hover provider, doHover; otherwise - default 'K' 'man'
nnoremap <silent> <C-j> :call <sid>HoverOrMan()<CR>

"Move default 'K' 'man' under the \
nnoremap <silent><leader>K <cmd>normal! K <CR>

"CoC outline is not much useful, better use something like Vista.vim
nnoremap <silent><leader>cco <cmd>CocList --normal --no-quit outline<cr>
nnoremap <silent><leader><M-h> <cmd>CocFzfList outline<cr>

"Diagnostics list
nnoremap <silent><leader>cld <cmd>CocList diagnostics<cr>
nmap <leader>cf <Plug>(coc-fix-current)

"Symbol rename
nmap <leader>cr <Plug>(coc-rename)

"Format
vnoremap <silent> <leader>cm <cmd>call CocAction('formatSelected', visualmode())<CR>
nnoremap <silent> <leader>cm <cmd>call CocAction('format')<CR>
"Autoformat
inoremap <silent> <CR> <C-r>=<SID>OnEnter()<CR>

"Autocomplete
inoremap <silent> <S-TAB> <C-r>=coc#refresh()<CR>
inoremap <silent> <TAB> <C-r>=<SID>OnTab()<CR>
imap <silent> <Backspace> <C-r>=<SID>OnBackspace()<CR>
"Snippetes signed with '~' in autocomplete hover
let g:coc_snippet_prev = '<C-j>'
let g:coc_snippet_next = '<tab>'

"Scroll floating window shown onHover
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1,3) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0,3) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1,3)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0,3)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1,3) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0,3) : "\<C-b>"

"Esc closes popups
nnoremap <silent><expr> <esc> coc#float#has_float() ? "\<cmd>call coc#float#close_all()\<cr>" : "\<esc>"

"COC explorer
nnoremap <silent> <C-n> <cmd>CocCommand explorer<CR>

" ??? Code actions - various refactorings, I suppose
xmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader>ca <Plug>(coc-codeaction)

"Range select, backward is broken
xmap <silent> v <Plug>(coc-range-select)
xmap <silent> <Right> <Plug>(coc-range-select)
xmap <silent> <Left> <Plug>(coc-range-select-backward)

" ???
" " Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" " Do default action for next item.
" nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" " Do default action for previous item.
" nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" " Resume latest coc list.
" nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"List providers
command! -nargs=0 -complete=command ListCocProviders call <sid>ListCocProviders()

"Restart helps with frozen signs
cnoreabbrev cr CocRestart

"Help
cnoreabbrev hc h coc-nvim.txt

augroup coc
  autocmd!

  "Highlight symbol
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr if has format-provider
  autocmd FileType * silent call s:SetFormatExpr()

  " Update signature help on jump placeholder.
  " ??? Somehow related to snippets, I don't certainly know
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

"Implementations
function! s:IsSpaceBefore() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:OnEnter() abort
  if pumvisible()
    return coc#_select_confirm()
  else
    return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  endif
endfunction

function! s:SetFormatExpr() abort
  if CocHasProvider('format')
    setl formatexpr=CocAction('formatSelected')
  endif
endfunction

function! s:OnTab() abort
  if pumvisible()
    return "\<C-n>"
  elseif coc#expandableOrJumpable()
    return "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>"
  else
    if <sid>IsSpaceBefore()
      return "\<tab>"
    else
      return coc#refresh()
    endif
  endif
endfunction

function! s:OnBackspace() abort
  if pumvisible()
    return "\<C-h>".coc#refresh()
"     " return \<C-h>\<esc>a\<tab>
  endif
  return "\<C-h>"
endfunction

function! s:HoverOrMan() abort
  if CocHasProvider('hover')
    call CocActionAsync('doHover')
  else
    normal! K
  endif
endfunction

function! s:ListCocProviders() abort
  let allActions =  [ "rename",
    \ "onTypeEdit", "documentLink", "documentColor", "foldingRange",
    \ "format", "codeAction", "workspaceSymbols", "formatRange",
    \ "hover", "signature", "documentSymbol", "documentHighlight",
    \ "definition", "declaration", "typeDefinition", "reference",
    \ "implementation", "codeLens", "selectionRange" ]
    \ + []
  let supportedActions = []
  let unsupportedActions = []
  for act in allActions
    if(CocHasProvider(act))
      let lst = supportedActions
    else
      let lst = unsupportedActions
    endif
    call add(lst, act)
  endfor

  let leftPad = '    '
  echom "Has providers:"
  if(len(supportedActions) <= 0)
    echom leftPad.'None'
  else
    for act in supportedActions
      echom leftPad.act
    endfor
  endif

  echom leftPad
  echom "Missing providers:"
  if(len(unsupportedActions) <= 0)
    echom leftPad.'None'
  else
    for act in unsupportedActions
      echom leftPad.act
    endfor
  endif
endfunction
