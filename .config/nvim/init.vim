if exists('g:vscode') | finish | endif

call setenv("STD_PATH_CONFIG", stdpath('config'))

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/utils.vim
source $STD_PATH_CONFIG/before-plug/fold.vim
source $STD_PATH_CONFIG/before-plug/status-line.vim
source $STD_PATH_CONFIG/before-plug/commands.vim
source $STD_PATH_CONFIG/before-plug/mappings.vim
source $STD_PATH_CONFIG/before-plug/autocmd.vim
source $STD_PATH_CONFIG/plug.vim
