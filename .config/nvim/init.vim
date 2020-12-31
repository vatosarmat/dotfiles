if exists('g:vscode') | finish | endif

call setenv("STD_PATH_CONFIG", stdpath('config'))

source $STD_PATH_CONFIG/options.vim
source $STD_PATH_CONFIG/plug.vim
source $STD_PATH_CONFIG/func_cmd.vim
source $STD_PATH_CONFIG/mappings.vim
source $STD_PATH_CONFIG/abbrevs.vim
source $STD_PATH_CONFIG/coc.vim

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

source $STD_PATH_CONFIG/playground.vim

