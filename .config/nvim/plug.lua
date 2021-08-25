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

  use { 'neovim/nvim-lspconfig' }
  use { 'hrsh7th/nvim-compe', after = 'nvim-lspconfig' }
  use { 'L3MON4D3/LuaSnip', after = 'nvim-compe' }
  use {
    'windwp/nvim-autopairs',
    after = 'LuaSnip',
    config = function()
      require 'plug-config.lsp'
      -- local npairs = require 'nvim-autopairs'
      -- npairs.setup()
      local npairs_compe = require "nvim-autopairs.completion.compe"
      npairs_compe.setup { map_cr = true }
      npairs_compe.add_rules(require('nvim-autopairs.rules.endwise-lua'))
      npairs_compe.remove_rule('\'')
      npairs_compe.remove_rule('"')
    end
  }

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

  use {
    'airblade/vim-rooter',
    event = 'VimEnter',
    config = function() require 'plug-config.project_type' end
  }
  use { '~/.fzf', as = 'fzf', after = 'vim-rooter' }
  use {
    'junegunn/fzf.vim',
    after = 'fzf',
    config = function()
      vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')
    end
  }
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
  -- Rarely needed
  use 'teal-language/vim-teal'
end)

return plug
