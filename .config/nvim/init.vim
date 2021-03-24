if exists('g:vscode') | finish | endif

call setenv("STD_PATH_CONFIG", stdpath('config'))

source $STD_PATH_CONFIG/options.vim
source $STD_PATH_CONFIG/plug.vim
source $STD_PATH_CONFIG/utils.vim
source $STD_PATH_CONFIG/commands.vim
source $STD_PATH_CONFIG/mappings.vim
source $STD_PATH_CONFIG/ft-specific.vim
source $STD_PATH_CONFIG/tab-line.vim

source $STD_PATH_CONFIG/playground.vim

luafile $STD_PATH_CONFIG/df-treesitter.lua
" luafile $STD_PATH_CONFIG/df-galaxyline.lua

"Settings that should probably be set at the end
let g:is_bash = 1

colorscheme nvcode
hi! link TSTypeBuiltin TSType
hi! link CocErrorSign LspDiagnosticsSignError
hi Pmenu guifg=#e6eeff
hi Comment gui=NONE cterm=NONE
hi Special gui=NONE cterm=NONE
hi CursorColumn guibg=#303030
hi CursorLine guibg=#303030
" hi Folded guifg=#555fd6

" set cursorline cursorcolumn

augroup Init
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END
