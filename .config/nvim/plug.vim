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

function! s:InitPlugins() abort
  call plug#begin(stdpath("data").'/site/plugged')
    "Major
    Plug 'tpope/vim-fugitive'
    if $NO_COC
      Plug 'neovim/nvim-lspconfig'
      " Plug 'nvim-lua/lsp_extensions.nvim'
      " Plug 'nvim-lua/completion-nvim'

      " Plug 'nvim-lua/popup.nvim'

      Plug 'nvim-telescope/telescope.nvim'

      Plug 'kyazdani42/nvim-web-devicons'
      Plug 'kyazdani42/nvim-tree.lua'

      Plug 'mfussenegger/nvim-dap'
      Plug 'jbyuki/one-small-step-for-vimkind'
    else
      Plug 'neoclide/coc.nvim'
      Plug 'antoinemadec/coc-fzf'
    endif
    Plug '~/.fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'dhruvasagar/vim-table-mode'
    Plug 'nvim-treesitter/nvim-treesitter', {'branch': '0.5-compat', 'do': ':TSUpdate'}
    Plug 'nvim-treesitter/playground'

    "Minor
    " Plug 'glepnir/galaxyline.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'airblade/vim-rooter'
    Plug 'tpope/vim-surround' | let g:surround_indent = 1
    Plug 'tpope/vim-endwise'
    Plug 'JoosepAlviste/nvim-ts-context-commentstring'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    Plug 'lambdalisue/suda.vim'
    Plug 'chaoren/vim-wordmotion'
    Plug 'haya14busa/vim-asterisk'
    Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
    Plug 'dstein64/nvim-scrollview'

    Plug 'christianchiarulli/nvcode-color-schemes.vim'
  call plug#end()

  "Config
  call s:Commentary()
  call s:Surround()
  call s:Vista()
  call s:Wordmotion()
  call s:Asterisk()
  call s:ScrollView()
  source $STD_PATH_CONFIG/plug-config/colors.vim
  source $STD_PATH_CONFIG/plug-config/fugitive.vim
  source $STD_PATH_CONFIG/plug-config/fzf.vim
  if $NO_COC
    luafile $STD_PATH_CONFIG/plug-config/lsp.lua
    source $STD_PATH_CONFIG/plug-config/lsp.vim

    luafile $STD_PATH_CONFIG/plug-config/dap.lua

    call s:NvimTree()
  else
    source $STD_PATH_CONFIG/plug-config/coc.vim
  endif
  lua require'plug-config.gitsigns'.setup()
endfunction


function! s:ScrollView() abort
 let g:scrollview_on_startup = 1
 let g:scrollview_winblend = 60
 let g:scrollview_column = 1
 let g:scrollview_auto_mouse = 0
endfunction

function! s:Vista() abort
  let g:vista_sidebar_position = 'vertical topleft'
  let g:vista_sidebar_width = 60
  let g:vista_cursor_delay = 0
  let g:vista_echo_cursor_strategy = 'scroll'
  let g:vista_executive_for = utils#ListToDictKeys(['vim', 'typescript', 'lua', 'javascript','json', 'c', 'cpp'], {_ -> 'coc'}, {})

  nnoremap <silent><leader>vf :Vista finder<cr>
  nnoremap <silent><leader>vo :Vista!!<cr>
endfunction

function! s:Wordmotion() abort
  let g:wordmotion_nomap = 1

  " TODO: configure whitespaces
  " nnoremap <expr><leader>twd add(g:word_motion_spaces, '.')

  map <M-w>          <Plug>WordMotion_w
  map <M-b>          <Plug>WordMotion_b
  map <M-e>          <Plug>WordMotion_e
  omap a<M-w>         <Plug>WordMotion_aw
  omap i<M-w>         <Plug>WordMotion_iw
endfunction

function! s:Asterisk() abort
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
endfunction

function! s:Surround() abort
  xmap s S
  augroup PlugSurround
    autocmd!

    autocmd FileType sh call s:TypeSh()
    autocmd FileType haskell call s:TypeHaskell()
    autocmd FileType lisp call s:TypeLisp()
    autocmd FileType rust call s:TypeRust()
  augroup END

  function! s:TypeSh() abort
    let b:surround_{char2nr("p")} = "$(\r)"
    let b:surround_{char2nr("s")} = "${\r}"
  endfunction

  function! s:TypeHaskell() abort
    xmap <buffer> sf s<C-f>
    cnoreabbrev <buffer> lfix !hlint --refactor --refactor-options="--inplace" '%:p'
  endfunction

  function! s:TypeLisp() abort
    xmap <buffer> sf s<C-f>
  endfunction

  function! s:TypeRust() abort
    let b:surround_{char2nr("p")} = "println!(\"{:#?}\", \r);"
    let b:surround_{char2nr("o")} = "Ok(\r)"
  endfunction
endfunction

function! s:Commentary() abort
  function! s:CommentaryImplExpr(a)
    silent! lua require('ts_context_commentstring.internal').update_commentstring()
    if a:a == 1
      return "\<Plug>Commentary"
    else
      return "\<Plug>CommentaryLine"
    endif
  endfunction

  xmap <expr><C-_> <sid>CommentaryImplExpr(1)
  nmap <expr><C-_> <sid>CommentaryImplExpr(0)
endfunction

function! s:NvimTree() abort
  let g:nvim_tree_lsp_diagnostics = 1
  let g:nvim_tree_root_folder_modifier = ':t'

  let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 1,
    \ 'files': 1,
    \ 'folder_arrows': 1,
    \}

  let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★",
    \   'deleted': "",
    \   'ignored': "◌"
    \   },
    \ 'folder': {
    \   'arrow_open': "",
    \   'arrow_closed': "",
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   },
    \   'lsp': {
    \     'hint': "",
    \     'info': "",
    \     'warning': "",
    \     'error': "",
    \   }
    \ }

  let g:nvim_tree_special_files = {}

  nnoremap <C-n> :NvimTreeToggle<CR>
endfunction

call s:InitPlugins()
