local api = vim.api
local func = require 'pl.func'
local luasnip = require 'luasnip'
local compe = require 'compe'

compe.setup {
  enabled = true,
  autocomplete = false,
  source = {
    nvim_lsp = true
  },
  preselect = 'always'
}

local t = func.bind(api.nvim_replace_termcodes, func._1, true, true, true)
-- luasnip.config.setup({ history = true })
luasnip.config.setup {}

local function is_space_before()
  local col = vim.fn.col '.' - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
    return true
  else
    return false
  end
end

local function on_tab()
  if vim.fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif luasnip.expandable() then
    return t '<Plug>luasnip-expand-snippet'
  elseif is_space_before() then
    return t '<Tab>'
  else
    return vim.fn['compe#complete']()
  end
end

local function on_cp()
  if luasnip.jumpable(-1) then
    return t '<Plug>luasnip-jump-prev'
  else
    return t '<C-p>'
  end
end

local function on_cn()
  if luasnip.jumpable(1) then
    return t '<Plug>luasnip-jump-next'
  else
    return t '<C-n>'
  end
end

-- local function on_ce() return t '<Plug>luasnip-next-choice' end

return {
  on_tab = on_tab,
  on_cn = on_cn,
  on_cp = on_cp
}
