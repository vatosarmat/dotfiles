set nomodeline
set hidden
set autoread
set noundofile
set nobackup nowritebackup
set noswapfile
set cpoptions-=_

set switchbuf=usetab

set scrolloff=5

set mouse=a

set virtualedit=block

set updatetime=100

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 nosmarttab
set autoindent smartindent

set splitbelow splitright
set keywordprg=:vert\ Man

set number
set relativenumber
set signcolumn=yes

set ignorecase
set smartcase
set nowrapscan
set noincsearch

set grepprg=grep\ -n\ --with-filename\ -I\ -R
set grepformat=%f:%l:%m

set tgc


"Disable folds in diffview
set diffopt+=vertical,context:10000,foldcolumn:0,indent-heuristic,algorithm:patience,hiddenoff

set completeopt=menuone,noselect
"set shortmess+=c
set omnifunc=v:lua.service.lsp.omnifunc


let mapleader = " "
nnoremap <Space> <Nop>

let g:vim_indent_cont=shiftwidth()
let g:is_bash = 1
let g:rust_recommended_style = 0


