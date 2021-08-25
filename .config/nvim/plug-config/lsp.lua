local func = require 'pl.func'
vim.lsp.log = require 'vim.lsp.log'
local lspconfig = require 'lspconfig'

local severities = {
  { name = 'Error', sign = '', hl = 'LspDiagnosticsSignError' },
  { name = 'Warning', sign = '', hl = 'LspDiagnosticsSignWarning' },
  { name = 'Information', sign = '', hl = 'LspDiagnosticsSignInformation' },
  { name = 'Hint', sign = '', hl = 'LspDiagnosticsSignHint' }
}

--
-- Service
--
do
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
end

--
-- UI
--
do
  for _, sev in ipairs(severities) do
    vim.fn.sign_define(sev.hl,
                       { texthl = sev.hl, text = sev.sign, numhl = sev.hl })
  end

  vim.lsp.protocol.CompletionItemKind = {
    " ", " ", " ", " ", "ﰠ ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", "﬌ ", " ", " ", " ",
    " ", " ", " ", " ", "⌘ ", " ", " "
  }
end

--
-- Default config
--
do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }

  lspconfig.util.default_config = vim.tbl_extend("force",
                                                 lspconfig.util.default_config,
                                                 {
    flags = { debounce_text_changes = 1500 },
    capabilities = capabilities
  })
end

--
-- Handlers
--
do
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
end

--
-- Language servers
--
do
  lspconfig.rust_analyzer.setup {}
  lspconfig.vimls.setup {}
  lspconfig.tsserver.setup {}
  lspconfig.bashls.setup {}
  lspconfig.pyright.setup {}
  lspconfig.clangd.setup {
    init_options = {
      compilationDatabasePath = "Debug",
      clangdFileStatus = true,
      semanticHighlighting = true
    },
    cmd = {
      'clangd', '--background-index', '--clang-tidy'
      -- '--completion-style=detailed'
    }
  }
  -- ccls fails to gd in dependancies headers, while clangd is ok with that
  -- lspconfig.ccls.setup {
  --   init_options = { compilationDatabaseDirectory = "Debug" },
  -- }
  lspconfig.cmake.setup {}
  -- lspconfig.html.setup {}
  -- lspconfig.cssls.setup {}
  lspconfig.jsonls.setup {
    filetypes = { 'jsonc' },
    init_options = { provideFormatter = false },
    settings = { json = { schemas = require 'plug-config.json_schemas' } }
  }

  lspconfig.sumneko_lua.setup {
    cmd = { 'sumneko', '2>', vim.fn.stdpath('cache') .. '/sumneko.log' },
    settings = {
      Lua = {
        completion = { workspaceWord = false },
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';')
        },
        diagnostics = {
          globals = {
            'vim', 'service', '_map', '_augroup', '_shortmap', 'use',
            'use_rocks'
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
    filetypes = { 'lua', 'json', 'jsonc', 'html', 'css', 'sh', 'python' },
    settings = {
      rootMarkers = { '.git/' },
      languages = {
        lua = { { formatCommand = 'lua-format -i', formatStdin = true } },
        json = {
          { formatCommand = 'prettier --parser json', formatStdin = true }
        },
        jsonc = {
          { formatCommand = 'prettier --parser json', formatStdin = true }
        },
        sh = {
          {
            formatCommand = 'shfmt -i 2 -ci -sr',
            lintCommand = 'shellcheck',
            formatStdin = true,
            lintStdin = true
          }
        },
        python = { { formatCommand = 'yapf', formatStdin = true } }
        -- html = { { formatCommand = 'prettier' } },
        -- css = { { formatCommand = 'prettier' } }
      }
    }
  }
end

--
-- Compe
--
local function compe_setup()
  require'compe'.setup({
    enabled = true,
    autocomplete = false,
    source = { nvim_lsp = true }
  })

  local t = func.bind(vim.api.nvim_replace_termcodes, func._1, true, true, true)
  local luasnip = require 'luasnip'

  local function is_space_before()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      return true
    else
      return false
    end
  end

  local function on_tab()
    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif luasnip.expandable() then
      return t "<Plug>luasnip-expand-snippet"
    elseif is_space_before() then
      return t "<Tab>"
    else
      return vim.fn['compe#complete']()
    end
  end

  local function on_cp()
    if luasnip.jumpable(-1) then
      return t "<Plug>luasnip-jump-prev"
    else
      return t "<C-p>"
    end
  end

  local function on_cn()
    if luasnip.jumpable(1) then
      return t "<Plug>luasnip-jump-next"
    else
      return t "<C-n>"
    end
  end

  local function on_ce() return t '<Plug>luasnip-next-choice' end

  return on_tab, on_cn, on_cp, on_ce
end

local on_tab, on_cn, on_cp, on_ce = compe_setup()

--
-- Mappings and (auto)commands
--
do
  local map = require'before-plug.vim_utils'.map
  local autocmd = require'before-plug.vim_utils'.autocmd

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
    if vim.g.utils_options.laf == 1 then
      vim.lsp.buf.formatting_sync(nil, 1500)
    end
  end

  -- Commands
  -- In use
  map('n', '<C-j>', vim.lsp.buf.hover)
  map('i', '<C-i>', on_tab, { expr = true, noremap = false })
  map('i', '<C-n>', on_cn, { expr = true, noremap = false })
  map('i', '<C-p>', on_cp, { expr = true, noremap = false })
  map('i', '<C-e>', on_ce, { expr = true, noremap = false })
  map('i', '<C-y>', 'compe#confirm(\'<C-y>\')', { expr = true })
  map('i', '<C-e>', 'compe#close(\'<C-e>\')', { expr = true })
  map('i', '<C-f>', 'compe#scroll(#{delta: +2})', { expr = true })
  map('i', '<C-d>', 'compe#scroll(#{delta: -2})', { expr = true })
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
  map('n', '<leader>l<M-v>', func.bind1(toggle_option, 'ldv'))
  map('n', '<leader>l<M-u>', func.bind1(toggle_option, 'ldu'))
  map('n', '<leader>l<M-f>', func.bind1(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, [[ User LspProgressUpdate redraws! ]],
    [[ User LspDiagnosticsChanged redraws! ]]
  })
end
