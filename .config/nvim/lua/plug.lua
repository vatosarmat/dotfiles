-- local execute = vim.api.nvim_command
-- local fn = vim.fn
--
-- local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
--
-- if fn.empty(fn.glob(install_path)) > 0 then
--   fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
--   execute 'packadd packer.nvim'
-- end

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
  local major = { 'lsp' }
  if vim.endswith(name, '.vim') then
    return function()
      vim.cmd('source $STD_PATH_CONFIG/plug-config/' .. name)
    end
  elseif vim.tbl_contains(major, name) then
    return function()
      require(name)
    end
  else
    return function()
      require('plug-config.' .. name)
    end
  end
end

local misc = require 'plug-config.misc'

require('lazy').setup({
  'nvim-lua/plenary.nvim',

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim',
      'jose-elias-alvarez/null-ls.nvim',
      'jose-elias-alvarez/typescript.nvim',
      'b0o/schemastore.nvim',
    },
    config = r 'lsp',
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'windwp/nvim-autopairs',
    },
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

  {
    'machakann/vim-sandwich',
    config = r 'sandwich',
  },

  {
    'mattn/emmet-vim',
    config = misc.emmet,
  },

  {
    'andymass/vim-matchup',
    config = misc.matchup,
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
    config = misc.scrollview,
  },

  'teal-language/vim-teal',
  'chr4/nginx.vim',
  'jwalton512/vim-blade',
}, {})

-- require('packer').startup {
--   function()
--     local r = function(name)
--       local major = { 'lsp' }
--       if vim.endswith(name, '.vim') then
--         return string.format('vim.cmd(\'source $STD_PATH_CONFIG/plug-config/%s\')', name)
--       elseif vim.tbl_contains(major, name) then
--         return string.format('require(\'%s\')', name)
--       else
--         return string.format('require(\'plug-config.%s\')', name)
--       end
--     end
--
--     local usec = function(path, name, disable)
--       use {
--         path,
--         config = r(name),
--         disable = disable,
--       }
--     end
--
--     use 'wbthomason/packer.nvim'
--     use 'nvim-lua/plenary.nvim'
--
--     use {
--       'neovim/nvim-lspconfig',
--       requires = {
--         'folke/neodev.nvim',
--         'jose-elias-alvarez/null-ls.nvim',
--         -- 'jose-elias-alvarez/nvim-lsp-ts-utils',
--         'jose-elias-alvarez/typescript.nvim',
--         'b0o/schemastore.nvim',
--       },
--       config = r 'lsp',
--     }
--
--     use {
--       'hrsh7th/nvim-cmp',
--       requires = {
--         'hrsh7th/cmp-nvim-lsp',
--         'hrsh7th/cmp-buffer',
--         'hrsh7th/cmp-path',
--         'saadparwaiz1/cmp_luasnip',
--         'L3MON4D3/LuaSnip',
--         'windwp/nvim-autopairs',
--       },
--     }
--
--     use {
--       'nvim-treesitter/nvim-treesitter',
--       run = ':TSUpdate',
--       requires = {
--         'nvim-treesitter/playground',
--         'nvim-treesitter/nvim-treesitter-textobjects',
--         'JoosepAlviste/nvim-ts-context-commentstring',
--         'windwp/nvim-ts-autotag',
--         'p00f/nvim-ts-rainbow',
--         'danymat/neogen',
--         -- 'nvim-treesitter/nvim-treesitter-angular'
--       },
--       config = r 'treesitter',
--     }
--     use {
--       'numToStr/Comment.nvim',
--       config = misc.Comment,
--     }
--
--     use {
--       'nvim-telescope/telescope.nvim',
--       requires = {
--         {
--           'nvim-telescope/telescope-fzf-native.nvim',
--           run = 'make',
--         },
--       },
--       config = r 'telescope',
--     }
--
--     use 'kyazdani42/nvim-web-devicons'
--     usec('kyazdani42/nvim-tree.lua', 'nvimtree')
--
--     use {
--       'mfussenegger/nvim-dap',
--       requires = { 'jbyuki/one-small-step-for-vimkind', 'mxsdev/nvim-dap-vscode-js' },
--       config = r 'dap',
--     }
--
--     usec('tpope/vim-fugitive', 'fugitive.vim')
--     usec('lewis6991/gitsigns.nvim', 'gitsigns')
--
--     use {
--       'junegunn/fzf',
--       run = ':call fzf#install()',
--       requires = { 'junegunn/fzf.vim' },
--       config = r 'fzf.vim',
--     }
--     use 'lambdalisue/suda.vim'
--
--     use {
--       'kevinhwang91/nvim-ufo',
--       requires = 'kevinhwang91/promise-async',
--       config = r 'ufo',
--     }
--
--     use {
--       'machakann/vim-sandwich',
--       config = r 'sandwich',
--     }
--
--     use {
--       'mattn/emmet-vim',
--       config = misc.emmet,
--     }
--
--     use {
--       'andymass/vim-matchup',
--       config = misc.matchup,
--     }
--
--     use {
--       'chaoren/vim-wordmotion',
--       config = misc.wordmotion,
--     }
--
--     use {
--       'haya14busa/vim-asterisk',
--       config = misc.asterisk,
--     }
--
--     use {
--       'rrethy/vim-hexokinase',
--       run = 'make hexokinase',
--     }
--     use {
--       'dstein64/nvim-scrollview',
--       config = misc.scrollview,
--     }
--
--     use 'teal-language/vim-teal'
--     use 'chr4/nginx.vim'
--     use 'jwalton512/vim-blade'
--   end,
--   {
--     config = {
--       git = {
--         clone_timeout = 300,
--       },
--     },
--   },
-- }
