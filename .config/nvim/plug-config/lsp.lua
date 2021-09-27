local func = require 'pl.func'
local log = require 'vim.lsp.log'
local api = vim.api
local lsp = vim.lsp
local lspconfig = require 'lspconfig'
local lint = require 'lint'

local symbol_icons = {
  Function = '',
  Variable = '✗'
}

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
  }, -- ['clang-tidy'] = { kind = 'linter', short_name = 'CT' },
  ['cppcheck'] = {
    kind = 'linter',
    short_name = 'CC'
  },
  ['clangd'] = {
    short_name = 'CD'
  },
  ['sumneko_lua'] = {
    short_name = 'SL',
    diagnostic_disable_line = '---@diagnostic disable-next-line: ${code}'
  },
  ['rust_analyzer'] = {
    short_name = 'RA'
  }
}

client_info['Lua Diagnostics.'] = client_info['sumneko_lua']

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
  local separator = {
    clients = '][',
    diagnostics = ' ',
    progress = '|'
  }

  local function get_linters()
    local ft = api.nvim_buf_get_option(0, 'filetype')
    return lint.linters_by_ft[ft] or {}
  end

  local function diagnostic_lines(client_id)
    local diagnostics = {}
    for i, sev in ipairs(severities) do
      local sev_count = lsp.diagnostic.get_count(0, sev.name, client_id)
      if sev_count > 0 then
        table.insert(diagnostics, '%' .. i .. '*' .. sev.sign .. ' %*' .. sev_count)
      end
    end

    return diagnostics
  end

  function lsp_service.status_line()
    local clients = lsp.buf_get_clients(0)
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
        client_str = client_str .. ':' .. table.concat(diagnostics, separator.diagnostics)
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
        linter_str = linter_str .. ':' .. table.concat(diagnostics, separator.diagnostics)
      end

      table.insert(client_strings, linter_str)
    end

    return table.concat(client_strings, separator.clients)
  end

  function lsp_service.omnifunc(...)
    -- zzz
    return lsp.omnifunc(unpack({ ... }))
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

  lsp.protocol.CompletionItemKind = {
    ' ', ' ', symbol_icons.Function, ' ', 'ﰠ ', symbol_icons.Variable, ' ', ' ',
    ' ', ' ', ' ', ' ', ' ', ' ', '﬌ ', ' ', ' ', ' ', ' ', ' ',
    ' ', ' ', '⌘ ', ' ', ' '
  }
end

--
-- Default config
--
vim.g.lsp_autostart = true
do
  local capabilities = lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }

  lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
    autostart = vim.g.lsp_autostart,
    flags = {
      debounce_text_changes = 500
    },
    capabilities = capabilities,
    ---@diagnostic disable-next-line: unused-local
    on_attach = function(client, bufnr)
    end
  })
end

