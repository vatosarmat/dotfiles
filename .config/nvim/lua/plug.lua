local misc = require 'plug-config.misc'
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  execute 'packadd packer.nvim'
end

require('packer').startup({
  function()
    local r = function(name)
      local major = { 'lsp' }
      if vim.endswith(name, '.vim') then
        return string.format('vim.cmd(\'source $STD_PATH_CONFIG/plug-config/%s\')', name)
      elseif vim.tbl_contains(major, name) then
        return string.format('require(\'%s\')', name)
      else
        return string.format('require(\'plug-config.%s\')', name)
      end
    end

    local usec = function(path, name)
      use {
        path,
        config = r(name)
      }
    end

    use_rocks 'penlight'

    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'

    use {
      'neovim/nvim-lspconfig',
      opt = true,
      event = 'VimEnter',
      wants = {
        'lua-dev.nvim',
        'null-ls.nvim',
        'nvim-lsp-ts-utils',
        'nvim-cmp',
        'telescope.nvim',
        'nvim-treesitter'
      },
      requires = {
        'folke/lua-dev.nvim',
        'jose-elias-alvarez/null-ls.nvim',
        'jose-elias-alvarez/nvim-lsp-ts-utils'
      },
      rocks = { 'penlight' },
      config = r 'lsp'
    }
    use {
      'hrsh7th/nvim-cmp',
      disable = false,
      opt = true,
      wants = { 'LuaSnip' },
      requires = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'windwp/nvim-autopairs'
      }
    }
    use {
      'ms-jpq/coq_nvim',
      disable = true,
      branch = 'coq',
      config = function()
        vim.g.coq_settings = {
          keymap = {
            manual_complete = '<C-space>',
            pre_select = true
          },
          auto_start = true
        }

        require('coq')
      end,
      requires = {
        {
          'ms-jpq/coq.artifacts',
          branch = 'artifacts'
        },
        {
          'ms-jpq/coq.thirdparty',
          branch = '3p'
        },
        'neovim/nvim-lspconfig'
      }
    }

    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      event = 'VimEnter',
      run = ':TSUpdate',
      requires = {
        'nvim-treesitter/playground',
        'nvim-treesitter/nvim-treesitter-textobjects',
        'JoosepAlviste/nvim-ts-context-commentstring'
      },
      config = r 'treesitter'
    }
    use {
      'numToStr/Comment.nvim',
      config = misc.Comment
    }

    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make'
        }
      },
      config = r 'telescope'
    }

    use 'kyazdani42/nvim-web-devicons'
    usec('kyazdani42/nvim-tree.lua', 'nvimtree')

    use {
      'mfussenegger/nvim-dap',
      requires = { 'jbyuki/one-small-step-for-vimkind' },
      rocks = { 'penlight' },
      config = r 'dap'
    }

    usec('tpope/vim-fugitive', 'fugitive.vim')
    usec('lewis6991/gitsigns.nvim', 'gitsigns')

    use {
      '~/.fzf',
      as = 'fzf',
      event = 'VimEnter',
      opt = true,
      requires = { 'junegunn/fzf.vim' },
      wants = { 'fzf.vim' },
      config = r 'fzf.vim'
    }
    use 'lambdalisue/suda.vim'

    use {
      'tpope/vim-surround',
      requires = { 'tpope/vim-repeat' },
      config = misc.surround
    }

    use {
      'chaoren/vim-wordmotion',
      config = misc.wordmotion
    }

    use {
      'haya14busa/vim-asterisk',
      config = misc.asterisk
    }

    use {
      'rrethy/vim-hexokinase',
      run = 'make hexokinase'
    }
    use {
      'dstein64/nvim-scrollview',
      config = misc.scrollview
    }

    use 'stevearc/aerial.nvim'

    usec('christianchiarulli/nvcode-color-schemes.vim', 'colors.vim')

    use 'teal-language/vim-teal'
    use 'chr4/nginx.vim'
  end,
  {
    config = {
      git = {
        clone_timeout = 300
      }
    }
  }
})
