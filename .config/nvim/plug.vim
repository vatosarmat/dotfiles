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

call plug#begin(stdpath("data").'/site/plugged')

  """"""IDE
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'tpope/vim-fugitive'
  Plug 'airblade/vim-gitgutter'
  Plug '~/.fzf'
  Plug 'junegunn/fzf.vim'
  " Plug 'kyazdani42/nvim-web-devicons' " for file icons
  " Plug 'kyazdani42/nvim-tree.lua'

  """"""UI
  "Plug 'preservim/nerdtree'
  "let g:NERDTreeChDirMode=3
  "let NERDTreeMinimalUI=1
  "noremap <C-n> :NERDTreeToggle<CR>

  "Plug 'ryanoasis/vim-devicons'
  " Plug 'google/vim-searchindex'
  " Plug 'osyo-manga/vim-anzu'

  "Plug 'vim-airline/vim-airline'
  "Plug 'vim-airline/vim-airline-themes'
  "let g:airline_powerline_fonts = 1
  "let g:airline_theme='deus'

  "Plug 'kshenoy/vim-signature'

  """"""Editing
  "Plug 'chaoren/vim-wordmotion'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-endwise'
  " Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-repeat'
  Plug 'lambdalisue/suda.vim'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'haya14busa/vim-asterisk'
  Plug 'chaoren/vim-wordmotion'

  """"""Langs
  Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/playground'
  " Plug 'sheerun/vim-polyglot'
  " Plug 'pangloss/vim-javascript'
  " Plug 'yuezk/vim-js'
  " Plug 'maxmellon/vim-jsx-pretty'
  " Plug 'jackguo380/vim-lsp-cxx-highlight'
  " Plug 'neovimhaskell/haskell-vim'

  """"""Color themes
  Plug 'christianchiarulli/nvcode-color-schemes.vim'
  Plug 'sainnhe/gruvbox-material'
  Plug 'habamax/vim-gruvbit'
  Plug 'tomasiser/vim-code-dark'
  Plug 'joshdick/onedark.vim'
  Plug 'morhetz/gruvbox'
  Plug 'doums/darcula'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'romainl/Apprentice'
  Plug 'ayu-theme/ayu-vim'
  Plug 'srcery-colors/srcery-vim'

call plug#end()

let g:coc_global_extensions = ['coc-json', 'coc-flow', 'coc-vimlsp', 'coc-marketplace',
  \'coc-pairs', 'coc-explorer', 'coc-prettier', 'coc-snippets', 'coc-clangd',
  \'coc-tsserver']

" let g:haskell_indent_disable = 1

let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
