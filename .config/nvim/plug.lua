local mk_sourcer = require'before-plug.vim_utils'.mk_sourcer
local misc = require 'plug-config.misc'
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  execute 'packadd packer.nvim'
end

local plug = require('packer').startup({
  function()
    use_rocks 'inspect'
    use_rocks 'penlight'
    use_rocks 'lua-cjson'
    use_rocks 'luasocket'
    use_rocks 'luasec'

    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'

    use {
      'folke/lua-dev.nvim',
      event = 'VimEnter'
    }
    use {
      'neovim/nvim-lspconfig',
      after = 'lua-dev.nvim'
    }
    use {
      'mfussenegger/nvim-lint',
      after = 'nvim-lspconfig'
    }
    use {
      'jose-elias-alvarez/null-ls.nvim',
      after = 'nvim-lspconfig'
    }
    use {
      'jose-elias-alvarez/nvim-lsp-ts-utils',
      after = 'null-ls.nvim'
    }
    -- compe, luasnip, auotpairs -> coq_nvim with deps
    use {
      'ms-jpq/coq_nvim',
      branch = 'coq',
      config = function()
        require 'plug-config.lsp'

        vim.g.coq_settings = {
          keymap = {
            manual_complete = '<C-space>',
            pre_select = true
          },
          auto_start = true
        }

        require('coq')
      end,
      requires = { 'ms-jpq/coq.artifacts', 'ms-jpq/coq.thirdparty', 'neovim/nvim-lspconfig' },
      after = { 'nvim-lint' },
      disable = true
    }
    use {
      'ms-jpq/coq.artifacts',
      branch = 'artifacts'
    }
    use {
      'ms-jpq/coq.thirdparty',
      branch = '3p'
    }
    use {
      'hrsh7th/nvim-cmp',
      requires = {
        -- snippet engine
        {
          'saadparwaiz1/cmp_luasnip',
          requires = {
            {
              'L3MON4D3/LuaSnip',
              after = 'nvim-lint'
            }
          },
          after = 'nvim-cmp'
        },
        -- sources
        {
          'hrsh7th/cmp-buffer',
          after = 'cmp_luasnip'
        },
        {
          'hrsh7th/cmp-nvim-lsp',
          after = 'cmp-buffer'
        },
        {
          'hrsh7th/cmp-path',
          after = 'cmp-nvim-lsp'
        },
        {
          'hrsh7th/cmp-nvim-lua',
          after = 'cmp-path'
        },
        {
          'windwp/nvim-autopairs',
          after = 'cmp-nvim-lua',
          config = function()
            require 'plug-config.lsp'
          end
        }
      },
      after = 'LuaSnip',
      disable = false
    }

    use 'nvim-telescope/telescope.nvim'

    use 'kyazdani42/nvim-web-devicons'
    use {
      'kyazdani42/nvim-tree.lua',
      config = mk_sourcer 'plug-config.nvimtree'
    }

    use {
      'mfussenegger/nvim-dap',
      config = mk_sourcer 'plug-config.dap'
    }
    use 'jbyuki/one-small-step-for-vimkind'

    use {
      'nvim-treesitter/nvim-treesitter',
      event = 'VimEnter',
      run = ':TSUpdate'
    }
    use {
      'nvim-treesitter/playground',
      after = 'nvim-treesitter'
    }
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      config = mk_sourcer 'plug-config.treesitter',
      after = 'nvim-treesitter'
    }

    use {
      'tpope/vim-fugitive',
      config = mk_sourcer '$STD_PATH_CONFIG/plug-config/fugitive.vim'
    }
    use {
      'lewis6991/gitsigns.nvim',
      config = mk_sourcer 'plug-config.gitsigns'
    }

    use {
      '~/.fzf',
      event = 'VimEnter',
      as = 'fzf'
    }
    use {
      'junegunn/fzf.vim',
      after = 'fzf',
      config = function()
        vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')
      end
    }
    use 'lambdalisue/suda.vim'

    use {
      'tpope/vim-surround',
      config = misc.surround
    }
    use 'tpope/vim-repeat'
    use {
      'tpope/vim-commentary',
      config = misc.commentary
    }
    use {
      'JoosepAlviste/nvim-ts-context-commentstring',
      after = { 'vim-commentary', 'nvim-treesitter' }
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

    use {
      'christianchiarulli/nvcode-color-schemes.vim',
      config = mk_sourcer '$STD_PATH_CONFIG/plug-config/colors.vim'
    }

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

return plug
