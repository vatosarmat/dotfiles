-- local api = vim.api
local lsp = vim.lsp
local api = vim.api
local func = require 'pl.func'
-- local log = require 'vim.lsp.log'
local vim_utils = require 'vim_utils'
local telescope = require 'telescope.builtin'

-- LSP submodules
local status_line = require 'lsp.status_line'
local ui = require 'lsp.ui'
local lsp_flags = require 'lsp.flags'
local sym_nav = require 'lsp.symbol_navigation'
local completion = require 'lsp.completion'
local diagnostic = require 'lsp.diagnostic'
local servers = require 'lsp.server_setups'
local lookup = require 'lsp.lookup'

completion.setup()
diagnostic.setup()
servers.setup(completion.capabilities(vim.tbl_deep_extend('force',
                                                          lsp.protocol.make_client_capabilities(), {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
  }
})))

do
  ui.setup()

  local lsp_service = {
    ui = {
      symbol = ui.symbol
    },
    flags = lsp_flags,
    status_line = status_line
  }

  function lsp_service.omnifunc(...)
    -- zzz
    return lsp.omnifunc(unpack { ... })
  end

  _U.lsp = lsp_service
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
      lsp.buf.format({
        timeout_ms = 1500
      })
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

  local function signature_help()
    local file_buf = vim.fn.bufnr()
    local float_winid = vim.b[file_buf].float_winid
    if float_winid then
      vim.api.nvim_win_close(float_winid, true)
    else
      local params = lsp.util.make_position_params()

      vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(...)
        local new_float_buf, new_float_winid = lsp.handlers['textDocument/signatureHelp'](...)

        api.nvim_create_autocmd('WinClosed', {
          callback = function(info)
            local closed_winid = tonumber(info.match)
            if closed_winid == new_float_winid then
              vim.b[file_buf].float_winid = nil
            end
            return true
          end,
          once = true
        })
        vim.b[file_buf].float_winid = new_float_winid
        return new_float_buf, new_float_winid
      end)
    end
  end

  map('n', '<C-j>', lsp.buf.hover)
  map('n', '<C-k>', vim.diagnostic.open_float)
  map('n', '<leader>ld', telescope.diagnostics)

  -- Goto's
  map('i', '<M-j>', signature_help) -- C-;
  map('n', 'gd', lookup.definition)
  map('n', 'g<C-M-d>', b(lookup.definition, 'split'))
  map('n', 'g<M-d>', b(lookup.definition, 'vsplit'))
  map('n', 'g<C-d>', b(lookup.definition, 'tabe'))
  map('n', '<M-j>', b(lookup.definition, 'preview')) -- C-; - remapped in alacritty
  map('n', 'gt', lookup.type_definition)
  map('n', 'gT', b(lookup.type_definition, 'split'))
  map('n', 'g<M-t>', b(lookup.type_definition, 'vsplit'))
  map('n', 'g<C-t>', b(lookup.type_definition, 'tabe'))
  map('n', '<M-k>', b(lookup.type_definition, 'preview')) -- C-' - remapped in alacritty
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
  map('n', 'gD', lsp.buf.declaration)

  -- Symbol lists
  map('n', '<leader>ls', sym_nav.document_symbol_request)
  map('n', '<C-M-h>', sym_nav.loclist_depth_up)
  map('n', '<C-M-l>', sym_nav.loclist_depth_down)
  map('n', '<M-g>', telescope.lsp_dynamic_workspace_symbols)

  -- Options
  map('n', '<leader>lv', b(toggle_option, 'ldv'))
  map('n', '<leader>lu', b(toggle_option, 'ldu'))
  map('n', '<leader>lf', b(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, ------------------------------------
    [[ User LspDiagnosticsChanged redraws! ]],
    [[ User LspProgressUpdate redraws! ]]
  })
end
