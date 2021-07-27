vim.lsp.log = require 'vim.lsp.log'
local lspconfig = require 'lspconfig'

local severities = {
  { name = 'Error', sign = '', hl = 'LspDiagnosticsSignError' },
  { name = 'Warning', sign = '', hl = 'LspDiagnosticsSignWarning' },
  { name = 'Information', sign = '', hl = 'LspDiagnosticsSignInformation' },
  { name = 'Hint', sign = '', hl = 'LspDiagnosticsSignHint' }
}

local lsp_utils = {}

-- local log = io.open('/home/igor/lsp_msg.log', 'w')

-- vim.g.lsp_status_string = ''

local separator = { clients = '][', diagnostics = ' ', progress = '|' }

function lsp_utils.render_status_string()
  local clients = vim.lsp.buf_get_clients(0)

  local client_strings = {}
  for _, client in ipairs(clients) do

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

function lsp_utils.apply_option(option)
  -- print('option ' .. option)
  local config = nil
  if vim.tbl_contains({ 'ldu', 'ldv' }, option) then
    config = {
      virtual_text = vim.g.utils_options.ldv == 1,
      underline = vim.g.utils_options.ldu == 1
    }
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, client.id), 0,
                                 client.id, config)
    end
  end
end

_G.lsp_utils = lsp_utils

--
-- UI
--

for i, sev in ipairs(severities) do
  vim.cmd(string.format('highlight User%d guifg=%s guibg=%s', i,
                        vim.fn['utils#GetHlAttr'](sev.hl, 'fg'),
                        vim.fn['utils#GetHlAttr']('StatusLine', 'bg')))
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
-- Languages
--
lspconfig.rust_analyzer.setup({})

lspconfig.sumneko_lua.setup {
  -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  cmd = { 'sumneko' },
  -- cmd={'/home/igor/Dist/lua-language-server/bin/Linux/lua-language-server', '-E', '/home/igor/Dist/lua-language-server/main.lua'},
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';')
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' }
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
  filetypes = { "lua" },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      lua = { { formatCommand = "lua-format -i", formatStdin = true } }
    }
  }
}

