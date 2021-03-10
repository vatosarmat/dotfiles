if exists('g:vscode') | finish | endif

call setenv("STD_PATH_CONFIG", stdpath('config'))

cabbr help vert help

source $STD_PATH_CONFIG/options.vim
source $STD_PATH_CONFIG/plug.vim
source $STD_PATH_CONFIG/commands.vim
source $STD_PATH_CONFIG/mappings.vim
source $STD_PATH_CONFIG/tab-line.vim

"Settings that should probably be set at the end
let g:is_bash = 1
colorscheme gruvbox
set cursorline cursorcolumn
autocmd BufWritePre * %s/\s\+$//e
