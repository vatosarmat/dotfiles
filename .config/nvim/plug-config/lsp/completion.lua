local luasnip = require 'luasnip'
local cmp = require 'cmp'
local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local autopairs = require('nvim-autopairs')
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
    elseif is_space_before() then
      return fallback()
    else
      return cmp.mapping.complete()(fallback)
    end
  end,
  ['<M-C-i>'] = cmp.mapping.complete(),
  ['<C-f>'] = cmp.mapping.scroll_docs(2),
  ['<C-b>'] = cmp.mapping.scroll_docs(-2),
  ['<M-C-y>'] = cmp.mapping.close()

  -- Default
  -- ['<C-n>'] = mapping(mapping.select_next_item({
  --   behavior = types.cmp.SelectBehavior.Insert
  -- }), { 'i', 'c' }),
  -- ['<C-p>'] = mapping(mapping.select_prev_item({
  --   behavior = types.cmp.SelectBehavior.Insert
  -- }), { 'i', 'c' }),
  -- ['<C-y>'] = mapping.confirm({
  --   select = false
  -- }),
  -- ['<C-e>'] = mapping.abort()

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
      }
      -- {
      --   name = 'nvim_lua'
      -- },
      -- {
      --   name = 'path'
      -- },
      -- {
      --   name = 'luasnip'
      -- }
    }

  })

end

function M.capabilities(client_capabilities)
  return cmp_nvim_lsp.update_capabilities(client_capabilities)
end

return M
