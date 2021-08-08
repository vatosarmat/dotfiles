local mk_sourcer = require'before-plug.vim_utils'.mk_sourcer
local misc = require 'plug-config.misc'
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({
    'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path
  })
  execute 'packadd packer.nvim'
end

local plug = require('packer').startup(function()
  use_rocks 'inspect'
  use_rocks 'penlight'
  use_rocks 'lua-cjson'
  use_rocks 'luasocket'
  use_rocks 'luasec'
  -- Major
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'teal-language/vim-teal'

  use { 'neovim/nvim-lspconfig', config = mk_sourcer 'plug-config.lsp' }

  use 'nvim-telescope/telescope.nvim'

  use 'kyazdani42/nvim-web-devicons'
  use { 'kyazdani42/nvim-tree.lua', config = mk_sourcer 'plug-config.nvimtree' }

  use { 'mfussenegger/nvim-dap', config = mk_sourcer 'plug-config.dap' }
  use 'jbyuki/one-small-step-for-vimkind'

  use {
    'nvim-treesitter/nvim-treesitter',
    branch = '0.5-compat',
    config = mk_sourcer 'plug-config.treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'

  use {
    'tpope/vim-fugitive',
    config = mk_sourcer '$STD_PATH_CONFIG/plug-config/fugitive.vim'
  }
  use { 'lewis6991/gitsigns.nvim', config = mk_sourcer 'plug-config.gitsigns' }

  use { '~/.fzf', as = 'fzf' }
  use {
    'junegunn/fzf.vim',
    config = mk_sourcer '$STD_PATH_CONFIG/plug-config/fzf.vim'
  }
  -- Minor
  use 'airblade/vim-rooter'
  use 'lambdalisue/suda.vim'

  use { 'tpope/vim-surround', config = misc.surround }
  use 'tpope/vim-repeat'
  use { 'tpope/vim-commentary', config = misc.commentary }
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  use { 'chaoren/vim-wordmotion', config = misc.wordmotion }
  use { 'haya14busa/vim-asterisk', config = misc.asterisk }

  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }
  use { 'dstein64/nvim-scrollview', config = misc.scrollview }

  use {
    'christianchiarulli/nvcode-color-schemes.vim',
    config = mk_sourcer '$STD_PATH_CONFIG/plug-config/colors.vim'
  }
end)

return plug
