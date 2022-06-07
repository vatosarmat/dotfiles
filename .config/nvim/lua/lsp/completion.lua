local ui = require 'lsp.ui'
local map = require'vim_utils'.map
local luasnip = require 'luasnip'
local cmp = require 'cmp'
local cmp_types = require('cmp.types')
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local autopairs = require 'nvim-autopairs'
-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')

local function is_space_before()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local M = {}

local kind_icons = {
  Text = ' ',
  Method = ui.symbol.Method.icon,
  Function = ui.symbol.Function.icon,
  Constructor = ui.symbol.Constructor.icon,
  Field = ui.symbol.Field.icon,
  Variable = ui.symbol.Variable.icon,
  Class = ui.symbol.Class.icon,
  Interface = ui.symbol.Interface.icon,
  Module = ui.symbol.Module.icon,
  Property = ui.symbol.Property.icon,
  Unit = ' ',
  Value = ' ',
  Enum = ui.symbol.Enum.icon,
  Keyword = ' ',
  Snippet = '﬌ ',
  Color = ' ',
  File = ' ',
  Reference = ' ',
  Folder = ' ',
  EnumMember = ui.symbol.EnumMember.icon,
  Constant = ui.symbol.Constant.icon,
  Struct = ui.symbol.Struct.icon,
  Event = '⌘ ',
  Operator = ' ',
  TypeParameter = ui.symbol.TypeParameter.icon
}

local function is_autocomplete()
  return vim.g.UOPTS.lac == 1 and { cmp_types.cmp.TriggerEvent.TextChanged } or false
end

function M.setup()
  luasnip.config.setup {}
  autopairs.setup({
    check_ts = true,
    ts_config = {
      lua = { 'string' }
    }
  })
  autopairs.add_rules(require('nvim-autopairs.rules.endwise-lua'))
  vim.cmd([[ inoremap <M-C-m> <C-m> ]])
  -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({
  --   map_char = {
  --     tex = ''
  --   }
  -- }))

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end
    },
    completion = {
      autocomplete = is_autocomplete(),
      completeopt = 'menu,menuone,noselect'
    },
    -- why 2 arrays?
    sources = {
      -- {
      --   name = 'buffer'
      -- },
      {
        name = 'nvim_lsp'
      },
      {
        name = 'nvim_lua'
      }
      -- {
      --   name = 'path'
      -- },
      -- {
      --   name = 'luasnip'
      -- }
    },
    formatting = {
      ---@diagnostic disable-next-line: unused-local
      format = function(entry, vim_item)
        print(vim_item.kind)
        vim_item.kind = kind_icons[vim_item.kind]
        return vim_item
      end
    }
  })
  map('n', '<leader>lc', function()
    vim.fn['uopts#toggle']('lac')
    cmp.setup({
      completion = {
        autocomplete = is_autocomplete()
      }
    })
  end)
end

function M.capabilities(client_capabilities)
  return cmp_nvim_lsp.update_capabilities(client_capabilities)
end

return M
