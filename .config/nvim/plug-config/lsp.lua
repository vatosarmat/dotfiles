local api = vim.api
local lsp = vim.lsp
local func = require 'pl.func'
local log = require 'vim.lsp.log'
local map = require'before-plug.vim_utils'.map
local autocmd = require'before-plug.vim_utils'.autocmd

-- LSP submodules
local status_line = require 'plug-config.lsp.status_line'
local pui = require 'plug-config.lsp.protocol_ui'
local lsp_flags = require 'plug-config.lsp.flags'
local completion = require 'plug-config.lsp.completion'
local sym_nav = require 'plug-config.lsp.symbol_navigation'
require 'plug-config.lsp.diagnostic'
require 'plug-config.lsp.server_setups'

do
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

    -- There could be logic to auto-close this sometimes annoying list
    -- when we return back from where we go to definition
    if vim.tbl_islist(result) then
      if #result > 1 then
        vim.fn.setloclist(0, {}, ' ', {
          title = 'Definitions',
          items = util.locations_to_items(result)
        })
        api.nvim_command 'lopen | wincmd p'
        autocmd('go_to_definition', 'BufWinEnter <buffer> ++once lclose', {
          buffer = true
        })
      end
      util.jump_to_location(result[1])
    else
      util.jump_to_location(result)
    end
  end
end

--
-- Mappings and (auto)commands
--
do
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

  -- Commands
  -- In use
  map('n', '<C-j>', lsp.buf.hover)
  map('i', '<C-i>', completion.on_tab, {
    expr = true,
    noremap = false
  })
  map('is', '<C-n>', completion.on_cn, {
    expr = true,
    noremap = false
  })
  map('is', '<C-p>', completion.on_cp, {
    expr = true,
    noremap = false
  })
  map('i', '<C-y>', 'compe#confirm(\'<C-y>\')', {
    expr = true,
    noremap = false
  })
  map('i', '<M-C-y>', '<C-y><Esc>')
  map('i', '<C-e>', 'compe#close(\'<End>\')', {
    expr = true
  })
  map('i', '<C-f>', 'compe#scroll(#{delta: +2})', {
    expr = true
  })
  map('i', '<C-b>', 'compe#scroll(#{delta: -2})', {
    expr = true
  })

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

  -- Less in use
  map('n', 'gi', lsp.buf.implementation)
  map('nx', '<M-j>', lsp.buf.signature_help) -- C-;
  map('n', 'gD', lsp.buf.declaration)
  map('n', 'ga', lsp.buf.code_action)

  -- Symbol lists
  map('n', '<leader>ls', sym_nav.document_list_non_props)
  map('n', '<leader>lS', sym_nav.document_list_symbols)
  map('n', '<leader>lf', sym_nav.document_list_functions)
  map('n', '<leader>lw', lsp.buf.workspace_symbol)

  -- Options
  map('n', '<leader>l<M-v>', func.bind1(toggle_option, 'ldv'))
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
