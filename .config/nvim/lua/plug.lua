local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local r = function(name)
  if vim.endswith(name, '.vim') then
    return function()
      vim.cmd('source $STD_PATH_CONFIG/plug-config/' .. name)
    end
  else
    return function()
      require('plug-config.' .. name)
    end
  end
end

local misc = require 'plug-config.misc'

-- init - usually sets variables affecting plugin
-- config - usually uses plugin API

ilog 'START: lazy setup'
require('lazy').setup({
  'nvim-lua/plenary.nvim',

  {
    'nvim-telescope/telescope.nvim',
    config = r 'telescope',
    dependencies = {
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim',
      'jose-elias-alvarez/null-ls.nvim',
      'jose-elias-alvarez/typescript.nvim',
      'b0o/schemastore.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'windwp/nvim-autopairs',
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
      },
    },
    init = require('lsp').init,
    config = require('lsp').config,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'windwp/nvim-ts-autotag',
      'p00f/nvim-ts-rainbow',
      'danymat/neogen',
    },
    config = r 'treesitter',
    build = ':TSUpdate',
  },

  {
    'numToStr/Comment.nvim',
    config = misc.Comment,
  },

  'kyazdani42/nvim-web-devicons',
  { 'kyazdani42/nvim-tree.lua', config = r 'nvimtree' },

  {
    'mfussenegger/nvim-dap',
    dependencies = { 'jbyuki/one-small-step-for-vimkind', 'mxsdev/nvim-dap-vscode-js' },
    config = r 'dap',
  },

  { 'tpope/vim-fugitive', config = r 'fugitive.vim' },
  { 'lewis6991/gitsigns.nvim', config = r 'gitsigns' },

  {
    'junegunn/fzf',
    build = ':call fzf#install()',
    dependencies = { 'junegunn/fzf.vim' },
    config = r 'fzf.vim',
  },
  'lambdalisue/suda.vim',

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = r 'ufo',
  },

  -- {
  --   'kylechui/nvim-surround',
  --   version = '*', -- Use for stability; omit to use `main` branch for the latest features
  --   -- event = 'VeryLazy',
  --   init = require('plug-config.surround').init,
  --   config = require('plug-config.surround').config,
  -- },

  {
    'machakann/vim-sandwich',
    init = require('plug-config.sandwich').init,
    config = require('plug-config.sandwich').config,
  },

  {
    'mattn/emmet-vim',
    init = misc.emmet.init,
    config = misc.emmet.config,
  },

  {
    'andymass/vim-matchup',
    init = misc.matchup.init,
    config = misc.matchup.config,
  },

  {
    'chaoren/vim-wordmotion',
    init = misc.wordmotion.init,
    config = misc.wordmotion.config,
  },

  {
    'haya14busa/vim-asterisk',
    config = misc.asterisk,
  },

  {
    'rrethy/vim-hexokinase',
    build = 'make hexokinase',
  },

  {
    'dstein64/nvim-scrollview',
    init = misc.scrollview.init,
    config = misc.scrollview.config,
  },

  'teal-language/vim-teal',
  'chr4/nginx.vim',
  'jwalton512/vim-blade',
}, {})
ilog 'DONE: lazy setup'

vim.opt.rtp:append(vim.fn.getenv 'NVIM_EXTRA')
vim.opt.rtp:append(vim.fn.stdpath 'data' .. '/rocks')
