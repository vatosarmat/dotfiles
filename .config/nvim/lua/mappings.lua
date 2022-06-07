local api = vim.api
local bind1 = require'pl.func'.bind1

local function is_space_before()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local function feed_keys(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
end

local function map_completion()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  local set = vim.keymap.set
  local iset = bind1(set, 'i')

  iset('<Tab>', function()
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.expandable() then
      luasnip.expand()
    else
      if is_space_before() then
        feed_keys '<Tab>'
      else
        cmp.complete()
      end
    end
  end)
  iset('<M-Tab>', cmp.complete)
  iset('<C-y>', cmp.confirm)
  iset('<C-M-y>', cmp.close)
  iset('<C-e>', function()
    if cmp.visible() then
      cmp.abort()
    else
      feed_keys '<End>'
    end
  end)

  iset('<C-f>', cmp.mapping.scroll_docs(2))
  iset('<C-b>', cmp.mapping.scroll_docs(-2))

  iset('<C-n>', function()
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.jumpable() then
      luasnip.jump(1)
    else
    end
  end)
  iset('<C-p>', function()
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable() then
      luasnip.jump(-1)
    else
    end
  end)
end

do
  map_completion()
end
