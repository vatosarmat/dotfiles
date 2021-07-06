inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

imap <Tab> <Plug>(completion_smart_tab)
imap <S-Tab> <Plug>(completion_smart_s_tab)

nnoremap <silent> gd           <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <C-j>        <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi           <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>ls   <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gt           <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr           <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> <leader>ld   <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> <leader>lw   <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gD           <cmd>lua vim.lsp.buf.declaration()<CR>

nnoremap <silent> ga           <cmd>lua vim.lsp.buf.code_action()<CR>

nnoremap <C-k>                 <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>
nnoremap <silent> g[           <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g]           <cmd>lua vim.lsp.diagnostic.goto_next()<CR>


