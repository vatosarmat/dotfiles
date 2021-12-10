local api = vim.api
local lsp = vim.lsp
local func = require 'pl.func'
local log = require 'vim.lsp.log'
local vim_utils = require 'before-plug.vim_utils'

-- LSP submodules
local status_line = require 'plug-config.lsp.status_line'
local pui = require 'plug-config.lsp.protocol_ui'
local lsp_flags = require 'plug-config.lsp.flags'
local sym_nav = require 'plug-config.lsp.symbol_navigation'
local completion = require 'plug-config.lsp.completion'
local diagnostic = require 'plug-config.lsp.diagnostic'
local servers = require 'plug-config.lsp.server_setups'

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
-- Handlers
--
do
  local util = lsp.util
  lsp.handlers['textDocument/definition'] = function(_, result, ctx, _)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, 'No location found')
      if lsp.get_client_by_id(ctx.client_id).name ~= 'efm' then
        api.nvim_echo({ { 'No definition found', 'WarningMsg' } }, true, {})
      end
      return nil
    end

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
    if vim.tbl_islist(result) then
      if #result > 1 then
        -- vim.fn.setloclist(0, {}, ' ', {
        --   title = 'Definitions',
        --   items = util.locations_to_items(result)
        -- })
        -- api.nvim_command 'lopen | wincmd p | try | lbefore | catch /E553/ | lafter | endtry'
        -- -- Close loclist when we get back from definition
        -- local pos = api.nvim_win_get_cursor(0)
        -- local auto_cmd = 'let b:lsp_gd_pos = | BufWinEnter <buffer> ++once if b:lsp_gd_pos] lclose'
        -- autocmd('go_to_definition', 'BufWinEnter <buffer> ++once lclose', {
        --   buffer = true
        -- })
        vim.fn['lsp#DefinitionList'](util.locations_to_items(result))
      else
        util.jump_to_location(result[1])
      end
    else
      util.jump_to_location(result)
    end
  end
end

--
-- Mappings and (auto)commands
--
do
  local map = vim_utils.map
  local autocmd = vim_utils.autocmd

  local function toggle_option(option)
    vim.fn['uopts#toggle'](option)
    if vim.tbl_contains({ 'ldu', 'ldv' }, option) then
      vim.diagnostic.show()
    end
  end

  local function auto_format()
    if vim.g.uopts.laf == 1 then
      lsp.buf.formatting_sync(nil, 1500)
    end
  end

  map('n', '<C-j>', lsp.buf.hover)
  map('n', '<C-k>', vim.diagnostic.open_float)

  -- Goto's
  map('n', 'gd', lsp.buf.definition)
  map('n', 'gt', lsp.buf.type_definition)
  map('n', 'gr', lsp.buf.references)
  map('n', 'g[', func.bind1(vim.diagnostic.goto_prev, {
    wrap = false,
    float = false
  }))
  map('n', 'g]', func.bind1(vim.diagnostic.goto_next, {
    wrap = false,
    float = false
  }))

  -- Refactor
  map('n', '<leader>ln', lsp.buf.rename)
  map('n', 'ga', lsp.buf.code_action)

  -- Less in use
  map('n', 'gi', lsp.buf.implementation)
  map('nx', '<M-j>', lsp.buf.signature_help) -- C-;
  map('n', 'gD', lsp.buf.declaration)

  -- Symbol lists
  map('n', '<leader>ls', sym_nav.document_list_non_props)
  map('n', '<leader>lS', sym_nav.document_list_symbols)
  map('n', '<leader>lf', sym_nav.document_list_functions)
  map('n', '<leader>lw', lsp.buf.workspace_symbol)

  -- Options
  map('n', '<leader>lv', func.bind1(toggle_option, 'ldv'))
  map('n', '<leader>l<M-u>', func.bind1(toggle_option, 'ldu'))
  map('n', '<leader>l<M-f>', func.bind1(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, ------------------------------------
    { 'BufWritePost *', require('lint').try_lint }, ----------------------
    { 'FileType *', require('lint').try_lint }, --------------------------
    [[ User LspDiagnosticsChanged redraws! ]],
    [[ User LspProgressUpdate redraws! ]]
  })
end