--
-- Handlers
--
--
local function setup_handlers()
  local util = lsp.util

  local function symbol_lnum(symbol)
    if symbol.location then
      return symbol.location.range.start.line + 1
    else
      return symbol.selectionRange.start.line + 1
    end
  end

  local function sort_symbols_by_lnum(list)
    table.sort(list, function(a, b)
      return symbol_lnum(a) < symbol_lnum(b)
    end)
    return list
  end

  -- Convert symbols to quickfix list
  local function symbols_to_items(symbols, bufnr)
    local function _symbols_to_items(_symbols, _items, _bufnr)
      for _, symbol in ipairs(_symbols) do
        local lnum = symbol_lnum(symbol)
        if symbol.location then -- SymbolInformation type
          local range = symbol.location.range
          local kind = util._get_symbol_kind_name(symbol.kind)
          table.insert(_items, {
            filename = vim.uri_to_fname(symbol.location.uri),
            lnum = lnum,
            col = range.start.character + 1,
            kind = kind,
            -- text = '[' .. kind .. '] ' .. symbol.name
            text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name
          })
        elseif symbol.selectionRange then -- DocumentSymbole type
          local kind = util._get_symbol_kind_name(symbol.kind)
          table.insert(_items, { -- bufnr = _bufnr,
            filename = vim.api.nvim_buf_get_name(_bufnr),
            lnum = lnum,
            col = symbol.selectionRange.start.character + 1,
            kind = kind,
            -- text = '[' .. kind .. '] ' .. symbol.name
            text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name
          })

          -- Don't go for children
          -- if symbol.children then
          --   for _, v in ipairs(
          --                 _symbols_to_items(symbol.children, _items, _bufnr)) do
          --     vim.list_extend(_items, v)
          --   end
          -- end
        end
      end
      return _items
    end
    return _symbols_to_items(symbols, {}, bufnr)
  end

  -- Render only line num and text in the list, don't show file names
  local function loclist_set(title, items)
    local what = {
      title = title,
      items = items
    }

    function what.quickfixtextfunc(info)
      return vim.tbl_map(function(item)
        return string.format('|%-5d| %s', item.lnum, item.text)
      end, vim.list_slice(items, info.start_idx, info.end_idx))
    end

    vim.fn.setloclist(0, {}, ' ', what)
  end

  -- handler with filter_sort and on_done
  local function make_symbol_handler(title, filter_sort, on_done)
    ---@diagnostic disable-next-line: unused-local
    return function(err, method, result, client_id, bufnr, config)
      if not result or vim.tbl_isempty(result) then
        local _ = log.info() and log.info(method, 'No location found')
        if lsp.get_client_by_id(client_id).name ~= 'efm' then
          api.nvim_echo({ { 'No symbols found', 'WarningMsg' } }, true, {})
        end
        return
      end

      local a = filter_sort(result)
      local items = symbols_to_items(a, bufnr)
      loclist_set(title, items)
      api.nvim_command('lopen | wincmd p')
      on_done()
    end
  end

  local function symbol_loclist_sync()
    local qf = vim.fn.getloclist(0, {
      items = 0,
      winid = 0
    })

    if qf.winid == 0 then
      return
    end

    local cl = api.nvim_win_get_cursor(0)[1]
    if cl > qf.items[1].lnum then
      local i = 2
      while i < #(qf.items) do
        if qf.items[i - 1].lnum <= cl and cl < qf.items[i].lnum then
          vim.cmd('ll ' .. i)
        end
        i = i + 1
      end
    else
      vim.cmd('lfirst')
    end
  end

  local function document_list_symbols(title, filter_sort, on_done)
    title = title or 'symbols'
    filter_sort = filter_sort or sort_symbols_by_lnum
    on_done = on_done or symbol_loclist_sync
    local params = {
      textDocument = util.make_text_document_params()
    }
    vim.lsp.buf_request(0, 'textDocument/documentSymbol', params,
                        make_symbol_handler(title, filter_sort, on_done))
  end

  local function document_list_functions()
    local function filter_sort(items)
      local ret = {}
      for _, item in ipairs(items) do
        if vim.lsp.util._get_symbol_kind_name(item.kind) == 'Function' then
          table.insert(ret, item)
        end
      end
      return sort_symbols_by_lnum(ret)
    end
    document_list_symbols('functions', filter_sort, symbol_loclist_sync)
  end

  lsp.handlers['textDocument/definition'] = function(_, method, result, client_id, _, _)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(method, 'No location found')
      if lsp.get_client_by_id(client_id).name ~= 'efm' then
        api.nvim_echo({ { 'No definition found', 'WarningMsg' } }, true, {})
      end
      return nil
    end

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])

      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command('copen | wincmd p')
      end
    else
      util.jump_to_location(result)
    end
  end

  lsp.handlers['textDocument/publishDiagnostics'] =
    lsp.with(lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = function(_, _)
        return vim.g.uopts.ldv == 1 -- { severity_limit = "Error" }
      end,
      underline = function(_, _)
        return vim.g.uopts.ldu == 1 -- { severity_limit = "Error" }
      end,
      signs = true,
      update_in_insert = false,
      severity_sort = true
    })

  return symbol_loclist_sync, document_list_symbols, document_list_functions
end

