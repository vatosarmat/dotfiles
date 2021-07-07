
let g:completion_enable_auto_popup = 0

"Autocomplete
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"???? what is completion_smart_tab??
imap <Tab> <Plug>(completion_smart_tab)
imap <S-Tab> <Plug>(completion_smart_s_tab)

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

"Autoformatting
augroup LSP
  autocmd BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 400)
augroup end


