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
  LuaSnip = {
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["aerial.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["cmp-buffer"] = {
    after_files = { "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-buffer/after/plugin/cmp_buffer.lua" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    after_files = { "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lsp/after/plugin/cmp_nvim_lsp.lua" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    after_files = { "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-path/after/plugin/cmp_path.lua" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    after_files = { "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp_luasnip/after/plugin/cmp_luasnip.lua" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  fzf = {
    after = { "fzf.vim" },
    config = { "\27LJ\2\nO\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0000source $STD_PATH_CONFIG/plug-config/fzf.vim\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/fzf",
    url = "/home/igor/.fzf",
    wants = { "fzf.vim" }
  },
  ["fzf.vim"] = {
    load_after = {
      fzf = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n4\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\25plug-config.gitsigns\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["lua-dev.nvim"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/lua-dev.nvim",
    url = "https://github.com/folke/lua-dev.nvim"
  },
  ["nginx.vim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nginx.vim",
    url = "https://github.com/chr4/nginx.vim"
  },
  ["null-ls.nvim"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvcode-color-schemes.vim"] = {
    config = { "\27LJ\2\nR\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0003source $STD_PATH_CONFIG/plug-config/colors.vim\bcmd\bvim\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvcode-color-schemes.vim",
    url = "https://github.com/christianchiarulli/nvcode-color-schemes.vim"
  },
  ["nvim-autopairs"] = {
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    after = { "cmp-buffer", "cmp-path", "cmp_luasnip", "nvim-autopairs", "LuaSnip", "cmp-nvim-lsp" },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp",
    wants = { "LuaSnip" }
  },
  ["nvim-dap"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plug-config.dap\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-lsp-ts-utils"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-lsp-ts-utils",
    url = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    after = { "lua-dev.nvim", "null-ls.nvim", "nvim-lsp-ts-utils" },
    config = { "\27LJ\2\n#\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\blsp\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig",
    wants = { "lua-dev.nvim", "null-ls.nvim", "nvim-lsp-ts-utils", "nvim-cmp", "telescope.nvim", "nvim-treesitter" }
  },
  ["nvim-scrollview"] = {
    config = { "\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-scrollview",
    url = "https://github.com/dstein64/nvim-scrollview"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n4\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\25plug-config.nvimtree\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "playground", "nvim-treesitter-textobjects", "nvim-ts-context-commentstring" },
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27plug-config.treesitter\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-context-commentstring"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-ts-context-commentstring",
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
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/playground",
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
    config = { "\27LJ\2\n5\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\26plug-config.telescope\frequire\0" },
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
  ["vim-commentary"] = {
    config = { "\27LJ\2\n°\1\0\0\b\0\t\0\0186\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\5\0'\6\b\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>Commentary\6x\25<Plug>CommentaryLine\n<C-_>\6n\1\0\1\fnoremap\1\bmap\14vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-fugitive"] = {
    config = { "\27LJ\2\nT\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0005source $STD_PATH_CONFIG/plug-config/fugitive.vim\bcmd\bvim\0" },
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
-- Config for: vim-asterisk
time([[Config for vim-asterisk]], true)
try_loadstring("\27LJ\2\nÅ\2\0\0\b\0\r\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1K\0\1\0\25<Plug>(asterisk-gz#)\ag#\25<Plug>(asterisk-gz*)\ag*\24<Plug>(asterisk-z#)\6#\24<Plug>(asterisk-z*)\6*\bnxo\1\0\1\fnoremap\1\bmap\14vim_utils\frequire\0", "config", "vim-asterisk")
time([[Config for vim-asterisk]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n4\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\25plug-config.nvimtree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n5\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\26plug-config.telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: nvim-dap
time([[Config for nvim-dap]], true)
try_loadstring("\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plug-config.dap\frequire\0", "config", "nvim-dap")
time([[Config for nvim-dap]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
try_loadstring("\27LJ\2\nT\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0005source $STD_PATH_CONFIG/plug-config/fugitive.vim\bcmd\bvim\0", "config", "vim-fugitive")
time([[Config for vim-fugitive]], false)
-- Config for: nvcode-color-schemes.vim
time([[Config for nvcode-color-schemes.vim]], true)
try_loadstring("\27LJ\2\nR\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0003source $STD_PATH_CONFIG/plug-config/colors.vim\bcmd\bvim\0", "config", "nvcode-color-schemes.vim")
time([[Config for nvcode-color-schemes.vim]], false)
-- Config for: nvim-scrollview
time([[Config for nvim-scrollview]], true)
try_loadstring("\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0", "config", "nvim-scrollview")
time([[Config for nvim-scrollview]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n4\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\25plug-config.gitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: vim-surround
time([[Config for vim-surround]], true)
try_loadstring("\27LJ\2\nﬁ\1\0\0\b\0\15\0\0286\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\n\0'\5\b\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\f\0'\5\r\0'\6\14\0\18\a\1\0B\2\5\1K\0\1\0\agE\6S\bnxo\20<Plug>VSurround\6x\20<Plug>Ysurround\6,\6n\1\0\1\fnoremap\1\20surround_indent\6g\bvim\bmap\14vim_utils\frequire\0", "config", "vim-surround")
time([[Config for vim-surround]], false)
-- Config for: vim-commentary
time([[Config for vim-commentary]], true)
try_loadstring("\27LJ\2\n°\1\0\0\b\0\t\0\0186\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\5\0'\6\b\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>Commentary\6x\25<Plug>CommentaryLine\n<C-_>\6n\1\0\1\fnoremap\1\bmap\14vim_utils\frequire\0", "config", "vim-commentary")
time([[Config for vim-commentary]], false)
-- Config for: vim-wordmotion
time([[Config for vim-wordmotion]], true)
try_loadstring("\27LJ\2\n™\5\0\0\b\0!\0P6\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0016\1\3\0009\1\4\0015\2\a\0=\2\6\0015\1\b\0\18\2\0\0'\4\t\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\16\0'\6\17\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\18\0'\6\19\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\20\0'\6\21\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\22\0'\6\23\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\24\0'\6\25\0\18\a\1\0B\2\5\1\18\2\0\0'\4\t\0'\5\26\0'\6\27\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\29\0'\6\30\0\18\a\1\0B\2\5\1\18\2\0\0'\4\28\0'\5\31\0'\6 \0\18\a\1\0B\2\5\1K\0\1\0\24<Plug>WordMotion_iw\vi<M-w>\24<Plug>WordMotion_aw\va<M-w>\6o\24<Plug>WordMotion_ge\n<M-s>\23<Plug>WordMotion_e\n<M-e>\23<Plug>WordMotion_b\n<M-b>\23<Plug>WordMotion_w\n<M-w>\24<Plug>WordMotion_gE\6s\23<Plug>WordMotion_E\6e\23<Plug>WordMotion_B\6b\23<Plug>WordMotion_W\6w\agE\6S\bnxo\1\0\1\fnoremap\1\1\2\0\0\19[^[:keyword:]] wordmotion_uppercase_spaces\21wordmotion_nomap\6g\bvim\bmap\14vim_utils\frequire\0", "config", "vim-wordmotion")
time([[Config for vim-wordmotion]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'fzf', 'nvim-treesitter', 'nvim-lspconfig'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
