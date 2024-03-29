local api = vim.api
local keymap = vim.keymap
local b = require('utils').b
local vu = require 'vim_utils'
local codemod = require 'codemod'

local function completion()
  local function is_space_before()
    local col = vim.fn.col '.' - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
  end

  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  local set = keymap.set
  local iset = b(set, { 'i', 's' })

  local function complete_sources(...)
    return cmp.complete {
      config = {
        sources = vim.tbl_map(function(v)
          return {
            name = v,
          }
        end, pack(...)),
      },
    }
  end

  iset('<M-i>', function()
    if cmp.visible() then
      cmp.select_next_item()
    else
      cmp.complete {
        reason = cmp.ContextReason.Manual,
        config = {
          sorting = {
            comparators = {
              function(a, b)
                return vim.stricmp(b.completion_item.label, a.completion_item.label) > 0
              end,
            },
          },
          sources = {
            {
              name = 'luasnip',
            },
          },
        },
      }
    end
  end)

  -- lsp
  iset('<C-i>', function()
    if cmp.visible() then
      cmp.select_next_item()
    else
      complete_sources('nvim_lsp', 'nvim_lua')
    end
  end)

  iset('<C-j>', function()
    if cmp.visible() then
      cmp.confirm()
    else
      luasnip.expand()
    end
  end)

  iset('<Down>', function()
    if cmp.visible() then
      cmp.confirm()
    else
      vu.feed_keys '<Down>'
    end
  end)

  iset('<M-Tab>', function()
    if cmp.visible() then
      cmp.close()
    else
      vu.feed_keys '<Tab>'
    end
  end)

  iset('<C-e>', function()
    if cmp.visible() then
      cmp.abort()
    else
      vu.feed_keys '<End>'
    end
  end)

  iset('<C-f>', b(cmp.scroll_docs, 1))
  iset('<C-b>', b(cmp.scroll_docs, -1))

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

local function spell()
  keymap.set('n', '<leader>as', function()
    vim.wo.spell = not vim.wo.spell
  end)
  keymap.set({ 'n', 'x' }, '<leader>ag', function()
    vim.ui.select(vim.opt.spellfile:get(), {
      prompt = 'Which dict?',
      format_item = function(item)
        return vim.fn.fnamemodify(item, ':t:r:r')
      end,
    }, function(_, idx)
      if idx then
        vim.cmd(('normal %szg'):format(idx))
      end
    end)
  end)
end

local function misc()
  -- "favouiriteze" symbol
  keymap.set('n', '<leader>an', '<Nop>')
  keymap.set('x', '<leader>an', function()
    local selection = vu.get_visual_selection_lines()[1]
    -- project root supposed
    local fd = io.open('.my_notes.md', 'a')
    fd:write(selection .. '\n')
    fd:close()
  end)

  -- keymap.set('n', '<leader>/e', function()
  --
  -- end)
end

local function edit()
  keymap.set('n', '<leader>ce', codemod.language_export)
  keymap.set('n', '<leader>cp', codemod.language_print)
end

local function yank()
  keymap.set('x', '<leader>ym', function()
    local selection = table.concat(vu.get_visual_selection_lines(), '\n')
    vim.fn.setreg(
      '+',
      ([[```%s
%s
```]]):format(vu.markdown_lang_by_ft(vim.o.ft), selection)
    )
    vu.feed_keys '<ESC>'
  end)

  keymap.set('n', '<leader>yr', function()
    -- relative file path
    vim.fn.setreg('+', vim.fn.expand '%')
  end)
  keymap.set('n', '<leader>yp', function()
    -- full file path
    vim.fn.setreg('+', vim.fn.expand '%:p')
  end)
  keymap.set('n', '<leader>yw', function()
    -- full directory path
    vim.fn.setreg('+', vim.fn.expand '%:p:h')
  end)
end

do
  completion()
  spell()
  misc()
  edit()
  yank()
end
