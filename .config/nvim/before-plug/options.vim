set nomodeline
set hidden
set autoread
set noundofile
set nobackup nowritebackup
set noswapfile
set cpoptions-=_

set cdpath=.,,,

set switchbuf=usetab

set scrolloff=5

set mouse=a

set virtualedit=block

set updatetime=300

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

set formatoptions-=o
set formatoptions-=c
"Stupidly reindents class::member
set cinkeys-=:

"Disable folds in diffview
set diffopt+=vertical,context:10000,foldcolumn:0,indent-heuristic,algorithm:patience,hiddenoff

"set shortmess+=c
set omnifunc=v:lua.service.lsp.omnifunc

set inccommand=

let mapleader = " "
nnoremap <Space> <Nop>

let g:vim_indent_cont=shiftwidth()
let g:rust_recommended_style = 0
let g:markdown_fenced_languages = [
  \'lua', 'vim',
  \'json', 'typescript', 'javascript', 'js=javascript', 'ts=typescript',
  \'shell=sh', 'python', 'sh', 'console=sh',
  \]


