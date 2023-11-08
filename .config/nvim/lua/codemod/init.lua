local utils = require 'utils'
local ts_utils = require 'nvim-treesitter.ts_utils'
local ts_indent = require 'nvim-treesitter.indent'
local keymap = vim.keymap

local function language_wrap(name, func)
  return function()
    local language = vim.b.language
    if language and language[name] then
      func(language[name])
    else
      vim.print(('`%s` not implemented for `%s`'):format(name, vim.bo.filetype))
    end
  end
end

local language_export = language_wrap('export', function(export)
  local target = vim.treesitter.get_node_text(ts_utils.get_node_at_cursor(0), 0)

  vim.fn.append(vim.fn.line '$', export(target))
end)

local language_print = language_wrap('print', function(print)
  local target = vim.treesitter.get_node_text(ts_utils.get_node_at_cursor(0), 0)

  local line = vim.fn.line '.'
  local indent = ts_indent.get_indent(line)
  vim.fn.append(line - 1, {
    utils.times(' ', indent) .. print(([['\n\n%s:']]):format(target)),
    utils.times(' ', indent) .. print(target),
  })
end)

keymap.set('n', '<leader>ce', language_export)
keymap.set('n', '<leader>cp', language_print)
