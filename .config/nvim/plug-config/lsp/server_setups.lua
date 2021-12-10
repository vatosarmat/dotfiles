local lsp = vim.lsp
local tablex = require 'pl.tablex'
local lspconfig = require 'lspconfig'
local lspconfig_util = require 'lspconfig.util'
local lint = require 'lint'
local autocmd = require'before-plug.vim_utils'.autocmd
local lsp_flags = require 'plug-config.lsp.flags'
--
--
-- server.setup takes same parameters as lsp.start_client() + root_dir, name, filetypes, autostart, on_new_config
--
--
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

local M = {}

function M.setup(capabilities)
  lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
    autostart = lsp_flags.lsp_autostart,
    flags = {
      debounce_text_changes = 500
    },
    capabilities = capabilities,
    on_attach = default_on_attach
  })

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
                'noop',
                'const'
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
      -- https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
      filter_out_diagnostics_by_code = {
        6133, -- '{0}' is declared but its value is never read.
        6196, -- '{0}' is declared but never used.
        80001, -- "File is a CommonJS module; it may be converted to an ES module."
        80006 -- "This may be converted to an async function."
      }
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
    if not lsp_flags.ts_formatter_efm then
      local null_ls = require 'null-ls'
      local b = null_ls.builtins

      local prettier_source = lsp_flags.prettier_with_d and b.formatting.prettierd.with({
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
        debug = lsp_flags.null_ls_debug,
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
          formatCommand = lsp_flags.lua_stylua and 'stylua -' or 'lua-format -i',
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

    if lsp_flags.ts_formatter_efm then
      local prettier_format = {
        formatCommand = lsp_flags.prettier_with_d and
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
end

return M
