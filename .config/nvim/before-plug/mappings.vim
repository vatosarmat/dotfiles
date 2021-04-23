
"Handy blockw movement
nnoremap K {
nnoremap J }

"Handy line start/end
nnoremap <C-h> _
nnoremap <C-l> g_

"Redraw
nnoremap g_ <C-l>

"Paste from vim to system clipboard
nnoremap <silent> <M-y> :let @+=@"<cr>

"Save file like in all other programs
nnoremap <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>

"yy - for string, Y - for rest of string, same with 'c' and 'd'
nnoremap Y y$

"No overwrite paste
xnoremap p "_dP

"Line in 'less' utility
nnoremap <silent> <M-u> :noh<CR>

"The options useful when iterating through many similarly highlighted search
"results - Vim unfortunately highlights 'current' result and all the others in
"the same way
"In routine workflow it distracts
nnoremap <silent> <leader>ocl :set cul! cuc!<CR>

"Wipe buffer or close its window - all via 'q'
nnoremap <silent><M-q> :bw<cr>
nnoremap <silent>Q :q<cr>

"Comfy buffer switching
nnoremap <M-n> <cmd>bn<cr>
nnoremap <M-p> <cmd>bp<cr>

"Useful before reviewing delta and commit
nnoremap <silent><leader>iub :call utils#ShowUnsavedBuffers()<cr>

"Syntax element under cursor
nnoremap <silent><leader>isn :echo synIDattr(synID(line("."), col("."), 1), "name")<cr>

nnoremap <leader>itl :lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))<cr>

"Terminal normal mode
tnoremap <c-o> <C-\><C-n>

"Easier windows navigation with arrows remapped to 'hjkl' in terminal emulator
nnoremap <Left> <C-w>h
nnoremap <Down> <C-w>j
nnoremap <Up> <C-w>k
nnoremap <Right> <C-w>l

"Close window to the left or right
nnoremap <silent><C-left> :wincmd h \| q<cr>
nnoremap <silent><C-right> :wincmd l \| q<cr>

"Easier non-file window resize
nnoremap <expr>< &buftype == "" ? "<" : "\<C-w><"
nnoremap <expr>> &buftype == "" ? ">" : "\<C-w>>"

"When writing file from top to bottom it is more comfortable to have
"new lines appering in the middle of the screen
nnoremap G Gzz

"Same with searching things, but sometimes
nnoremap <silent><leader>tnz :call <sid>ToggleNzz()<cr>

"Pair braces and quotes in command line
cnoremap <M-9> ()<left>
cnoremap <M-'> ""<left>
cnoremap <M-[> []<left>
"rem
"Emacs keybindings in insert and command modes
"Line begin-end
inoremap <expr><C-a> getline('.')[0] == ' ' ? "\<Home>\<C-Right>" : "\<Home>"
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

"Sentence and paragraph motions shouldn't be tossed jump stack
nnoremap <silent>} :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent>{ :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

"Diff buffer with last saved state
nnoremap <silent><M-f> :DiffOrig<cr>

"Diff, jump to the next hunk. With default 'c' it may be erroneously changed
nmap [w [czz
nmap ]w ]czz

"Replace last search pattern, i.e. '/' register content
nnoremap U :%s//<c-r>=<sid>GetSearchPatternWithoutFlags()<cr>/gc<left><left><left>
xnoremap U :s///gc<left><left><left>

"Implementations
function! s:GetSearchPatternWithoutFlags() abort
  return matchlist(@/, '\v^%(\\V|\\v|\\\<){,2}(.{-})%(\\\>)?$')[1]
endfunction

function s:ToggleNzz() abort
  if !exists("b:dotfiles_nzz") || !b:dotfiles_nzz
    nnoremap n nzz
    nnoremap N Nzz
    let b:dotfiles_nzz = 1
  else
    nunmap n
    nunmap N
    let b:dotfiles_nzz = 0
  endif
endfunction
