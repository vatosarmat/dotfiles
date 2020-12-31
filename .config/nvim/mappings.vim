"nnoremap <C-Space> <C-w>
"nnoremap <C-w> <C-g>
nnoremap <silent> <M-u> :noh<CR>

"nnoremap <key> :ls<CR>:b<Space>
"nnoremap <key> :<C-u>marks<CR>:normal! `
nnoremap <M-p> :bp<cr>
nnoremap <M-n> :bn<cr>

inoremap ( ()<left>
inoremap ( ()<left>
inoremap { {}<left>
inoremap { {}<left>
inoremap [ []<left>
inoremap [ []<left>

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

"For {...} blocks
inoremap <M-n> <cr><C-o>%<right><cr>

