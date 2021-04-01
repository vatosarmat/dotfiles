
let g:coc_global_extensions = ['coc-json', 'coc-flow', 'coc-vimlsp', 'coc-marketplace',
  \'coc-pairs', 'coc-explorer', 'coc-prettier', 'coc-snippets', 'coc-clangd',
  \'coc-tsserver', 'coc-lua']

"Various 'go to' actions
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
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

"If has hover provider, doHover; otherwise - default 'K' 'man'
nnoremap <silent> K :call <sid>HoverOrMan()<CR>

"Move default 'K' 'man' under the \
nnoremap <silent>\K :normal! K <CR>

"CoC outline is not much useful, better use something like Vista.vim
nnoremap <silent><leader>co :CocList --normal --no-quit outline<cr>

"Diagnostics list
nnoremap <silent><leader>cld :CocList diagnostics<cr>
nmap <leader>cf <Plug>(coc-fix-current)

"Format
vnoremap <silent> <leader>= :call CocAction('formatSelected', visualmode())<CR>
nnoremap <silent> <leader>= :call CocAction('format')<CR>
"Autoformat
inoremap <silent> <CR> <C-r>=<SID>OnEnter()<CR>

"Autocomplete
inoremap <silent> <TAB> <C-r>=<SID>OnTab()<CR>
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

"COC explorer
nnoremap <silent> <C-n> :CocCommand explorer<CR>

"List providers
command! -nargs=0 -complete=command ListCocProviders silent call <sid>ListCocProviders()

"Restart helps with frozen signs
cnoreabbrev cr CocRestart

"Help
cnoreabbrev hc h coc-nvim.txt

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
