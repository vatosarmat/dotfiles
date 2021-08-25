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
  local success, result = pcall(loadstring(s))
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
    after = { "nvim-autopairs" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/LuaSnip"
  },
  fzf = {
    after = { "fzf.vim" },
    load_after = {
      ["vim-rooter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/fzf"
  },
  ["fzf.vim"] = {
    config = { "\27LJ\2\nO\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0000source $STD_PATH_CONFIG/plug-config/fzf.vim\bcmd\bvim\0" },
    load_after = {
      fzf = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "if not pcall(require, 'plug-config.gitsigns') then print('plug-config.gitsigns config failed') end " },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["nvcode-color-schemes.vim"] = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/colors.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvcode-color-schemes.vim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\nÇ\2\0\0\6\0\v\0\0266\0\0\0'\2\1\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0029\1\3\0B\1\1\0016\1\0\0'\3\4\0B\1\2\0029\1\3\0015\3\5\0B\1\2\0019\1\6\0006\3\0\0'\5\a\0B\3\2\0A\1\0\0019\1\b\0'\3\t\0B\1\2\0019\1\b\0'\3\n\0B\1\2\1K\0\1\0\6\"\6'\16remove_rule%nvim-autopairs.rules.endwise-lua\14add_rules\1\0\1\vmap_cr\2$nvim-autopairs.completion.compe\nsetup\19nvim-autopairs\20plug-config.lsp\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-autopairs"
  },
  ["nvim-compe"] = {
    after = { "LuaSnip" },
    after_files = { "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    loaded = true,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-dap"] = {
    config = { "if not pcall(require, 'plug-config.dap') then print('plug-config.dap config failed') end " },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-dap"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-scrollview"] = {
    config = { "\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-scrollview"
  },
  ["nvim-tree.lua"] = {
    config = { "if not pcall(require, 'plug-config.nvimtree') then print('plug-config.nvimtree config failed') end " },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "if not pcall(require, 'plug-config.treesitter') then print('plug-config.treesitter config failed') end " },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["one-small-step-for-vimkind"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/one-small-step-for-vimkind"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["suda.vim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/suda.vim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-asterisk"] = {
    config = { "\27LJ\2\nç\2\0\0\b\0\r\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1K\0\1\0\25<Plug>(asterisk-gz#)\ag#\25<Plug>(asterisk-gz*)\ag*\24<Plug>(asterisk-z#)\6#\24<Plug>(asterisk-z*)\6*\bnxo\1\0\1\fnoremap\1\bmap\26before-plug.vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-asterisk"
  },
  ["vim-commentary"] = {
    config = { "\27LJ\2\n≠\1\0\0\b\0\t\0\0186\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\5\0'\6\b\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>Commentary\6x\25<Plug>CommentaryLine\n<C-_>\6n\1\0\1\fnoremap\1\bmap\26before-plug.vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-fugitive"] = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/fugitive.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-hexokinase"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-hexokinase"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rooter"] = {
    after = { "fzf" },
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29plug-config.project_type\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/vim-rooter"
  },
  ["vim-surround"] = {
    config = { "\27LJ\2\nÃ\1\0\0\b\0\f\0\0226\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>VgSurround\agS\20<Plug>VSurround\ags\6x\1\0\1\fnoremap\1\20surround_indent\6g\bvim\bmap\26before-plug.vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-teal"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-teal"
  },
  ["vim-wordmotion"] = {
    config = { "\27LJ\2\n•\3\0\0\b\0\21\0.6\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1\18\2\0\0'\4\16\0'\5\17\0'\6\18\0\18\a\1\0B\2\5\1\18\2\0\0'\4\16\0'\5\19\0'\6\20\0\18\a\1\0B\2\5\1K\0\1\0\24<Plug>WordMotion_iw\vi<M-w>\24<Plug>WordMotion_aw\va<M-w>\6o\24<Plug>WordMotion_ge\n<M-s>\23<Plug>WordMotion_e\n<M-e>\23<Plug>WordMotion_b\n<M-b>\23<Plug>WordMotion_w\n<M-w>\bnxo\1\0\1\fnoremap\1\21wordmotion_nomap\6g\bvim\bmap\26before-plug.vim_utils\frequire\0" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-wordmotion"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/fugitive.vim')
time([[Config for vim-fugitive]], false)
-- Config for: nvim-dap
time([[Config for nvim-dap]], true)
if not pcall(require, 'plug-config.dap') then print('plug-config.dap config failed') end 
time([[Config for nvim-dap]], false)
-- Config for: nvim-scrollview
time([[Config for nvim-scrollview]], true)
try_loadstring("\27LJ\2\n£\1\0\0\2\0\6\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1<\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\26scrollview_auto_mouse\22scrollview_column\24scrollview_winblend\26scrollview_on_startup\6g\bvim\0", "config", "nvim-scrollview")
time([[Config for nvim-scrollview]], false)
-- Config for: vim-wordmotion
time([[Config for vim-wordmotion]], true)
try_loadstring("\27LJ\2\n•\3\0\0\b\0\21\0.6\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1\18\2\0\0'\4\16\0'\5\17\0'\6\18\0\18\a\1\0B\2\5\1\18\2\0\0'\4\16\0'\5\19\0'\6\20\0\18\a\1\0B\2\5\1K\0\1\0\24<Plug>WordMotion_iw\vi<M-w>\24<Plug>WordMotion_aw\va<M-w>\6o\24<Plug>WordMotion_ge\n<M-s>\23<Plug>WordMotion_e\n<M-e>\23<Plug>WordMotion_b\n<M-b>\23<Plug>WordMotion_w\n<M-w>\bnxo\1\0\1\fnoremap\1\21wordmotion_nomap\6g\bvim\bmap\26before-plug.vim_utils\frequire\0", "config", "vim-wordmotion")
time([[Config for vim-wordmotion]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
if not pcall(require, 'plug-config.nvimtree') then print('plug-config.nvimtree config failed') end 
time([[Config for nvim-tree.lua]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
if not pcall(require, 'plug-config.gitsigns') then print('plug-config.gitsigns config failed') end 
time([[Config for gitsigns.nvim]], false)
-- Config for: vim-asterisk
time([[Config for vim-asterisk]], true)
try_loadstring("\27LJ\2\nç\2\0\0\b\0\r\0\0306\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1K\0\1\0\25<Plug>(asterisk-gz#)\ag#\25<Plug>(asterisk-gz*)\ag*\24<Plug>(asterisk-z#)\6#\24<Plug>(asterisk-z*)\6*\bnxo\1\0\1\fnoremap\1\bmap\26before-plug.vim_utils\frequire\0", "config", "vim-asterisk")
time([[Config for vim-asterisk]], false)
-- Config for: nvcode-color-schemes.vim
time([[Config for nvcode-color-schemes.vim]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/colors.vim')
time([[Config for nvcode-color-schemes.vim]], false)
-- Config for: vim-commentary
time([[Config for vim-commentary]], true)
try_loadstring("\27LJ\2\n≠\1\0\0\b\0\t\0\0186\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\5\0'\6\b\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>Commentary\6x\25<Plug>CommentaryLine\n<C-_>\6n\1\0\1\fnoremap\1\bmap\26before-plug.vim_utils\frequire\0", "config", "vim-commentary")
time([[Config for vim-commentary]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
if not pcall(require, 'plug-config.treesitter') then print('plug-config.treesitter config failed') end 
time([[Config for nvim-treesitter]], false)
-- Config for: vim-surround
time([[Config for vim-surround]], true)
try_loadstring("\27LJ\2\nÃ\1\0\0\b\0\f\0\0226\0\0\0'\2\1\0B\0\2\0029\0\2\0006\1\3\0009\1\4\1)\2\1\0=\2\5\0015\1\6\0\18\2\0\0'\4\a\0'\5\b\0'\6\t\0\18\a\1\0B\2\5\1\18\2\0\0'\4\a\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\1K\0\1\0\21<Plug>VgSurround\agS\20<Plug>VSurround\ags\6x\1\0\1\fnoremap\1\20surround_indent\6g\bvim\bmap\26before-plug.vim_utils\frequire\0", "config", "vim-surround")
time([[Config for vim-surround]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-compe ]]
vim.cmd [[ packadd LuaSnip ]]
vim.cmd [[ packadd nvim-autopairs ]]

-- Config for: nvim-autopairs
try_loadstring("\27LJ\2\nÇ\2\0\0\6\0\v\0\0266\0\0\0'\2\1\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0029\1\3\0B\1\1\0016\1\0\0'\3\4\0B\1\2\0029\1\3\0015\3\5\0B\1\2\0019\1\6\0006\3\0\0'\5\a\0B\3\2\0A\1\0\0019\1\b\0'\3\t\0B\1\2\0019\1\b\0'\3\n\0B\1\2\1K\0\1\0\6\"\6'\16remove_rule%nvim-autopairs.rules.endwise-lua\14add_rules\1\0\1\vmap_cr\2$nvim-autopairs.completion.compe\nsetup\19nvim-autopairs\20plug-config.lsp\frequire\0", "config", "nvim-autopairs")

time([[Sequenced loading]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'vim-rooter'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
