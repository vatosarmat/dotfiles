local func = require 'pl.func'
vim.lsp.log = require 'vim.lsp.log'
local lspconfig = require 'lspconfig'
local lint = require 'lint'

local severities = {
  {
    name = 'Error',
    sign = '',
    hl_sign = 'LspDiagnosticsSignError',
    hl_float = 'LspDiagnosticsFloatingError'
  }, {
    name = 'Warning',
    sign = '',
    hl_sign = 'LspDiagnosticsSignWarning',
    hl_float = 'LspDiagnosticsFloatingWarning'
  }, {
    name = 'Information',
    sign = '',
    hl_sign = 'LspDiagnosticsSignInformation',
    hl_float = 'LspDiagnosticsFloatingInformation'
  }, {
    name = 'Hint',
    sign = '',
    hl_sign = 'LspDiagnosticsSignHint',
    hl_float = 'LspDiagnosticsFloatingHint'
  }
}

local client_info = {
  ['shellcheck'] = {
    kind = 'linter',
    short_name = 'SC',
    diagnostic_disable_line = '#shellcheck disable=${code}',
    diagnostic_webpage = 'https://github.com/koalaman/shellcheck/wiki/SC${code}'
  },
  -- ['clang-tidy'] = { kind = 'linter', short_name = 'CT' },
  ['cppcheck'] = { kind = 'linter', short_name = 'CC' },
  ['clangd'] = { short_name = 'CD' },
  ['sumneko_lua'] = { short_name = 'SL' },
  ['rust_analyzer'] = { short_name = 'RA' }
}

setmetatable(client_info, {
  __index = function(tbl, key)
    local v = rawget(tbl, key)
    if not v then
      v = {}
      rawset(tbl, key, v)
    end
    return v
  end
})
--
-- Service
--
do
  local lsp_service = {}
  local separator = { clients = '][', diagnostics = ' ', progress = '|' }

  local function get_linters()
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    return lint.linters_by_ft[ft] or {}
  end

  local function diagnostic_lines(client_id)
    local diagnostics = {}
    for i, sev in ipairs(severities) do
      local sev_count = vim.lsp.diagnostic.get_count(0, sev.name, client_id)
      if sev_count > 0 then
        table.insert(diagnostics,
                     '%' .. i .. '*' .. sev.sign .. ' %*' .. sev_count)
      end
    end

    return diagnostics
  end

  function lsp_service.status_line()
    local clients = vim.lsp.buf_get_clients(0)
    local client_strings = {}
    for _, client in pairs(clients) do

      local diagnostics = diagnostic_lines(client.id)

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

      local client_str = client_info[client.name].short_name or client.name

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

    local linters = get_linters()
    for i, name in ipairs(linters) do
      local diagnostics = diagnostic_lines(1000 + i)
      local linter_str = client_info[name].short_name or name

      if next(diagnostics) then
        linter_str = linter_str .. ':' ..
                       table.concat(diagnostics, separator.diagnostics)
      end

      table.insert(client_strings, linter_str)
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
    vim.fn.sign_define(sev.hl_sign, {
      texthl = sev.hl_sign,
      text = sev.sign,
      numhl = sev.hl_sign
    })
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
vim.g.lsp_autostart = true
do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }

  lspconfig.util.default_config = vim.tbl_extend("force",
                                                 lspconfig.util.default_config,
                                                 {
    autostart = vim.g.lsp_autostart,
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
-- Same parameters as vim.lsp.start_client() + root_dir, name, filetypes, autostart, on_new_config
do
  local luadev = require("lua-dev").setup({
    lspconfig = {
      cmd = { 'sumneko', '2>', vim.fn.stdpath('cache') .. '/sumneko.log' },
      settings = {
        Lua = {
          completion = {
            workspaceWord = false,
            showWord = 'Disable',
            callSnipper = 'Replace'
          },
          diagnostics = {
            globals = {
              'vim', 'service', '_map', '_augroup', '_shortmap', 'use',
              'use_rocks'
            }
          }
        }
      }
    }
  })
  lspconfig.sumneko_lua.setup(luadev)

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
      'clangd', '--background-index', '--clang-tidy',
      '--completion-style=detailed'
    },
    on_new_config = function(new_config, _)
      local cc_file = 'compile_commands.json'

      for _, dir in ipairs({ '.', 'Debug', 'debugfull', 'Release' }) do
        if vim.fn.filereadable(dir .. '/' .. cc_file) == 1 then
          new_config.init_options.compilationDatabasePath = dir
          return
        end
      end

      new_config.init_options.compilationDatabasePath = vim.fn.input(
                                                          'Where is ' .. cc_file ..
                                                            '? ', '', 'file')
    end
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
            -- lintCommand = 'shellcheck --format=gcc --severity=style -',
            formatStdin = true
            -- lintStdin = true
          }
        },
        python = { { formatCommand = 'yapf', formatStdin = true } }
        -- html = { { formatCommand = 'prettier' } },
        -- css = { { formatCommand = 'prettier' } }
      },
      logFile = vim.fn.stdpath('cache') .. '/efm.log',
      logLevel = 1
    }
  }
