local mk_sourcer = require'before-plug.vim_utils'.mk_sourcer
local misc = require 'plug-config.misc'
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  execute 'packadd packer.nvim'
end

local plug = require('packer').startup(function()
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
  use {
    'hrsh7th/nvim-compe',
    after = 'nvim-lint'
  }
  use {
    'L3MON4D3/LuaSnip',
    after = 'nvim-compe'
  }
  use {
    'windwp/nvim-autopairs',
    after = 'LuaSnip',
    config = function()
      require 'plug-config.lsp'
      local npairs = require 'nvim-autopairs'
      npairs.setup()
      require'nvim-autopairs.completion.compe'.setup {
        map_cr = true
      }
      npairs.add_rules(require('nvim-autopairs.rules.endwise-lua'))
      npairs.remove_rule('\'')
      npairs.remove_rule('"')
      if vim.g.lsp_autostart then
        vim.cmd('LspStart')
        require'lint'.try_lint()
      end
    end
  }
  -- use { 'jackguo380/vim-lsp-cxx-highlight', after = 'nvim-autopairs' }

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
    branch = '0.5-compat',
    config = mk_sourcer 'plug-config.treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'

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
  use 'JoosepAlviste/nvim-ts-context-commentstring'

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
end)

return plug
