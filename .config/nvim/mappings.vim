"Editing
nnoremap <silent> <M-u> :noh<CR>
nnoremap <silent> <M-y> :let @+=@"<cr>
" cnoremap <M-p> <C-r>"
" inoremap <M-p> <C-r>"
" cnoremap <M-v> <C-r>0
" inoremap <M-v> <C-r>0
nnoremap <silent> <C-s> :w<cr>
inoremap <silent> <C-s> <Esc>:w<cr>
"for fugitive - it checks this mapping exists
nnoremap q q
"paste yanked in normal, visual, and maybe operator pending also, I am not sure
noremap gp "0p
"do not dup yy
nnoremap Y y$
"comment out
nmap <C-_> <Plug>CommentaryLine
xmap <C-_> <Plug>Commentary

"Navigation
" nnoremap <silent>` :<C-u>marks<CR>:normal! '
" nnoremap <M-/> /\C
" nnoremap <M-?> ?\C

"Buffer
" nnoremap <silent><f1> :ls<CR>:b<Space>
" nnoremap <silent><f2> :ls!<CR>:b<Space>
" nnoremap <silent><f3> :ls!<CR>:bw<Space>
" nnoremap <silent><M-p> :bp<cr>
" nnoremap <silent><M-n> :bn<cr>

"Window
nnoremap <Left> <C-w>h
nnoremap <Down> <C-w>j
nnoremap <Up> <C-w>k
nnoremap <Right> <C-w>l
nnoremap <silent>Q :q<cr>
nnoremap <silent><C-left> :wincmd h \| q<cr>
nnoremap <silent><C-right> :wincmd l \| q<cr>
nnoremap <silent><C-w>gl :wincmd L \| execute "vertical resize" string(&columns * 0.27)<cr>
"easy resize non-file windows
nnoremap <expr>< &buftype == "" ? "<" : "\<C-w><"
nnoremap <expr>> &buftype == "" ? ">" : "\<C-w>>"

"Motion
nnoremap - _
nnoremap _ -
nnoremap <silent>} :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent>{ :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>
nnoremap G Gzz

"Pair braces and quotes in command line
cnoremap ( ()<left>
cnoremap ' ''<left>
cnoremap " ""<left>
cnoremap [ []<left>

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

 "vim-surround
" xmap s <Plug>VSurround
augroup CustomSurround
  autocmd!
  autocmd FileType sh call s:SurroundSh()
  autocmd FileType haskell call s:SurroundHaskellLisp()
  autocmd FileType lisp call s:SurroundHaskellLisp()
augroup END

function! s:SurroundSh() abort
  let b:surround_{char2nr("p")} = "$(\r)"
  let b:surround_{char2nr("s")} = "${\r}"
endfunction

function! s:SurroundHaskellLisp() abort
  xmap <buffer> sf s<C-f>
endfunction

"COC
function! s:MyCocOutline()
  CocList --normal outline
  "sleep 1m
  "wincmd L
endfunction

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

"COC actions
"nnoremap doesn't work with <Plug>!
nmap <silent> <leader>cd <Plug>(coc-definition)
nmap <silent> <leader>ct <Plug>(coc-type-definition)
nmap <silent> <leader>ci <Plug>(coc-implementation)
nmap <silent> <leader>cr <Plug>(coc-references)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
nnoremap <silent><leader>co :call <sid>MyCocOutline()<cr>
nnoremap <silent><leader>cld :CocList diagnostics<cr>
nnoremap <silent> K :call <sid>HoverOrMan()<CR>
nnoremap <silent><leader> K :normal! K <CR>
vnoremap <silent> <leader>= :call CocAction('formatSelected', visualmode())<CR>
nnoremap <silent> <leader>= :call CocAction('format')<CR>

nmap <leader>cf <Plug>(coc-fix-current)
let g:coc_snippet_prev = '<C-j>'
let g:coc_snippet_next = '<tab>'

nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1,3) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0,3) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1,3)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0,3)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1,3) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0,3) : "\<C-b>"

"COC autoformat/autocomplete
inoremap <silent> <CR> <C-r>=<SID>OnEnter()<CR>
inoremap <silent> <TAB> <C-r>=<SID>OnTab()<CR>

"COC explorer
nnoremap <silent> <C-n> :execute "CocCommand explorer" expand("%:p:h")<CR>


"FZF
nnoremap <silent><C-p> :Files<cr>
let g:fzf_action = { 'ctrl-l': 'vsplit', 'ctrl-t': 'tab split', 'ctrl-x': 'split' }


"Diffs
nnoremap <silent><M-f> :DiffOrig<cr>
nnoremap <silent><M-d> :Gvdiffsplit! HEAD<cr>
nnoremap [v [c
nnoremap ]v ]c
" augroup CustomFugitive
"   autocmd BufWinEnter */.git/index let @n="j\<cr>\<M-d>gg\<down>"
"   autocmd BufWinEnter */.git/index let @p="k\<cr>\<M-d>gg\<down>"
"   autocmd BufWinEnter */.git/index let @s="s\<cr>\<M-d>gg\<down>"
"   autocmd BufWinEnter */.git/index nnoremap <buffer><M-n> @n
"   autocmd BufWinEnter */.git/index nnoremap <buffer><M-p> @p
"   autocmd BufWinEnter */.git/index nnoremap <buffer><M-s> @s
" augroup END
