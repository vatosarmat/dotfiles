set hidden
set autoread
set noundofile
set nobackup nowritebackup
set noswapfile

set scrolloff=5

set mouse=a

set virtualedit=block

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 nosmarttab
set autoindent smartindent

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

" set wildmode=longest,list,full

"Disable folds in diffview
set diffopt+=vertical,context:10000

let mapleader = " "
nnoremap <Space> <Nop>

let g:vim_indent_cont=shiftwidth()
let g:is_bash = 1


