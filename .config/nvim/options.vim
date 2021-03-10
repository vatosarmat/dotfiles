set hidden
set autoread
set noundofile
set nobackup nowritebackup
set noswapfile

set scrolloff=3

set mouse=a

set virtualedit=block

"set clipboard+=unnamedplus

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 nosmarttab
let g:vim_indent_cont=shiftwidth()

set splitbelow splitright
set keywordprg=:vert\ Man

set number
set relativenumber

set ignorecase
set smartcase
set nowrapscan
set noincsearch

set tgc
"set noshowmode

set foldmethod=indent
"set foldnestmax=10
set foldminlines=10
set nofoldenable

"set wildmode=longest,list,full

let mapleader = " "
nnoremap <Space> <Nop>

let g:is_bash = 1
