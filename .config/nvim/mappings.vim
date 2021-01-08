"nnoremap <C-Space> <C-w>
"nnoremap <C-w> <C-g>

"Editing
nnoremap <silent> <M-u> :noh<CR>

nnoremap <silent> <M-s> :let @+=@"<cr>
nnoremap <silent> <C-s> :w<cr>
nnoremap q q

"Navigation
nnoremap <silent>` :<C-u>marks<CR>:normal! '
"Buffer
nnoremap <silent><f1> :ls!<CR>:b<Space>
nnoremap <silent><f2> :ls!<CR>:bw<Space>
nnoremap <silent><f3> :ls<CR>:b<Space>
nnoremap <silent>\ :<C-u>execute "b" . v:count1<CR>
nnoremap <silent><M-p> :bp<cr>
nnoremap <silent><M-n> :bn<cr>
"Window
nnoremap <Left> <C-w>h
nnoremap <Down> <C-w>j
nnoremap <Up> <C-w>k
nnoremap <Right> <C-w>l
nnoremap <silent>Q :q<cr>
nnoremap <silent><M-q> :wincmd h \| q<cr>
"Motion
nnoremap - _
nnoremap _ -
nnoremap <silent>} :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent>{ :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

"Pair braces and quotes
cnoremap ( ()<left>
cnoremap ' ''<left>
cnoremap " ""<left>
"inoremap { {}<left>
cnoremap [ []<left>

"Emacs keybindings in insert and command modes
"Line begin-end
inoremap <C-a> <Home>
inoremap <C-e> <End>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
"Word backward-forward
inoremap <M-b> <C-Left>
inoremap <M-f> <C-Right>
cnoremap <M-f> <C-Right>
cnoremap <M-b> <C-Left>
"Delete char forward
inoremap <C-d> <Del>
cnoremap <C-d> <Del>
"Delete word backward-forward
inoremap <M-BS> <C-w>
inoremap <M-d> <C-o>de
cnoremap <M-BS> <C-w>
"Delete line end
inoremap <C-y> <C-o>d$
"Undo
inoremap <C-_> <C-o>u

"COC
nmap <silent> gd <Plug>(coc-definition)
nnoremap <leader>d :CocList diagnostics<cr>
nnoremap <silent> <C-h> :call CocAction('doHover')<CR>
vnoremap <silent> <leader>= :call CocAction('formatSelected', visualmode())<CR>
nnoremap <silent> <leader>= :call CocAction('format')<CR>
nnoremap <silent> <C-n> :execute "CocCommand explorer" expand("%:p:h")<CR>
"inoremap <silent> <expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! s:CocConfirm() abort
  if pumvisible()
    return coc#_select_confirm()
  else
    return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  endif
endfunction
inoremap <silent> <CR> <C-r>=<SID>CocConfirm()<CR>

function! s:IsSpaceBefore() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>IsSpaceBefore() ? "\<TAB>" :
      \ coc#refresh()

"FZF
nnoremap <silent><C-p> :FZF<cr>
let g:fzf_action = { 'ctrl-l': 'vsplit' }

"Diffs
nnoremap <silent><M-f> :DiffOrig<cr>
nnoremap <silent><M-d> :Gvdiffsplit! HEAD<cr>
nnoremap [v [c
nnoremap ]v ]c
autocmd BufWinEnter */.git/index let @n="j\<cr>\<M-d>gg\<down>"
autocmd BufWinEnter */.git/index let @p="k\<cr>\<M-d>gg\<down>"
autocmd BufWinEnter */.git/index nnoremap <buffer><M-n> @n
autocmd BufWinEnter */.git/index nnoremap <buffer><M-p> @p