end

--
-- And linters
--
lint.linters_by_ft = {
  sh = { 'shellcheck' },
  cpp = { 'cppcheck' },
  c = { 'cppcheck' }
}

--
-- Diagnostics UI
--
local Text = require'before-plug.vim_utils'.Text
local map = require'before-plug.vim_utils'.map
local map_buf = require'before-plug.vim_utils'.map_buf
local autocmd = require'before-plug.vim_utils'.autocmd

local function show_line_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
  local opts = {}

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr,
                                                                   line_nr, opts)
  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  local text = Text:new()
  for _, diagnostic in ipairs(line_diagnostics) do
    local name = '?'
    local code = diagnostic.code or diagnostic.severity
    if diagnostic.source then
      name = client_info[diagnostic.source].short_name or diagnostic.source
    end
    local hiname = severities[diagnostic.severity].hl_float
    assert(hiname, 'unknown severity: ' .. tostring(diagnostic.severity))
    text:append(name .. '_' .. code .. ': ', hiname)
    -- Maybe I should split it to lines somehow?
    text:append(diagnostic.message)
    text:newline()
  end

  opts.focus_id = "line_diagnostics"
  local float_bufnr, float_winnr = text:render_in_float(opts)

  local function disable()
    -- Current window is diagnostic float
    local idx = vim.api.nvim_win_get_cursor(0)[1]
    local source = line_diagnostics[idx].source
    local dl_pattern = client_info[source].diagnostic_disable_line
    if dl_pattern then
      vim.api.nvim_buf_delete(float_bufnr, {})
      local line = vim.api
                     .nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
      print(vim.inspect(line))
      local indent_spaces = string.sub(line, string.find(line, '%s*'))
      local dl = indent_spaces ..
                   string.gsub(dl_pattern, "%${code}",
                               line_diagnostics[idx].code)
      vim.api.nvim_buf_set_lines(bufnr, line_nr, line_nr, false, { dl })
      -- if client_info[source].kind == 'linter' then
      --   lint.try_lint()
      -- else
      vim.cmd("write " .. tostring(vim.fn.bufname(bufnr)))
      -- end
    end
  end

  local function webpage()
    local idx = vim.api.nvim_win_get_cursor(0)[1]
    local source = line_diagnostics[idx].source
    local webpage_pattern = client_info[source].diagnostic_webpage
    if webpage_pattern then
      vim.api.nvim_buf_delete(float_bufnr, {})
      local uri = string.gsub(webpage_pattern, "%${code}",
                              line_diagnostics[idx].code)
      os.execute('$BROWSER ' .. uri)
    end

  end

  map_buf(float_bufnr, 'n', 'd', disable, { silent = true, nowait = true })
  map_buf(float_bufnr, 'n', 'p', webpage, { silent = true, nowait = true })
  return float_bufnr, float_winnr
end

--
-- Compe
--
local function compe_setup()
  require'compe'.setup({
    enabled = true,
    autocomplete = false,
    source = { nvim_lsp = true },
    preselect = 'always'
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

  -- local function on_ce() return t '<Plug>luasnip-next-choice' end

  return on_tab, on_cn, on_cp -- , on_ce
end

local on_tab, on_cn, on_cp = compe_setup()

--
-- Mappings and (auto)commands
--
do
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
  map('i', '<C-y>', 'compe#confirm(\'<C-y>\')', { expr = true, noremap = false })
  map('i', '<C-e>', 'compe#close(\'<End>\')', { expr = true })
  map('i', '<C-f>', 'compe#scroll(#{delta: +2})', { expr = true })
  map('i', '<C-b>', 'compe#scroll(#{delta: -2})', { expr = true })

  vim.lsp.diagnostic.show_line_diagnostics = show_line_diagnostics
  map('n', '<C-k>', vim.lsp.diagnostic.show_line_diagnostics)

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

  -- Options
  map('n', '<leader>l<M-v>', func.bind1(toggle_option, 'ldv'))
  map('n', '<leader>l<M-u>', func.bind1(toggle_option, 'ldu'))
  map('n', '<leader>l<M-f>', func.bind1(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, [[ User LspProgressUpdate redraws! ]],
    { 'BufWritePost *', require('lint').try_lint },
    { 'FileType *', require('lint').try_lint },
    [[ User LspDiagnosticsChanged redraws! ]]
  })
end
