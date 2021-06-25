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
    Plug 'neoclide/coc.nvim'
    Plug '~/.fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'liuchengxu/vista.vim'
    Plug 'dhruvasagar/vim-table-mode'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
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

    Plug 'christianchiarulli/nvcode-color-schemes.vim'
  call plug#end()

  "Config
  call s:Commentary()
  call s:Surround()
  call s:Vista()
  call s:Wordmotion()
  call s:Asterisk()
  call s:Colorscheme()
  source $STD_PATH_CONFIG/plug-config/fugitive.vim
  source $STD_PATH_CONFIG/plug-config/fzf.vim
  source $STD_PATH_CONFIG/plug-config/coc.vim
  luafile $STD_PATH_CONFIG/plug-config/treesitter.lua
  lua require'plug-config.gitsigns'.setup()
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

  nmap <M-w>          <Plug>WordMotion_w
  nmap <M-b>          <Plug>WordMotion_b
  nmap <M-e>          <Plug>WordMotion_e
  omap <M-w>          <Plug>WordMotion_w
  omap <M-b>          <Plug>WordMotion_b
  omap <M-e>          <Plug>WordMotion_e
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
  augroup END

  function! s:TypeSh() abort
    let b:surround_{char2nr("p")} = "$(\r)"
    let b:surround_{char2nr("s")} = "${\r}"
    let b:coc_pairs_disabled = ["'", "\""]
  endfunction

  function! s:TypeHaskell() abort
    xmap <buffer> sf s<C-f>
    cnoreabbrev <buffer> lfix !hlint --refactor --refactor-options="--inplace" '%:p'
  endfunction

  function! s:TypeLisp() abort
    xmap <buffer> sf s<C-f>
    let b:coc_pairs_disabled = ["'"]
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

function! s:Colorscheme() abort
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
  hi LspDiagnosticsSignError guifg=#c87a7a
  hi CocHighlightText guibg=#3a3a3a
  hi YankHighlight guibg=#1d3a3a

  " hi StatusLine guifg=#abb2bf ctermfg=249 guibg=#2c323c ctermbg=236 gui=NONE cterm=NONE
  " hi StatusLineNC guifg=#5c6370 ctermfg=241 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
  " hi StatusLineNC guifg=#5c6370 ctermfg=241 guibg=#1e1e1e ctermbg=NONE gui=NONE cterm=NONE

  hi StatusLine guifg=#abb2bf ctermfg=249 guibg=#000000 ctermbg=236 gui=NONE cterm=NONE
  hi StatusLineNC guifg=#5c6370 ctermfg=241 guibg=#191919 ctermbg=NONE gui=NONE cterm=NONE

  " hi DiffAdd guifg=NONE guibg=#4b5632
  " hi DiffDelete guifg=NONE guibg=NONE
  " hi DiffChange guifg=NONE guibg=#053f4f
  " hi DiffDelete guifg=NONE guibg=#4a0a0d
  "
  hi RedBlue guifg=#ff0000, guibg=#00ff00

  hi DiffAdd guifg=NONE guibg=#151e00
  hi DiffDelete guifg=NONE guibg=#101010
  hi DiffChange guifg=NONE gui=NONE guibg=#01181e
  hi DiffText guifg=NONE guibg=#1e0000
  hi DiffConflictMarker guibg=#666666 guifg=#000000

  " hi GitSignsAdd    guifg=NONE guibg=#608b4e
  " hi GitSignsChange guifg=NONE guibg=#dcdcaa
  " hi GitSignsDelete guifg=NONE guibg=#d16969

  " More saturated colours if needed
  " hi GitSignsAdd    guifg=#00ff00
  " hi GitSignsChange guifg=#ffff00
  " hi GitSignsDelete guibg=#d16969
  "
  " hi Folded guifg=#555fd6
endfunction

call s:InitPlugins()
