
let g:completion_enable_auto_popup = 0

"Autocomplete
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"???? what is completion_smart_tab??
" imap <Tab> <Plug>(completion_smart_tab)
" imap <S-Tab> <Plug>(completion_smart_s_tab)

"""""""""""""""
" LSP commands
"""""""""""""""
"In use
nnoremap <silent> <C-j>        <cmd>lua vim.lsp.buf.hover()<CR>
"Go to's
nnoremap <silent> gd           <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gt           <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr           <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g[           <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g]           <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> <leader>ld   <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> <leader>lw   <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

"Less in use
nnoremap <silent> gi           <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>ls   <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gD           <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> ga           <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <C-k>                 <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>
"""""""""""""""

"""""""""""""""
" Settings
"""""""""""""""
nnoremap <leader>l<M-v> <cmd>call <sid>ToggleOption('ldv')<cr>
nnoremap <leader>l<M-u> <cmd>call <sid>ToggleOption('ldu')<cr>
nnoremap <leader>l<M-f> <cmd>call <sid>ToggleOption('laf')<cr>

augroup LSP
  autocmd BufWritePre * call s:OnBufWritePre()
  autocmd User LspProgressUpdate redraws!
  autocmd User LspDiagnosticsChanged redraws!
augroup end

" let s:autoformat_ft = utils#ListToDictKeys(['vim', 'typescript', 'lua', 'javascript','json', 'c', 'cpp'],
"   \{_ -> _}, {})

function! s:OnBufWritePre() abort
  if g:utils_options.laf
    lua vim.lsp.buf.formatting_sync(nil, 400)
  endif
endfunction

function! s:ToggleOption(option) abort
  let g:utils_options[a:option] = !g:utils_options[a:option]
  execute 'lua' 'lsp_utils.apply_option("'.a:option.'")'
  echom a:option.' '.(g:utils_options[a:option] ? 'SET' : 'UNset')
endfunction
