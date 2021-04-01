let plugPath = stdpath("data").'/site/autoload/plug.vim'
let plugUrl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if empty(glob(plugPath))
  exec '!curl -fLo '.plugPath.' --create-dirs '.plugUrl
endif

augroup Plug
  autocmd!
  autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
   \| PlugInstall --sync | source $MYVIMRC
   \| endif
augroup END

function s:InitPlugins() abort
  call plug#begin(stdpath("data").'/site/plugged')
    "Major
    Plug 'tpope/vim-fugitive'
    Plug 'neoclide/coc.nvim'
    Plug '~/.fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'dhruvasagar/vim-table-mode'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/playground'

    "Minor
    Plug 'airblade/vim-gitgutter'
    Plug 'airblade/vim-rooter'
    Plug 'tpope/vim-surround' | let g:surround_indent = 1
    Plug 'tpope/vim-endwise'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    Plug 'lambdalisue/suda.vim'
    Plug 'chaoren/vim-wordmotion'
    Plug 'haya14busa/vim-asterisk'
    Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

    Plug 'christianchiarulli/nvcode-color-schemes.vim'
  call plug#end()

  "Config
  call s:Fugitive()
  call s:Commentary()
  call s:Fzf()
  call s:Vista()
  call s:Wordmotion()
  call s:Asterisk()
  call s:Colorscheme()
  source $STD_PATH_CONFIG/plug-config/coc.vim
  luafile $STD_PATH_CONFIG/plug-config/treesitter.lua
endfunction

"Config functions
function! s:Fugitive() abort
  nnoremap <silent><M-d> :Gvdiffsplit! HEAD<cr>
  cnoreabbrev G G \| execute "resize" string(&lines * 0.3)
  cnoreabbrev hg h fugitive
endfunction

function! s:Vista() abort
  let g:vista_sidebar_position = 'vertical topleft'
  let g:vista_sidebar_width = 60
  let g:vista_cursor_delay = 0
  let g:vista_echo_cursor_strategy = 'scroll'
  let g:vista_executive_for = ListToDictKeys(['vim', 'typescript', 'lua', 'javascript','json', 'c', 'cpp'], {_ -> 'coc'}, {})

  nnoremap <silent> \vf :Vista finder<cr>
  nnoremap <silent> \vo :Vista!!<cr>
endfunction

function s:Fzf() abort
  nnoremap <silent><C-p> :Files<cr>
  let g:fzf_action = { 'ctrl-l': 'vsplit', 'ctrl-t': 'tab split', 'ctrl-x': 'split' }

  cnoreabbrev ht h \| Helptags
  cnoreabbrev hf h fzf-vim

  let s:rga_shell_command = "rg --column --line-number --no-heading --color=always --smart-case"
  command! -bang -nargs=* Rga
    \ call fzf#vim#grep(s:rga_shell_command." ".<q-args>, 1, fzf#vim#with_preview(), <bang>0)
endfunction

function s:Wordmotion() abort
  let g:wordmotion_nomap = 1

  nmap <M-w>          <Plug>WordMotion_w
  nmap <M-b>          <Plug>WordMotion_b
  nmap <M-e>          <Plug>WordMotion_e
  omap <M-w>          <Plug>WordMotion_w
  omap <M-b>          <Plug>WordMotion_b
  omap <M-e>          <Plug>WordMotion_e
  omap a<M-w>         <Plug>WordMotion_aw
  omap i<M-w>         <Plug>WordMotion_iw
endfunction

function s:Asterisk() abort
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
endfunction

function s:Commentary() abort
  "Comment out line or selection
  nmap <C-_> <Plug>CommentaryLine
  xmap <C-_> <Plug>Commentary
endfunction

function s:Colorscheme() abort
  colorscheme nvcode
  hi! link TSTypeBuiltin TSType
  hi! link CocErrorSign LspDiagnosticsSignError
  hi Pmenu guifg=#e6eeff
  hi Comment gui=NONE cterm=NONE
  hi Special gui=NONE cterm=NONE
  hi CursorColumn guibg=#2b2b2b
  hi CursorLine guibg=#2b2b2b
  hi Visual guibg=#264f78
  hi Search guibg=#613214
  " hi Folded guifg=#555fd6
endfunction

call s:InitPlugins()
