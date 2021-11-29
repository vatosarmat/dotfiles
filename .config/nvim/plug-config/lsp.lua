local func = require 'pl.func'
local tablex = require 'pl.tablex'
local log = require 'vim.lsp.log'
local api = vim.api
local lsp = vim.lsp
local lspconfig = require 'lspconfig'
local lspconfig_util = require 'lspconfig.util'
local lint = require 'lint'

local flags = {

  -- typescript
  ts_formatter_efm = true,
  prettier_with_d = true,

  -- lua
  lua_stylua = false,

  -- common
  null_ls_debug = false,
  lsp_autostart = true
}

local severities = {
  {
    name = 'Error',
    sign = '',
    hl_sign = 'LspDiagnosticsSignError',
    hl_float = 'LspDiagnosticsFloatingError'
  },
  {
    name = 'Warning',
    sign = '',
    hl_sign = 'LspDiagnosticsSignWarning',
    hl_float = 'LspDiagnosticsFloatingWarning'
  },
  {
    name = 'Information',
    sign = '',
    hl_sign = 'LspDiagnosticsSignInformation',
    hl_float = 'LspDiagnosticsFloatingInformation'
  },
  {
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
  },
  ['tsserver'] = {
    short_name = 'TS'
  },
  ['typescript'] = {
    short_name = 'TS'
  },
  ['eslint'] = {
    short_name = 'ES',
    diagnostic_disable_line = '//eslint-disable-next-line ${code}',
    diagnostic_webpage = function(diagnostic)
      return diagnostic.codeDescription.href
    end
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

local symbol_icons = {
  Function = 'F',
  Method = 'M',
  Variable = 'V',
  Constant = 'C',
  Property = 'P',
  Field = '',
  Namespace = '',
  Interface = '',
  Constructor = '',
  Class = '',
  Struct = '',
  Enum = 'ﴰ',
  EnumMember = '喝'
}

do
  local lsp_service = {
    symbol_icons = symbol_icons,
    flags = flags
  }

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
    return lsp.omnifunc(unpack { ... })
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
    ' ',
    ' ',
    symbol_icons.Function,
    ' ',
    'ﰠ ',
    symbol_icons.Variable,
    symbol_icons.Class,
    symbol_icons.Interface,
    ' ',
    symbol_icons.Property,
    ' ',
    ' ',
    symbol_icons.Enum,
    ' ',
    '﬌ ',
    ' ',
    ' ',
    ' ',
    ' ',
    symbol_icons.EnumMember,
    symbol_icons.Constant,
    symbol_icons.Struct,
    '⌘ ',
    ' ',
    ' '
  }
end

local Text = require('before-plug.vim_utils').Text
local map = require('before-plug.vim_utils').map
local map_buf = require('before-plug.vim_utils').map_buf
local autocmd = require('before-plug.vim_utils').autocmd

--
-- Default config
--

local function document_highlight()
  local col = vim.fn.col '.'
  local cursor_char = vim.fn.getline('.'):sub(col, col)
  -- Send request to LSP only if keyword char is under cursor
  if vim.fn.matchstr(cursor_char, '\\k') ~= '' then
    lsp.buf.document_highlight()
  end
end

---@diagnostic disable-next-line: unused-local
local function default_on_attach(client, _bufnr)
  if client.resolved_capabilities.document_highlight then
    autocmd('LSP_buffer', -------------------------------------------------------
    {
      { 'CursorHold', document_highlight }, -----------------------
      { 'CursorMoved', lsp.buf.clear_references }
    }, {
      buffer = true
    })
  end
end
do
  local capabilities = lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }

  lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
    autostart = flags.lsp_autostart,
    flags = {
      debounce_text_changes = 500
    },
    capabilities = capabilities,
    on_attach = default_on_attach
  })
end

--
-- Handlers
--
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
        util.set_loclist(util.locations_to_items(result))
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
end

