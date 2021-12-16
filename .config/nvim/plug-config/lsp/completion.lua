local pui = require 'plug-config.lsp.protocol_ui'
local luasnip = require 'luasnip'
local cmp = require 'cmp'
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local autopairs = require 'nvim-autopairs'
-- local cmp_autopairs = require('nvim-autopairs.completion.cmp')

local function is_space_before()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local M = {}

local mapping = {
  ['<C-i>'] = function(fallback)
    if cmp.visible() then
      return cmp.mapping.select_next_item {
        behavior = cmp.SelectBehavior.Insert
      }(fallback)
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    elseif is_space_before() then
      return fallback()
    else
      return cmp.mapping.complete()(fallback)
    end
  end,
  ['<M-C-i>'] = cmp.mapping.complete(),
  ['<C-f>'] = cmp.mapping.scroll_docs(2),
  ['<C-b>'] = cmp.mapping.scroll_docs(-2),
  ['<M-C-y>'] = cmp.mapping.close(),
  ['<C-n>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.jumpable(1) then
      luasnip.jump(1)
    else
      fallback()
    end
  end, { 'i', 's' }),
  ['<C-p>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, { 'i', 's' })

  -- Default
  -- ['<C-y>'] = mapping.confirm({
  --   select = false
  -- }),
  -- ['<C-e>'] = mapping.abort()
}

local kind_icons = {
  Text = ' ',
  Method = pui.symbol_icons.Method,
  Function = pui.symbol_icons.Function,
  Constructor = pui.symbol_icons.Constructor,
  Field = pui.symbol_icons.Field,
  Variable = pui.symbol_icons.Variable,
  Class = pui.symbol_icons.Class,
  Interface = pui.symbol_icons.Interface,
  Module = ' ',
  Property = pui.symbol_icons.Property,
  Unit = ' ',
  Value = ' ',
  Enum = pui.symbol_icons.Enum,
  Keyword = ' ',
  Snippet = '﬌ ',
  Color = ' ',
  File = ' ',
  Reference = ' ',
  Folder = ' ',
  EnumMember = pui.symbol_icons.EnumMember,
  Constant = pui.symbol_icons.Constant,
  Struct = pui.symbol_icons.Struct,
  Event = '⌘ ',
  Operator = ' ',
  TypeParameter = ' '
}

function M.setup()
  luasnip.config.setup {}
  autopairs.setup()

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
      autocomplete = false,
      completeopt = 'menu,menuone,noinsert'
    },
    mapping = mapping,
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
      },
      -- {
      --   name = 'path'
      -- },
      {
        name = 'luasnip'
      }
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
end

function M.capabilities(client_capabilities)
  return cmp_nvim_lsp.update_capabilities(client_capabilities)
end

return M
