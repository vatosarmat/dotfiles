-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    config = { "\27LJ\2\nﬂ\3\0\1\a\0\22\00066\1\0\0009\1\1\0019\1\2\1\a\1\3\0X\0010Ä6\1\4\0'\3\5\0B\1\2\0029\2\6\0009\3\6\0019\3\a\3\5\2\3\0X\2\2Ä'\2\b\0X\3\1Ä'\2\t\0+\3\0\0009\4\6\0009\5\6\0019\5\n\5\5\4\5\0X\4\aÄ6\4\4\0'\6\v\0B\4\2\0029\4\f\4B\4\1\2\18\3\4\0X\4\16Ä9\4\r\0009\5\r\0019\5\14\5\4\4\5\0X\4\5Ä9\4\r\0009\5\r\0019\5\15\5\5\4\5\0X\4\6Ä6\4\4\0'\6\v\0B\4\2\0029\4\16\4B\4\1\2\18\3\4\0006\4\4\0'\6\17\0B\4\2\0029\4\18\0045\6\19\0=\2\20\6=\3\21\6D\4\2\0K\0\1\0\rlocation\bkey\1\0\0\28calculate_commentstring&ts_context_commentstring.internal\30get_visual_start_location\6V\6v\fcmotion\24get_cursor_location#ts_context_commentstring.utils\nblock\16__multiline\14__default\tline\nctype\18Comment.utils\frequire\20typescriptreact\rfiletype\abo\bvimN\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\rpre_hook\1\0\0\0\nsetup\fComment\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  fzf = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/fzf",
    url = "/home/igor/.fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plug-config.gitsigns')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/lua-dev.nvim",
    url = "https://github.com/folke/lua-dev.nvim"
  },
  ["nginx.vim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nginx.vim",
    url = "https://github.com/chr4/nginx.vim"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvcode-color-schemes.vim"] = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/colors.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvcode-color-schemes.vim",
    url = "https://github.com/christianchiarulli/nvcode-color-schemes.vim"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-dap"] = {
    config = { "require('plug-config.dap')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-lsp-ts-utils"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-lsp-ts-utils",
    url = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    config = { "require('lsp')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-scrollview"] = {
    config = { "\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-scrollview",
    url = "https://github.com/dstein64/nvim-scrollview"
  },
  ["nvim-tree.lua"] = {
    config = { "require('plug-config.nvimtree')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "require('plug-config.treesitter')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-autotag"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["one-small-step-for-vimkind"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/one-small-step-for-vimkind",
    url = "https://github.com/jbyuki/one-small-step-for-vimkind"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["suda.vim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/suda.vim",
    url = "https://github.com/lambdalisue/suda.vim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    config = { "require('plug-config.telescope')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-asterisk"] = {
    config = { "\27LJ\2\nÅ\2\0\0\b\0\r\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1K\0\1\0\25<Plug>(asterisk-gz#)\ag#\25<Plug>(asterisk-gz*)\ag*\24<Plug>(asterisk-z#)\6#\24<Plug>(asterisk-z*)\6*\bnxo\1\0\1\fnoremap\1\bmap\14vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-asterisk",
    url = "https://github.com/haya14busa/vim-asterisk"
  },
  ["vim-fugitive"] = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/fugitive.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-hexokinase"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-hexokinase",
    url = "https://github.com/rrethy/vim-hexokinase"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-surround"] = {
    config = { "\27LJ\2\nﬁ\1\0\0\b\0\15\0\0286\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\n\0'\5\b\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\f\0'\5\r\0'\6\14\0\18\a\1\0B\2\5\1K\0\1\0\agE\6S\bnxo\20<Plug>VSurround\6x\20<Plug>Ysurround\6,\6n\1\0\1\fnoremap\1\20surround_indent\6g\bvim\bmap\14vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-teal"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-teal",
    url = "https://github.com/teal-language/vim-teal"
  },
  ["vim-wordmotion"] = {
    config = { "\27LJ\2\n™\5\0\0\b\0!\0P6\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0016\1\3\0009\1\4\0015\2\a\0=\2\6\0015\1\b\0\18\2\0\0'\4\t\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\16\0'\6\17\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\18\0'\6\19\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\20\0'\6\21\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\22\0'\6\23\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\24\0'\6\25\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\26\0'\6\27\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\29\0'\6\30\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\31\0'\6 \0\18\a\1\0B\2\5\1K\0\1\0\24<Plug>WordMotion_iw\vi<M-w>\24<Plug>WordMotion_aw\va<M-w>\6o\24<Plug>WordMotion_ge\n<M-s>\23<Plug>WordMotion_e\n<M-e>\23<Plug>WordMotion_b\n<M-b>\23<Plug>WordMotion_w\n<M-w>\24<Plug>WordMotion_gE\6s\23<Plug>WordMotion_E\6e\23<Plug>WordMotion_B\6b\23<Plug>WordMotion_W\6w\agE\6S\bnxo\1\0\1\fnoremap\1\1\2\0\0\19[^[:keyword:]] wordmotion_uppercase_spaces\21wordmotion_nomap\6g\bvim\bmap\14vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-wordmotion",
    url = "https://github.com/chaoren/vim-wordmotion"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
require('lsp')
time([[Config for nvim-lspconfig]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
require('plug-config.telescope')
time([[Config for telescope.nvim]], false)
-- Config for: vim-surround
time([[Config for vim-surround]], true)
try_loadstring("\27LJ\2\nﬁ\1\0\0\b\0\15\0\0286\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\n\0'\5\b\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\f\0'\5\r\0'\6\14\0\18\a\1\0B\2\5\1K\0\1\0\agE\6S\bnxo\20<Plug>VSurround\6x\20<Plug>Ysurround\6,\6n\1\0\1\fnoremap\1\20surround_indent\6g\bvim\bmap\14vim_utils\frequire\0", "config", "vim-surround")
time([[Config for vim-surround]], false)
-- Config for: nvcode-color-schemes.vim
time([[Config for nvcode-color-schemes.vim]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/colors.vim')
time([[Config for nvcode-color-schemes.vim]], false)
-- Config for: vim-wordmotion
time([[Config for vim-wordmotion]], true)
try_loadstring("\27LJ\2\n™\5\0\0\b\0!\0P6\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0016\1\3\0009\1\4\0015\2\a\0=\2\6\0015\1\b\0\18\2\0\0'\4\t\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\16\0'\6\17\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\18\0'\6\19\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\20\0'\6\21\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\22\0'\6\23\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\24\0'\6\25\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\26\0'\6\27\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\29\0'\6\30\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\31\0'\6 \0\18\a\1\0B\2\5\1K\0\1\0\24<Plug>WordMotion_iw\vi<M-w>\24<Plug>WordMotion_aw\va<M-w>\6o\24<Plug>WordMotion_ge\n<M-s>\23<Plug>WordMotion_e\n<M-e>\23<Plug>WordMotion_b\n<M-b>\23<Plug>WordMotion_w\n<M-w>\24<Plug>WordMotion_gE\6s\23<Plug>WordMotion_E\6e\23<Plug>WordMotion_B\6b\23<Plug>WordMotion_W\6w\agE\6S\bnxo\1\0\1\fnoremap\1\1\2\0\0\19[^[:keyword:]] wordmotion_uppercase_spaces\21wordmotion_nomap\6g\bvim\bmap\14vim_utils\frequire\0", "config", "vim-wordmotion")
time([[Config for vim-wordmotion]], false)
-- Config for: nvim-dap
time([[Config for nvim-dap]], true)
require('plug-config.dap')
time([[Config for nvim-dap]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/fugitive.vim')
time([[Config for vim-fugitive]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require('plug-config.gitsigns')
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
require('plug-config.nvimtree')
time([[Config for nvim-tree.lua]], false)
-- Config for: vim-asterisk
time([[Config for vim-asterisk]], true)
try_loadstring("\27LJ\2\nÅ\2\0\0\b\0\r\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1K\0\1\0\25<Plug>(asterisk-gz#)\ag#\25<Plug>(asterisk-gz*)\ag*\24<Plug>(asterisk-z#)\6#\24<Plug>(asterisk-z*)\6*\bnxo\1\0\1\fnoremap\1\bmap\14vim_utils\frequire\0", "config", "vim-asterisk")
time([[Config for vim-asterisk]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
require('plug-config.treesitter')
time([[Config for nvim-treesitter]], false)
-- Config for: Comment.nvim
time([[Config for Comment.nvim]], true)
try_loadstring("\27LJ\2\nﬂ\3\0\1\a\0\22\00066\1\0\0009\1\1\0019\1\2\1\a\1\3\0X\0010Ä6\1\4\0'\3\5\0B\1\2\0029\2\6\0009\3\6\0019\3\a\3\5\2\3\0X\2\2Ä'\2\b\0X\3\1Ä'\2\t\0+\3\0\0009\4\6\0009\5\6\0019\5\n\5\5\4\5\0X\4\aÄ6\4\4\0'\6\v\0B\4\2\0029\4\f\4B\4\1\2\18\3\4\0X\4\16Ä9\4\r\0009\5\r\0019\5\14\5\4\4\5\0X\4\5Ä9\4\r\0009\5\r\0019\5\15\5\5\4\5\0X\4\6Ä6\4\4\0'\6\v\0B\4\2\0029\4\16\4B\4\1\2\18\3\4\0006\4\4\0'\6\17\0B\4\2\0029\4\18\0045\6\19\0=\2\20\6=\3\21\6D\4\2\0K\0\1\0\rlocation\bkey\1\0\0\28calculate_commentstring&ts_context_commentstring.internal\30get_visual_start_location\6V\6v\fcmotion\24get_cursor_location#ts_context_commentstring.utils\nblock\16__multiline\14__default\tline\nctype\18Comment.utils\frequire\20typescriptreact\rfiletype\abo\bvimN\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\rpre_hook\1\0\0\0\nsetup\fComment\frequire\0", "config", "Comment.nvim")
time([[Config for Comment.nvim]], false)
-- Config for: fzf
time([[Config for fzf]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')
time([[Config for fzf]], false)
-- Config for: nvim-scrollview
time([[Config for nvim-scrollview]], true)
try_loadstring("\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0", "config", "nvim-scrollview")
time([[Config for nvim-scrollview]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
