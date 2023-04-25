local func = require 'pl.func'
local reduce = require'pl.tablex'.reduce
local assert_key_mode = require'vim_utils'.assert_key_mode
local buf_set_map = func.bind(vim.api.nvim_buf_set_keymap, 0, func._1, func._2, func._3, func._4)
local buf_del_map = func.bind(vim.api.nvim_buf_del_keymap, 0, func._1, func._2)

local M = {}

local function assert_defined(name)
  local shortmap = _U.shortmap[name]
  assert(shortmap, 'Shortmap \'' .. name .. '\' not defined')
  return shortmap
end

local function buf_get_map(mode)
  local raw = vim.api.nvim_buf_get_keymap(0, mode)
  local function f(dict, item)
    dict[item.lhs] = {
      lhs = item.lhs,
      rhs = item.rhs,
      mode = mode,
      opts = {
        expr = item.expr,
        silent = item.silent,
        nowait = item.nowait,
        script = item.script,
        noremap = item.noremap
      }
    }
    return dict
  end
  return reduce(f, raw, {})
end

-- mapping is {modes, lhs, rhs}
-- lhs supposed to be short, while rhs supposed to be <leader><prefix><op-key>
-- it is all remap-based
function M.define(name, mappings)
  assert(not _U.shortmap[name], 'Shortmap \'' .. name .. '\' already defined')
  local function f(full_mappings, abbreved_mapping)
    local modes, lhs, rhs = unpack(abbreved_mapping)
    modes:gsub('.', function(m)
      assert_key_mode(m)
      if not full_mappings[m] then
        full_mappings[m] = {}
      end
      assert(not full_mappings[m][lhs], 'Shortmapping ' .. m .. lhs .. ' already defined')

      full_mappings[m][lhs] = rhs
    end)
    return full_mappings
  end

  _U.shortmap[name] = { name, reduce(f, mappings, {}) }
end

-- Do actual mapping, if something overwritten, save it
function M.enable(name)
  if vim.b.shortmap and vim.b.shortmap[1] ~= name then
    error('Shortmap ' .. vim.b.shortmap[1] .. ' already enabled')
  end

  local shortmap = assert_defined(name)
  local mappings = shortmap[2]
  local current_keymaps = {}
  local overwritten_keymaps = {}
  for mode, mode_maps in pairs(mappings) do
    current_keymaps[mode] = buf_get_map(mode)
    overwritten_keymaps[mode] = {}
    for lhs, rhs in pairs(mode_maps) do
      local maybe_overwritten = current_keymaps[mode][lhs]
      if maybe_overwritten then
        overwritten_keymaps[mode][lhs] = maybe_overwritten
      end
      buf_set_map(mode, lhs, rhs, {
        noremap = false
      })
    end
  end
  vim.b.overwritten_keymaps = overwritten_keymaps
  vim.b.shortmap = shortmap
end

-- Delete mappings, restore overwritten
function M.disable()
  local shortmap = vim.b.shortmap
  if not shortmap then
    return
  end

  local overwritten_keymaps = vim.b.overwritten_keymaps
  local mappings = shortmap[2]
  for mode, mode_maps in pairs(mappings) do
    for lhs, _ in pairs(mode_maps) do
      buf_del_map(mode, lhs)
      local maybe_overwritten = overwritten_keymaps[mode][lhs]
      if maybe_overwritten then
        buf_set_map(mode, maybe_overwritten.lhs, maybe_overwritten.rhs, maybe_overwritten.opts)
      end
    end
  end
  vim.b.overwritten_keymaps = {}
  vim.b.shortmap = nil
end

function M.toggle(name)
  local shortmap = vim.b.shortmap
  if shortmap then
    M.disable()
  else
    M.enable(name)
  end
end

return M
