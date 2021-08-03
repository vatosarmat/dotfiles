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
  fzf = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/fzf"
  },
  ["fzf.vim"] = {
    config = { "vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "require 'plug-config.gitsigns'" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["nvcode-color-schemes.vim"] = {
    after = { "nvim-lspconfig" },
    loaded = true,
    only_config = true
  },
  ["nvim-dap"] = {
    config = { "require 'plug-config.dap'" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-dap"
  },
  ["nvim-lspconfig"] = {
    config = { "require 'plug-config.lsp'" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/igor/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
  },
  ["nvim-scrollview"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-scrollview"
  },
  ["nvim-tree.lua"] = {
    config = { "require 'plug-config.nvimtree'" },
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "require 'plug-config.treesitter'" },
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
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-asterisk"
  },
  ["vim-commentary"] = {
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
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-rooter"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-wordmotion"] = {
    loaded = true,
    path = "/home/igor/.local/share/nvim/site/pack/packer/start/vim-wordmotion"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-dap
time([[Config for nvim-dap]], true)
require 'plug-config.dap'
time([[Config for nvim-dap]], false)
-- Config for: fzf.vim
time([[Config for fzf.vim]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/fzf.vim')
time([[Config for fzf.vim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
require 'plug-config.treesitter'
time([[Config for nvim-treesitter]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/fugitive.vim')
time([[Config for vim-fugitive]], false)
-- Config for: nvcode-color-schemes.vim
time([[Config for nvcode-color-schemes.vim]], true)
vim.cmd('source $STD_PATH_CONFIG/plug-config/colors.vim')
time([[Config for nvcode-color-schemes.vim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
require 'plug-config.nvimtree'
time([[Config for nvim-tree.lua]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require 'plug-config.gitsigns'
time([[Config for gitsigns.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-lspconfig ]]

-- Config for: nvim-lspconfig
require 'plug-config.lsp'

time([[Sequenced loading]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
