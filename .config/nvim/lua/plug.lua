local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
  execute 'packadd packer.nvim'
end

local misc = require 'plug-config.misc'

require('packer').startup {
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

    local usec = function(path, name, disable)
      use {
        path,
        config = r(name),
        disable = disable,
      }
    end

    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'

    use {
      'neovim/nvim-lspconfig',
      requires = {
        'folke/neodev.nvim',
        'jose-elias-alvarez/null-ls.nvim',
        -- 'jose-elias-alvarez/nvim-lsp-ts-utils',
        'jose-elias-alvarez/typescript.nvim',
        'b0o/schemastore.nvim',
      },
      config = r 'lsp',
    }

    use {
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'windwp/nvim-autopairs',
      },
    }

    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      requires = {
        'nvim-treesitter/playground',
        'nvim-treesitter/nvim-treesitter-textobjects',
        'JoosepAlviste/nvim-ts-context-commentstring',
        'windwp/nvim-ts-autotag',
        'p00f/nvim-ts-rainbow',
        'danymat/neogen',
        -- 'nvim-treesitter/nvim-treesitter-angular'
      },
      config = r 'treesitter',
    }
    use {
      'numToStr/Comment.nvim',
      config = misc.Comment,
    }

    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          run = 'make',
        },
      },
      config = r 'telescope',
    }

    use 'kyazdani42/nvim-web-devicons'
    usec('kyazdani42/nvim-tree.lua', 'nvimtree')

    use {
      'mfussenegger/nvim-dap',
      requires = { 'jbyuki/one-small-step-for-vimkind', 'mxsdev/nvim-dap-vscode-js' },
      config = r 'dap',
    }

    usec('tpope/vim-fugitive', 'fugitive.vim')
    usec('lewis6991/gitsigns.nvim', 'gitsigns')

    use {
      'junegunn/fzf',
      run = ':call fzf#install()',
      requires = { 'junegunn/fzf.vim' },
      config = r 'fzf.vim',
    }
    use 'lambdalisue/suda.vim'

    use {
      'kevinhwang91/nvim-ufo',
      requires = 'kevinhwang91/promise-async',
      config = r 'ufo',
    }

    use {
      'machakann/vim-sandwich',
      config = r 'sandwich',
    }

    use {
      'mattn/emmet-vim',
      config = misc.emmet,
    }

    use {
      'andymass/vim-matchup',
      config = misc.matchup,
    }

    use {
      'chaoren/vim-wordmotion',
      config = misc.wordmotion,
    }

    use {
      'haya14busa/vim-asterisk',
      config = misc.asterisk,
    }

    use {
      'rrethy/vim-hexokinase',
      run = 'make hexokinase',
    }
    use {
      'dstein64/nvim-scrollview',
      config = misc.scrollview,
    }

    use 'teal-language/vim-teal'
    use 'chr4/nginx.vim'
    use 'jwalton512/vim-blade'
  end,
  {
    config = {
      git = {
        clone_timeout = 300,
      },
    },
  },
}
