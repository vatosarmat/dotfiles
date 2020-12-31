  nmap <silent> gd <Plug>(coc-definition)

  "Completion
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
  "inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  "inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  "inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

  nnoremap <leader>d :CocList diagnostics<cr>

  nnoremap <silent> <C-h> :call CocAction('doHover')<CR>

  "Format
  vnoremap <silent> <leader>f :call CocAction('formatSelected', visualmode())<CR>
  nnoremap <silent> <leader>f :call CocAction('format')<CR>

  "Explorer
  nnoremap <C-n> :execute "CocCommand explorer" expand("%:p:h")<CR>
