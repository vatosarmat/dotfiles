local bind1 = require'pl.func'.bind1
vim.lsp.log = require 'vim.lsp.log'
local lspconfig = require 'lspconfig'
local map = require'before-plug.vim_utils'.map
local autocmd = require'before-plug.vim_utils'.autocmd

local severities = {
  { name = 'Error', sign = '', hl = 'LspDiagnosticsSignError' },
  { name = 'Warning', sign = '', hl = 'LspDiagnosticsSignWarning' },
  { name = 'Information', sign = '', hl = 'LspDiagnosticsSignInformation' },
  { name = 'Hint', sign = '', hl = 'LspDiagnosticsSignHint' }
}

local lsp_service = {}

local separator = { clients = '][', diagnostics = ' ', progress = '|' }

function lsp_service.status_line()
  local clients = vim.lsp.buf_get_clients(0)

  local client_strings = {}
  for _, client in pairs(clients) do

    local diagnostics = {}
    for i, sev in ipairs(severities) do
      local sev_count = vim.lsp.diagnostic.get_count(0, sev.name, client.id)
      if sev_count > 0 then
        table.insert(diagnostics,
                     '%' .. i .. '*' .. sev.sign .. ' %*' .. sev_count)
      end
    end

    local progress = {}
    for token, item in pairs(client.messages.progress) do
      if not item or item.done then
        client.messages.progress[token] = nil
      else
        local title = item.title and item.title or ''
        local message = item.message and '(' .. item.message .. ')' or ''
        local percentage = item.percentabe and item.percentage .. '%%' or ''
        table.insert(progress, title .. message .. '...' .. percentage)
      end
    end

    local client_str = client.name

    -- If at least one present, separate it from the client name
    if next(diagnostics) or next(progress) then
      client_str = client_str .. ':' ..
                     table.concat(diagnostics, separator.diagnostics)
    end
    if next(diagnostics) and next(progress) then
      -- If both present, separate them
      client_str = client_str .. '|'
    end
    client_str = client_str .. table.concat(progress, separator.progress)
    table.insert(client_strings, client_str)

  end

  return table.concat(client_strings, separator.clients)
end

function lsp_service.omnifunc(...)
  -- zzz
  return vim.lsp.omnifunc(unpack({ ... }))
end

service.lsp = lsp_service

--
-- UI
--

for _, sev in ipairs(severities) do
  vim.fn.sign_define(sev.hl,
                     { texthl = sev.hl, text = sev.sign, numhl = sev.hl })
end

vim.lsp.protocol.CompletionItemKind = {
  " ", " ", " ", " ", "ﰠ ", " ", " ", " ", " ",
  " ", " ", " ", " ", " ", "﬌ ", " ", " ", " ",
  " ", " ", " ", " ", "⌘ ", " ", " "
}

--
-- Default config
--
lspconfig.util.default_config = vim.tbl_extend("force",
                                               lspconfig.util.default_config, {
  flags = { debounce_text_changes = 1000 }
})

--
-- Handlers
--
vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = function(_, _)
      return vim.g.utils_options.ldv == 1 -- { severity_limit = "Error" }
    end,
    underline = function(_, _)
      return vim.g.utils_options.ldu == 1 -- { severity_limit = "Error" }
    end,
    signs = true,
    update_in_insert = false,
    severity_sort = true
  })

--
-- Language servers
--
lspconfig.rust_analyzer.setup {}

-- lspconfig.html.setup {}
-- lspconfig.cssls.setup {}
lspconfig.jsonls.setup {
  filetypes = { 'jsonc' },
  init_options = { provideFormatter = false }
}

lspconfig.sumneko_lua.setup {
  cmd = { 'sumneko', '2>', vim.fn.stdpath('cache') .. '/sumneko.log' },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';')
      },
      diagnostics = {
        globals = {
          'vim', 'service', '_map', '_augroup', '_shortmap', 'use', 'use_rocks'
        }
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
        }
      }
    }
  }
}

lspconfig.efm.setup {
  -- on_attach = on_attach,
  init_options = { documentFormatting = true },
  filetypes = { "lua", "json", "jsonc", 'html', 'css' },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      lua = { { formatCommand = "lua-format -i", formatStdin = true } },
      json = { { formatCommand = 'prettier --parser json', formatStdin = true } },
      jsonc = { { formatCommand = 'prettier --parser json', formatStdin = true } }
      -- html = { { formatCommand = 'prettier' } },
      -- css = { { formatCommand = 'prettier' } }
    }
  }
}

local function toggle_option(option)
  vim.fn['utils_options#toggle'](option)
  if vim.tbl_contains({ 'ldu', 'ldv' }, option) then
    local config = {
      virtual_text = vim.g.utils_options.ldv == 1,
      underline = vim.g.utils_options.ldu == 1
    }
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, client.id), 0,
                                 client.id, config)
    end
  end
end

local function auto_format()
  if vim.g.utils_options.laf then
    vim.lsp.buf.formatting_sync(nil, 400)
  end
end

-- Commands
-- In use
map('n', '<C-j>', vim.lsp.buf.hover)
-- Goto's
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gt', vim.lsp.buf.type_definition)
map('n', 'gr', vim.lsp.buf.references)
map('n', 'g[', vim.lsp.diagnostic.goto_prev)
map('n', 'g]', vim.lsp.diagnostic.goto_next)
map('n', '<leader>ld', vim.lsp.buf.document_symbol)
map('n', '<leader>lw', vim.lsp.buf.workspace_symbol)
-- Less in use
map('n', 'gi', vim.lsp.buf.implementation)
map('n', '<leader>ls', vim.lsp.buf.signature_help)
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'ga', vim.lsp.buf.code_action)
map('n', '<C-k>', vim.lsp.diagnostic.show_line_diagnostics)

-- Options
map('n', '<leader>l<M-v>', bind1(toggle_option, 'ldv'))
map('n', '<leader>l<M-u>', bind1(toggle_option, 'ldu'))
map('n', '<leader>l<M-f>', bind1(toggle_option, 'laf'))

autocmd('LSP', {
  { 'BufWritePre *', auto_format }, [[ User LspProgressUpdate redraws! ]],
  [[ User LspDiagnosticsChanged redraws! ]]
})

