local map = require'before-plug.vim_utils'.map
local mk_sourcer = require'before-plug.vim_utils'.mk_sourcer
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

  use {
    'neovim/nvim-lspconfig',
    config = mk_sourcer 'plug-config.lsp',
    after = 'nvcode-color-schemes.vim'
  }

  use 'nvim-telescope/telescope.nvim'

  use 'kyazdani42/nvim-web-devicons'
  use { 'kyazdani42/nvim-tree.lua', config = mk_sourcer 'plug-config.nvimtree' }

  use { 'mfussenegger/nvim-dap', config = mk_sourcer 'plug-config.dap' }
  use 'jbyuki/one-small-step-for-vimkind'

  use {
    'nvim-treesitter/nvim-treesitter',
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

  use { 'tpope/vim-surround', config = surround }
  use 'tpope/vim-repeat'
  use { 'tpope/vim-commentary', config = commentary }
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  use { 'chaoren/vim-wordmotion', config = wordmotion }
  use { 'haya14busa/vim-asterisk', config = asterisk }

  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }
  use { 'dstein64/nvim-scrollview', config = scrollview }

  use {
    'christianchiarulli/nvcode-color-schemes.vim',
    config = mk_sourcer '$STD_PATH_CONFIG/plug-config/colors.vim'
  }
end)

function commentary()
  -- function comment(a)
  --   require'ts_context_commentstring.internal'.update_commentstring()
  --   if a == 1 then
  --     return "<Plug>Commentary"
  --   else
  --     return "<Plug>CommentaryLine"
  --   end
  -- end
  local opts = { expr = 1, noremap = false }
  map('n', 'C-_', '<Plug>Commentary', opts)
  map('x', 'C-_', '<Plug>CommentaryLine', opts)
end

function asterisk()
  local opts = { noremap = false }
  map({ 'n', 'x', 'o' }, '*', '<Plug>(asterisk-z*)', opts)
  map({ 'n', 'x', 'o' }, '#', '<Plug>(asterisk-z#)', opts)
  map({ 'n', 'x', 'o' }, 'g*', '<Plug>(asterisk-gz*)', opts)
  map({ 'n', 'x', 'o' }, 'g#', '<Plug>(asterisk-gz#)', opts)
end

function wordmotion()
  vim.g.wordmotion_nomap = 1
  local opts = { noremap = false }
  map({ 'n', 'x', 'o' }, '<M-w>', '<Plug>WordMotion_w', opts)
  map({ 'n', 'x', 'o' }, '<M-b>', '<Plug>WordMotion_b', opts)
  map({ 'n', 'x', 'o' }, '<M-e>', '<Plug>WordMotion_e', opts)
  map({ 'o' }, 'a<M-w>', '<Plug>WordMotion_aw', opts)
  map({ 'o' }, 'i<M-w>', '<Plug>WordMotion_iw', opts)
end

function surround()
  vim.g.surround_indent = 1
  map('x', 's', 'S', { noremap = false })
end

function scrollview()
  vim.g.scrollview_on_startup = 1
  vim.g.scrollview_winblend = 60
  vim.g.scrollview_column = 1
  vim.g.scrollview_auto_mouse = 0
end

return plug
