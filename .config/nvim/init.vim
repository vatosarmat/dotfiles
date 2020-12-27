if exists('g:vscode') | finish | endif

"""""""""""Options""""""""""""""""""""""""""""""""""""""""""

"Allow buffer to be hidden without saving/writing
set hidden

set scrolloff=3

set mouse=a

set virtualedit=block

set clipboard+=unnamedplus

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 nosmarttab

set splitbelow splitright

set number
set relativenumber

set ignorecase
set nowrapscan
set noincsearch

set tgc
"set noshowmode

set foldmethod=indent
"set foldnestmax=10
set nofoldenable

"set wildmode=longest,list,full

"""""""""""Plugins""""""""""""""""""""""""""""""""""""""""""

let plugPath = stdpath("data").'/site/autoload/plug.vim'
let plugUrl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if empty(glob(plugPath))
  exec '!curl -fLo '.plugPath.' --create-dirs '.plugUrl
endif

autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin(stdpath("data").'/site/plugged')

  """"""COC
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
  nnoremap <C-n> :CocCommand explorer<CR>

  """"""UI
  "Plug 'preservim/nerdtree'
  "let g:NERDTreeChDirMode=3
  "let NERDTreeMinimalUI=1
  "noremap <C-n> :NERDTreeToggle<CR>

  "Plug 'ryanoasis/vim-devicons'
  Plug 'google/vim-searchindex'
  Plug 'junegunn/fzf'

  "Plug 'vim-airline/vim-airline'
  "Plug 'vim-airline/vim-airline-themes'
  "let g:airline_powerline_fonts = 1
  "let g:airline_theme='deus'

  "Plug 'kshenoy/vim-signature'

  """"""Editing
  "Plug 'chaoren/vim-wordmotion'
  Plug 'tpope/vim-surround'

  """"""Langs
  "Plug 'pangloss/vim-javascript'
  Plug 'yuezk/vim-js'
  Plug 'maxmellon/vim-jsx-pretty'

  """"""Color themes
  Plug 'tomasiser/vim-code-dark'
  Plug 'joshdick/onedark.vim'
  Plug 'morhetz/gruvbox'
  Plug 'doums/darcula'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'romainl/Apprentice'
  Plug 'ayu-theme/ayu-vim'
  Plug 'srcery-colors/srcery-vim'

call plug#end()

"""""""""""Mappings"""""""""""""""""""""""""""""""""""""""""

nnoremap <Space> <C-w>
nnoremap <C-w> <C-g>
nnoremap <M-v> <C-v>
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

"""""""""""Abbrevs""""""""""""""""""""""""""""""""""""""""""

cnoreabbrev h vert h
"cnoreabbrev hnot vert help notation
"cnoreabbrev hqr vert help quickref
"cnoreabbrev options vert options
cnoreabbrev hc vert h coc-nvim.txt

cnoreabbrev evrc tabe $MYVIMRC
cnoreabbrev svrc source $MYVIMRC
cnoreabbrev etmc tabe $HOME/.tmux.conf
cnoreabbrev mm messages
cnoreabbrev cop tabe \| CocCommand explorer

"""""""""""Highlight""""""""""""""""""""""""""""""""""""""""

augroup Highlight
  autocmd!
  "autocmd ColorScheme * highlight Normal guibg=#202020
  "autocmd ColorScheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
  "autocmd ColorScheme * highlight StatusLineNC guifg=#302a2a
  "autocmd ColorScheme * highlight StatusLine guifg=#333333
  "autocmd ColorScheme * highlight LineNr guibg=#1a1a1a
  "autocmd ColorScheme * highlight CursorLineNr guibg=#333333
augroup END

"colorscheme tokyonight
"let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
"colorscheme darcula
"colorscheme codedark
"colorscheme onedark
"colorscheme apprentice
"let ayucolor="mirage"
"colorscheme ayu
"colorscheme dracula
"colorscheme srcery
"syntax off
set cursorline cursorcolumn

"""""""""""Autocmds"""""""""""""""""""""""""""""""""""""""""

autocmd BufWritePre * %s/\s\+$//e

"""""""""""Don't fully understand how that works""""""""""""

" Redirect the output of a Vim or external command into a scratch buffer
function! Redir(cmd) abort
  let output = execute(a:cmd)
  tabnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, "\n"))
endfunction

command! -nargs=1 Redir silent call Redir(<f-args>)

"""""""""""Useless scripts""""""""""""""""""""""""""""""""""

function! MyCocListProviders() abort
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

function FooCount()
  let users = ['vasya', 'petya', 'johny', 'petya']
  echom count()
endfunction

function FooWhile()
	let s:i = 1
	while i < 5
	  echom "while count is" i
	  let i += 1
  endwhile
endfunction

function FooFor()
  for i in range(1,4)
	  echom "for count is" i
  endfor
endfunction

function FooCountWords() range
  let lnum = a:firstline
  let n = 0
  while lnum <= a:lastline
    let n = n + len(split(getline(lnum)))
    let lnum = lnum + 1
  endwhile
  echo "found " . n . " words"
endfunction

function Foo()
  let Af = function('MyCocListProviders')
  call call(Af, [])
endfunction

cnoreabbrev ff w \| source $MYVIMRC \|call Foo()




