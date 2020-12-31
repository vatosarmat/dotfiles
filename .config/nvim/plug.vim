let plugPath = stdpath("data").'/site/autoload/plug.vim'
let plugUrl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if empty(glob(plugPath))
  exec '!curl -fLo '.plugPath.' --create-dirs '.plugUrl
endif

autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin(stdpath("data").'/site/plugged')

  """"""COC
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  """"""UI
  "Plug 'preservim/nerdtree'
  "let g:NERDTreeChDirMode=3
  "let NERDTreeMinimalUI=1
  "noremap <C-n> :NERDTreeToggle<CR>

  "Plug 'ryanoasis/vim-devicons'
  Plug 'google/vim-searchindex'
  Plug 'junegunn/fzf'

  "Plug 'vim-airline/vim-airline'
  "Plug 'vim-airline/vim-airline-themes'
  "let g:airline_powerline_fonts = 1
  "let g:airline_theme='deus'

  "Plug 'kshenoy/vim-signature'

  """"""Editing
  "Plug 'chaoren/vim-wordmotion'
  Plug 'tpope/vim-surround'

  """"""Langs
  "Plug 'pangloss/vim-javascript'
  Plug 'yuezk/vim-js'
  Plug 'maxmellon/vim-jsx-pretty'

  """"""Color themes
  Plug 'tomasiser/vim-code-dark'
  Plug 'joshdick/onedark.vim'
  Plug 'morhetz/gruvbox'
  Plug 'doums/darcula'
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'romainl/Apprentice'
  Plug 'ayu-theme/ayu-vim'
  Plug 'srcery-colors/srcery-vim'

call plug#end()