--
-- Symbol selectors
--
-- vim.g.igor = ''
local function SymbolSelectors()
  local util = lsp.util
  local pub = {}

  local function symbol_lnum(symbol)
    if symbol.location then
      -- SymbolInformation type
      return symbol.location.range.start.line + 1
    else
      -- DocumentSymbol type
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
        elseif symbol.selectionRange then -- DocumentSymbol type
          local kind = util._get_symbol_kind_name(symbol.kind)
          local maybe_detail = symbol.detail and '  ' .. symbol.detail or ''
          table.insert(_items, { -- bufnr = _bufnr,
            filename = vim.api.nvim_buf_get_name(_bufnr),
            lnum = lnum,
            col = symbol.selectionRange.start.character + 1,
            kind = kind,
            -- text = '[' .. kind .. '] ' .. symbol.name
            text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name .. maybe_detail
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

  -- vim.g.igor = ''
  local function parent_symbol_under_cursor(items)
    local pos = api.nvim_win_get_cursor(0)
    local cursor_line = pos[1] - 1
    local cursor_character = pos[2]
    local function _find_psuc(_items)
      -- Find if items have symbol under cursor
      local uc_idx = tablex.find_if(_items, function(item)
        local sr = item.location and item.location.range or item.range
        -- vim.g.igor = vim.g.igor ..
        --                string.format('%s: %d %d %d %d', item.name, sr.start.line,
        --                              sr.start.character, sr['end'].line, sr['end'].character) ..
        --                '\n'
        return (cursor_line > sr.start.line and cursor_line < sr['end'].line) or
                 ((cursor_line == sr.start.line or cursor_line == sr['end'].line) and
                   (cursor_character >= sr.start.character and cursor_character <=
                     sr['end'].character))
      end)
      -- If have and it has children, remember it and check its children
      -- if uc_idx then
      --   vim.g.igor = vim.g.igor .. _items[uc_idx].name .. '\n'
      -- end
      if uc_idx and _items[uc_idx].children then
        return _find_psuc(_items[uc_idx].children) or _items[uc_idx]
      end
    end
    return _find_psuc(items)
  end

  -- handler with filter_sort and on_done
  local function make_symbol_handler(title, filter_sort, on_done)
    ---@diagnostic disable-next-line: unused-local
    return function(err, request_result, ctx, config)
      if not request_result or vim.tbl_isempty(request_result) then
        local _ = log.info() and log.info(ctx.method, 'No location found')
        if lsp.get_client_by_id(ctx.client_id).name ~= 'efm' then
          api.nvim_echo({ { 'No symbols found', 'WarningMsg' } }, true, {})
        end
        return
      end

      local psuc = parent_symbol_under_cursor(request_result)
      local a = filter_sort(psuc and psuc.children or request_result)
      local items = symbols_to_items(a, ctx.bufnr)
      loclist_set(psuc and psuc.name .. ': ' .. title or title, items)
      api.nvim_command 'lopen | wincmd p'
      on_done()
    end
  end

  local function loclist_sync()
    -- vim.cmd('lbefore | normal! \015')
    vim.cmd 'try | lbefore | catch /E553/ | lafter | endtry'
  end

  -- Pub selectors

  function pub.document_list_symbols(title, filter_sort, on_done)
    title = title or 'all symbols'
    filter_sort = filter_sort or sort_symbols_by_lnum
    on_done = on_done or loclist_sync
    local params = {
      textDocument = util.make_text_document_params()
    }
    vim.lsp.buf_request(0, 'textDocument/documentSymbol', params,
                        make_symbol_handler(title, filter_sort, on_done))
  end

  function pub.document_list_functions()
    local function filter_sort(items)
      local ret = {}
      for _, item in ipairs(items) do
        if vim.lsp.util._get_symbol_kind_name(item.kind) == 'Function' then
          table.insert(ret, item)
        end
      end
      return sort_symbols_by_lnum(ret)
    end
    pub.document_list_symbols('functions', filter_sort)
  end

  function pub.document_list_non_props()
    local function filter_sort(items)
      local ret = {}
      for _, item in ipairs(items) do
        if vim.lsp.util._get_symbol_kind_name(item.kind) ~= 'Property' then
          table.insert(ret, item)
        end
      end
      return sort_symbols_by_lnum(ret)
    end
    pub.document_list_symbols('symbols', filter_sort)
  end

  return pub
end

--
-- Language servers
--
-- Same parameters as lsp.start_client() + root_dir, name, filetypes, autostart, on_new_config
local jsts_filetype = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.jsx'
}
local prettier_filetype = vim.list_extend({ 'html', 'css', 'json', 'jsonc' }, jsts_filetype)
-- local eslint_filetype = jsts_filetype

do
  do
    --
    -- Sumneko lua
    --
    local luadev = require('lua-dev').setup {
      lspconfig = {
        cmd = { 'sumneko', '2>', vim.fn.stdpath 'cache' .. '/sumneko.log' },
        settings = {
          Lua = {
            completion = {
              workspaceWord = false,
              showWord = 'Disable',
              callSnipper = 'Replace'
            },
            diagnostics = {
              globals = {
                'vim',
                'service',
                '_map',
                '_augroup',
                '_shortmap',
                'use',
                'pack',
                'use_rocks',
                'noop'
              }
            }
          }
        }
      }
    }
    lspconfig.sumneko_lua.setup(luadev)
  end

  lspconfig.rust_analyzer.setup {}
  lspconfig.vimls.setup {}
  --
  -- Flow and tsserver
  --
  do
    local flow = lspconfig.flow
    flow.setup {}
    local flow_add = flow.manager.add
    flow.manager.add = function(...)
      local res = flow_add(...)
      if res then
        vim.b.flow_active = 1
      end
      return res
    end

    local tsserver = lspconfig.tsserver
    local ts_utils_settings = {
      -- debug = true,
      -- import_all_scan_buffers = 100
      -- I really need this?
      -- eslint_bin = 'eslint_d',
      -- eslint_enable_diagnostics = true,
      -- eslint_opts = {
      --   condition = function(utils)
      --     return utils.root_has_file('.eslintrc.js')
      --   end,
      --   diagnostics_format = '#{m} [#{c}]'
      -- },
      -- enable_formatting = true,
      -- formatter = 'eslint_d',
      -- update_imports_on_move = true,
      -- filter out dumb module warning
      filter_out_diagnostics_by_code = { 80001, 80006 }
    }
    tsserver.setup {
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        default_on_attach(client, bufnr)

        local ts_utils = require 'nvim-lsp-ts-utils'
        ts_utils.setup(ts_utils_settings)
        ts_utils.setup_client(client)

        -- map_buf(bufnr, 'n', 'gs', '<cmd>TSLspOrganize<CR>')
        -- map_buf(bufnr, 'n', 'gI', '<cmd>TSLspRenameFile<CR>')
        -- map_buf(bufnr, 'n', 'go', '<cmd>TSLspImportAll<CR>')
        -- map_buf(bufnr, 'n', 'qq', '<cmd>TSLspFixCurrent<CR>')
      end
      -- root_dir = lspconfig_util.find_git_ancestor
    }
    local tsserver_add = tsserver.manager.add
    tsserver.manager.add = function(...)
      if not vim.b.flow_active then
        return tsserver_add(...)
      end
    end
  end

  lspconfig.bashls.setup {}
  lspconfig.pyright.setup {}
  lspconfig.clangd.setup {
    init_options = {
      compilationDatabasePath = 'Debug',
      clangdFileStatus = false,
      semanticHighlighting = true
    },
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed' },
    on_new_config = function(new_config, _)
      local cc_file = 'compile_commands.json'

      for _, dir in ipairs { '.', 'Debug', 'debugfull', 'Release' } do
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
  lspconfig.yamlls.setup {}
  lspconfig.eslint.setup {
    settings = {
      format = true,
      workingDirectory = {
        mode = 'location'
      }
    },
    root_dir = lspconfig_util.find_git_ancestor
  }

  --
  -- null-ls linters and formatters
  --
  do
    if not flags.ts_formatter_efm then
      local null_ls = require 'null-ls'
      local b = null_ls.builtins

      local prettier_source = flags.prettier_with_d and b.formatting.prettierd.with({
        filetypes = prettier_filetype
      }) or b.formatting.prettier.with({
        filetypes = prettier_filetype,
        only_local = 'node_modules/.bin'
      })
      local sources = {
        prettier_source

        -- b.formatting.stylua.with({
        --   condition = function(utils)
        --     return utils.root_has_file('stylua.toml')
        --   end
        -- }),
        -- b.formatting.shfmt,
        -- b.diagnostics.write_good,
        -- b.diagnostics.markdownlint,
        -- b.diagnostics.teal,
        -- b.diagnostics.shellcheck.with({
        --   diagnostics_format = '#{m} [#{c}]'
        -- }),
        -- b.code_actions.gitsigns,
        -- b.hover.dictionary
      }

      null_ls.config {
        debug = flags.null_ls_debug,
        sources = sources
      }
      lspconfig['null-ls'].setup {}
    end
  end

  do
    -- lua, python yapf, shfmt, maybe prettier
    local efm_filetypes = { 'lua', 'sh', 'python' }
    local efm_langs = {
      lua = {
        {
          formatCommand = flags.lua_stylua and 'stylua -' or 'lua-format -i',
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
      }
    }

    if flags.ts_formatter_efm then
      local prettier_format = {
        formatCommand = flags.prettier_with_d and
          'PRETTIERD_LOCAL_PRETTIER_ONLY=true prettierd ${INPUT}' or
          'node_modules/.bin/prettier --stdin --stdin-filepath ${INPUT}',
        formatStdin = true
      }
      efm_filetypes = vim.list_extend(efm_filetypes, prettier_filetype)
      efm_langs = vim.tbl_extend('keep', efm_langs, tablex.reduce(function(ac, v)
        ac[v] = { prettier_format }
        return ac
      end, prettier_filetype, {}))
    end

    lspconfig.efm.setup {
      init_options = {
        documentFormatting = true
      },
      filetypes = efm_filetypes,
      settings = {
        rootMarkers = { '.git/' },
        languages = efm_langs,
        logFile = vim.fn.stdpath 'cache' .. '/efm.log',
        logLevel = 1
      }
    }
  end
end

--
-- nvim-lint linters
--
do
  local shellcheck = lint.linters.shellcheck
  table.insert(shellcheck.args, 1, '-x') -- allow source
  table.insert(shellcheck.args, 1, function()
    if vim.b.is_bash == 1 then
      return '--shell=bash'
    end
    return '--shell=sh'
  end)
  local vanila_parser = shellcheck.parser
  shellcheck.parser = function(output) -- add source field to diagnostic data
    return vim.tbl_map(function(diag)
      diag.source = 'shellcheck'
      return diag
    end, vanila_parser(output))
  end

  lint.linters.eslint.cmd = 'eslint_d'
  lint.linters_by_ft = {
    sh = { 'shellcheck' },
    cpp = { 'cppcheck' }
  }
  -- lint.linters_by_ft = vim.tbl_extend('keep', {
  --   sh = { 'shellcheck' },
  --   cpp = { 'cppcheck' }
  -- }, tablex.reduce(function(ac, v)
  --   ac[v] = { 'eslint' }
  --   return ac
  -- end, eslint_filetype, {}))
end

--
-- Typescript
--
local function const(v)
  return function()
    return v
  end
end

local function diagnostic_highlight(text, line)
  local type_hl_idx = 0
  local pats = {
    {
      [[[tT]ype '[^']+']],
      function()
        local ret = type_hl_idx % 2 == 0 and 'TSType' or 'TSKeyword'
        type_hl_idx = (type_hl_idx + 1) % 2
        return ret
      end
    },
    { [[[sS]ignature '[^']+']], const('TSInclude') },
    { [[[oO]verload %d of %d, '[^']+']], const('TSFunction') }
  }
  local rest = line
  local done = true
  while #rest > 0 do
    local q1, q2 = string.find(rest, [['[^']+']])

    -- found something in quotes
    if q1 then
      local quote_area = string.sub(rest, 0, q2)

      for _, pat in ipairs(pats) do
        local rexp, hl_func = unpack(pat)
        local _, e = string.find(quote_area, rexp)
        -- quote_area is one of interested pats
        if e == q2 then
          text:append(string.sub(rest, 0, q1)) -- prefix
          text:append(string.sub(rest, q1 + 1, q2 - 1), hl_func()) -- type
          text:append('\'')
          rest = string.sub(rest, q2 + 1)
          done = false
          break
        end
      end
    end

    if done then
      text:append(rest)
      return
    end
    done = true
  end
end

--
-- Diagnostics UI
--

local function show_line_diagnostics()
  local bufnr = api.nvim_get_current_buf()
  local line_nr = api.nvim_win_get_cursor(0)[1] - 1
  local opts = {}
  local line_diag_idx = {}

  local line_diagnostics = lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts)
  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  local text = Text:new()
  -- local diag_idx_by_text = {}
  for diag_idx, diagnostic in ipairs(line_diagnostics) do
    local name = '?'
    local code = diagnostic.code or diagnostic.severity
    if diagnostic.source then
      name = client_info[diagnostic.source].short_name or diagnostic.source
    end
    local hiname = severities[diagnostic.severity].hl_float
    assert(hiname, 'unknown severity: ' .. tostring(diagnostic.severity))
    text:append(name .. '_' .. code .. ': ', hiname)
    local lines = vim.fn.split(diagnostic.message, '\n', true)
    for _, line in ipairs(lines) do
      if name == 'TS' then
        diagnostic_highlight(text, line)
      else
        text:append(line)
      end
      text:newline()
      table.insert(line_diag_idx, diag_idx)
    end
  end

  opts.focus_id = 'line_diagnostics'
  opts.max_width = math.floor(vim.fn.winwidth(0) * 0.8)
  local float_bufnr, float_winnr = text:render_in_float(opts)

  local function disable()
    -- Current window is diagnostic float
    local idx = line_diag_idx[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local dl_pattern = client_info[source].diagnostic_disable_line
    if dl_pattern then
      api.nvim_buf_delete(float_bufnr, {})
      local line = api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
      print(vim.inspect(line))
      local indent_spaces = string.sub(line, string.find(line, '%s*'))
      local dl = indent_spaces .. string.gsub(dl_pattern, '%${code}', line_diagnostics[idx].code)
      api.nvim_buf_set_lines(bufnr, line_nr, line_nr, false, { dl })
      vim.cmd('write ' .. tostring(vim.fn.bufname(bufnr)))
    end
  end

  local function webpage()
    local idx = line_diag_idx[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local diagnostic_webpag = client_info[source].diagnostic_webpage
    if diagnostic_webpag then
      local uri = type(diagnostic_webpag) == 'string' and
                    string.gsub(diagnostic_webpag, '%${code}', line_diagnostics[idx].code) or
                    diagnostic_webpag(line_diagnostics[idx])
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
  require('compe').setup {
    enabled = true,
    autocomplete = false,
    source = {
      nvim_lsp = true
    },
    preselect = 'always'
  }

  local t = func.bind(api.nvim_replace_termcodes, func._1, true, true, true)
  local luasnip = require 'luasnip'
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

  return on_tab, on_cn, on_cp -- , on_ce
end

--
-- Mappings and (auto)commands
--
do
  local on_tab, on_cn, on_cp = compe_setup()
  local ss = SymbolSelectors()

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

  -- Refactor
  map('n', '<leader>ln', lsp.buf.rename)

  -- Less in use
  map('n', 'gi', lsp.buf.implementation)
  map('nx', '<M-j>', lsp.buf.signature_help) -- C-;
  map('n', 'gD', lsp.buf.declaration)
  map('n', 'ga', lsp.buf.code_action)

  -- Symbol lists
  map('n', '<leader>ls', ss.document_list_non_props)
  map('n', '<leader>lS', ss.document_list_symbols)
  map('n', '<leader>lf', ss.document_list_functions)
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
