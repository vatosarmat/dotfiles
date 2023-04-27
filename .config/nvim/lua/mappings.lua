local api = vim.api
local bind1 = require'pl.func'.bind1
local bind = require'pl.func'.bind
local vu = require 'vim_utils'

local function map_completion()
  local function is_space_before()
    local col = vim.fn.col '.' - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
  end

  local function feed_keys(keys)
    api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
  end

  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  local set = vim.keymap.set
  local iset = bind1(set, 'i')

  local function complete_sources(...)
    return cmp.complete {
      config = {
        sources = vim.tbl_map(function(v)
          return {
            name = v
          }
        end, pack(...))
      }
    }
  end

  -- snippet
  iset('<M-Tab>', function()
    cmp.complete({
      reason = cmp.ContextReason.Manual,
      config = {
        sorting = {
          comparators = {
            function(a, b)
              return vim.stricmp(b.completion_item.label, a.completion_item.label) > 0
            end
          }
        },
        sources = {
          {
            name = 'luasnip'
          }
        }
      }
    })
  end)
  iset('<M-i>', luasnip.expand)
  -- lsp
  iset('<C-j>', function()
    if cmp.visible() then
      cmp.select_next_item()
    else
      complete_sources('nvim_lsp', 'nvim_lua')
    end
  end)
  iset('<C-y>', cmp.confirm)
  iset('<C-M-y>', cmp.close)
  iset('<C-e>', function()
    if cmp.visible() then
      cmp.abort()
    else
      feed_keys '<End>'
    end
  end)

  iset('<C-f>', cmp.mapping.scroll_docs(1))
  iset('<C-b>', cmp.mapping.scroll_docs(-1))

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

local function map_spell()
  local set = vim.keymap.set
  local nset = function(lhs, rhs, opts)
    return set('n', '<leader>a' .. lhs, rhs, opts)
  end

  nset('s', function()
    vim.wo.spell = not vim.wo.spell
  end)
  nset('g', function()
    vim.ui.select(vim.opt.spellfile:get(), {
      prompt = 'Which dict?',
      format_item = function(item)
        return vim.fn.fnamemodify(item, ':t:r:r')
      end
    }, function(_, idx)
      if idx then
        vim.cmd(('normal %szg'):format(idx))
      end
    end)
  end)

end

local function map_misc()
  -- "favouiriteze" symbol
  vim.keymap.set('n', '<space>an', '<Nop>')
  vim.keymap.set('x', '<space>an', function()
    local selection = vu.get_visual_selection_lines()[1]
    -- project root supposed
    local fd = io.open('.my_notes.md', 'a')
    fd:write(selection .. '\n')
    fd:close()
  end)
end

do
  map_completion()
  map_spell()
  map_misc()
end
