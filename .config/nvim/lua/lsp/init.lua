-- local api = vim.api
local lsp = vim.lsp
local func = require 'pl.func'
-- local log = require 'vim.lsp.log'
local vim_utils = require 'vim_utils'
local telescope = require 'telescope.builtin'

-- LSP submodules
local status_line = require 'lsp.status_line'
local pui = require 'lsp.protocol_ui'
local lsp_flags = require 'lsp.flags'
local sym_nav = require 'lsp.symbol_navigation'
local completion = require 'lsp.completion'
local diagnostic = require 'lsp.diagnostic'
local servers = require 'lsp.server_setups'
local goto = require 'lsp.goto'

completion.setup()
diagnostic.setup()
servers.setup(completion.capabilities(lsp.protocol.make_client_capabilities()))

do
  pui.setup()

  local lsp_service = {
    symbol_icons = pui.symbol_icons,
    flags = lsp_flags,
    status_line = status_line
  }

  function lsp_service.omnifunc(...)
    -- zzz
    return lsp.omnifunc(unpack { ... })
  end

  service.lsp = lsp_service
end

--
-- Mappings and (auto)commands
--
do
  local map = vim_utils.map
  local autocmd = vim_utils.autocmd
  local b = func.bind1

  local function toggle_option(option)
    vim.fn['uopts#toggle'](option)
    if vim.tbl_contains({ 'ldu', 'ldv' }, option) then
      vim.diagnostic.show()
    end
  end

  local function auto_format()
    if vim.g.UOPTS.laf == 1 then
      lsp.buf.formatting_sync(nil, 1500)
    end
  end

  local function map_diagnostic_goto(sev, key)
    key = key or 'g'
    map('n', '[' .. key, function()
      vim.diagnostic.goto_prev({
        wrap = false,
        float = false,
        severity = vim.diagnostic.severity[sev]
      })
      vim.fn['uopts#nzz']()
    end)
    map('n', ']' .. key, function()
      vim.diagnostic.goto_next({
        wrap = false,
        float = false,
        severity = vim.diagnostic.severity[sev]
      })
      vim.fn['uopts#nzz']()
    end)
  end

  map('n', '<C-j>', lsp.buf.hover)
  map('n', '<C-k>', vim.diagnostic.open_float)
  map('n', '<leader>ld', telescope.diagnostics)

  -- Goto's
  map('n', 'gd', goto.definition)
  map('n', 'g<C-M-d>', b(goto.definition, 'split'))
  map('n', 'g<M-d>', b(goto.definition, 'vsplit'))
  map('n', 'g<C-d>', b(goto.definition, 'tab'))
  map('n', '<M-j>', b(goto.definition, 'preview')) -- C-; - remapped in alacritty
  map('n', 'gt', goto.type_definition)
  map('n', 'gT', b(goto.type_definition, 'split'))
  map('n', 'g<M-t>', b(goto.type_definition, 'vsplit'))
  map('n', 'g<C-t>', b(goto.type_definition, 'tab'))
  map('n', 'g<M-j>', b(goto.type_definition, 'preview')) -- C-; - remapped in alacritty
  map('n', 'gr', lsp.buf.references)
  map_diagnostic_goto()
  map_diagnostic_goto('ERROR', 'e')
  map_diagnostic_goto('WARN', 'w')
  map_diagnostic_goto('INFO', 'q')
  map_diagnostic_goto('HINT', 'r')

  -- Refactor
  map('n', '<leader>ln', lsp.buf.rename)
  map('n', 'ga', lsp.buf.code_action)

  -- Less in use
  map('n', 'gi', lsp.buf.implementation)
  map('i', '<M-j>', lsp.buf.signature_help) -- C-;
  map('n', 'gD', lsp.buf.declaration)

  -- Symbol lists
  map('n', '<leader>ls', sym_nav.document_list_non_props)
  map('n', '<leader>lS', sym_nav.document_list_symbols)
  map('n', '<leader>lf', sym_nav.document_list_functions)
  map('n', '<M-g>', telescope.lsp_workspace_symbols)

  -- Options
  map('n', '<leader>lv', b(toggle_option, 'ldv'))
  map('n', '<leader>l<M-u>', b(toggle_option, 'ldu'))
  map('n', '<leader>l<M-f>', b(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, ------------------------------------
    [[ User LspDiagnosticsChanged redraws! ]],
    [[ User LspProgressUpdate redraws! ]]
  })
end