--
-- Language servers
--
-- Same parameters as lsp.start_client() + root_dir, name, filetypes, autostart, on_new_config
do
  local luadev = require('lua-dev').setup({
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
              'vim', 'service', '_map', '_augroup', '_shortmap', 'use', 'pack', 'use_rocks', 'noop'
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
      compilationDatabasePath = 'Debug',
      clangdFileStatus = true,
      semanticHighlighting = true
    },
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed' },
    on_new_config = function(new_config, _)
      local cc_file = 'compile_commands.json'

      for _, dir in ipairs({ '.', 'Debug', 'debugfull', 'Release' }) do
        if vim.fn.filereadable(dir .. '/' .. cc_file) == 1 then
          new_config.init_options.compilationDatabasePath = dir
          return
        end
      end

      new_config.init_options.compilationDatabasePath =
        vim.fn.input('Where is ' .. cc_file .. '? ', '', 'file')
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
    init_options = {
      provideFormatter = false
    },
    settings = {
      json = {
        schemas = require 'plug-config.json_schemas'
      }
    }
  }

  lspconfig.efm.setup { -- on_attach = on_attach,
    init_options = {
      documentFormatting = true
    },
    filetypes = { 'lua', 'json', 'jsonc', 'html', 'css', 'sh', 'python' },
    settings = {
      rootMarkers = { '.git/' },
      languages = {
        lua = {
          {
            formatCommand = 'lua-format -i',
            formatStdin = true
          }
        },
        json = {
          {
            formatCommand = 'prettier --parser json',
            formatStdin = true
          }
        },
        jsonc = {
          {
            formatCommand = 'prettier --parser json',
            formatStdin = true
          }
        },
        sh = {
          {
            formatCommand = 'shfmt -i 2 -ci -sr',
            -- lintCommand = 'shellcheck --format=gcc --severity=style -',
            formatStdin = true -- lintStdin = true
          }
        },
        python = {
          {
            formatCommand = 'yapf',
            formatStdin = true
          }
        } -- html = { { formatCommand = 'prettier' } },
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
  local bufnr = api.nvim_get_current_buf()
  local line_nr = api.nvim_win_get_cursor(0)[1] - 1
  local opts = {}

  local line_diagnostics = lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts)
  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  local text = Text:new()
  -- local diag_idx_by_text = {}
  for _, diagnostic in ipairs(line_diagnostics) do
    local name = '?'
    local code = diagnostic.code or diagnostic.severity
    if diagnostic.source then
      name = client_info[diagnostic.source].short_name or diagnostic.source
    end
    local hiname = severities[diagnostic.severity].hl_float
    assert(hiname, 'unknown severity: ' .. tostring(diagnostic.severity))
    text:append(name .. '_' .. code .. ': ', hiname)
    text:append(pack(string.gsub(diagnostic.message, '\n', ' '))[1])
    text:newline()
  end

  opts.focus_id = 'line_diagnostics'
  opts.max_width = math.floor(vim.fn.winwidth(0) * 0.8)
  local float_bufnr, float_winnr = text:render_in_float(opts)

  local function disable()
    -- Current window is diagnostic float
    local idx = api.nvim_win_get_cursor(0)[1]
    local source = line_diagnostics[idx].source
    local dl_pattern = client_info[source].diagnostic_disable_line
    if dl_pattern then
      api.nvim_buf_delete(float_bufnr, {})
      local line = api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
      print(vim.inspect(line))
      local indent_spaces = string.sub(line, string.find(line, '%s*'))
      local dl = indent_spaces .. string.gsub(dl_pattern, '%${code}', line_diagnostics[idx].code)
      api.nvim_buf_set_lines(bufnr, line_nr, line_nr, false, { dl })
      -- if client_info[source].kind == 'linter' then
      --   lint.try_lint()
      -- else
      vim.cmd('write ' .. tostring(vim.fn.bufname(bufnr)))
      -- end
    end
  end

  local function webpage()
    local idx = api.nvim_win_get_cursor(0)[1]
    local source = line_diagnostics[idx].source
    local webpage_pattern = client_info[source].diagnostic_webpage
    if webpage_pattern then
      api.nvim_buf_delete(float_bufnr, {})
      local uri = string.gsub(webpage_pattern, '%${code}', line_diagnostics[idx].code)
      os.execute('$BROWSER ' .. uri)
    end

  end

  map_buf(float_bufnr, 'n', 'd', disable, {
    silent = true,
    nowait = true
  })
  map_buf(float_bufnr, 'n', 'p', webpage, {
    silent = true,
    nowait = true
  })
  return float_bufnr, float_winnr
end

--
-- Compe
--
local function compe_setup()
  require'compe'.setup({
    enabled = true,
    autocomplete = false,
    source = {
      nvim_lsp = true
    },
    preselect = 'always'
  })

  local t = func.bind(api.nvim_replace_termcodes, func._1, true, true, true)
  local luasnip = require 'luasnip'
  -- luasnip.config.setup({ history = true })
  luasnip.config.setup({})

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

  return on_tab, on_cn, on_cp -- , on_ce
end

local on_tab, on_cn, on_cp = compe_setup()
local symbol_qflist_sync, document_list_symbols, document_list_functions = setup_handlers()

--
-- Mappings and (auto)commands
--
do
  local function toggle_option(option)
    vim.fn['uopts#toggle'](option)
    if vim.tbl_contains({ 'ldu', 'ldv' }, option) then
      local config = {
        virtual_text = vim.g.uopts.ldv == 1,
        underline = vim.g.uopts.ldu == 1
      }
      for _, client in ipairs(lsp.get_active_clients()) do
        lsp.diagnostic.display(lsp.diagnostic.get(0, client.id), 0, client.id, config)
      end
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
  map('i', '<C-i>', on_tab, {
    expr = true,
    noremap = false
  })
  map('is', '<C-n>', on_cn, {
    expr = true,
    noremap = false
  })
  map('is', '<C-p>', on_cp, {
    expr = true,
    noremap = false
  })
  map('i', '<C-y>', 'compe#confirm(\'<C-y>\')', {
    expr = true,
    noremap = false
  })
  map('i', '<C-e>', 'compe#close(\'<End>\')', {
    expr = true
  })
  map('i', '<C-f>', 'compe#scroll(#{delta: +2})', {
    expr = true
  })
  map('i', '<C-b>', 'compe#scroll(#{delta: -2})', {
    expr = true
  })

  lsp.diagnostic.show_line_diagnostics = show_line_diagnostics
  map('n', '<C-k>', lsp.diagnostic.show_line_diagnostics)

  -- Goto's
  map('n', 'gd', lsp.buf.definition)
  map('n', 'gt', lsp.buf.type_definition)
  map('n', 'gr', lsp.buf.references)
  map('n', 'g[', func.bind1(lsp.diagnostic.goto_prev, {
    wrap = false,
    enable_popup = false
  }))
  map('n', 'g]', func.bind1(lsp.diagnostic.goto_next, {
    wrap = false,
    enable_popup = false
  }))

  -- Less in use
  map('n', 'gi', lsp.buf.implementation)
  map('n', '<leader>lh', lsp.buf.signature_help)
  map('n', 'gD', lsp.buf.declaration)
  map('n', 'ga', lsp.buf.code_action)

  -- Symbol lists
  map('n', '<leader>ls', document_list_symbols)
  map('n', '<leader>lf', document_list_functions)
  map('n', '<leader>lw', lsp.buf.workspace_symbol)
  map('n', '<leader>l<C-s>', symbol_qflist_sync)

  -- Options
  map('n', '<leader>l<M-v>', func.bind1(toggle_option, 'ldv'))
  map('n', '<leader>l<M-u>', func.bind1(toggle_option, 'ldu'))
  map('n', '<leader>l<M-f>', func.bind1(toggle_option, 'laf'))

  autocmd('LSP', {
    { 'BufWritePre *', auto_format }, [[ User LspProgressUpdate redraws! ]],
    { 'BufWritePost *', require('lint').try_lint }, ----------------------
    { 'FileType *', require('lint').try_lint }, --------------------------
    [[ User LspDiagnosticsChanged redraws! ]]
  })
end
