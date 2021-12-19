local lsp = vim.lsp
-- local tablex = require 'pl.tablex'
local lspconfig = require 'lspconfig'
local lspconfig_util = require 'lspconfig.util'
local autocmd = require'vim_utils'.autocmd
local lsp_flags = require 'lsp.flags'
local null_ls = require 'null-ls'
local luadev = require 'lua-dev'
local ts_utils = require 'nvim-lsp-ts-utils'
local json_schemas = require 'json_schemas'
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

local function setup_ts_flow()
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

local function setup_null_ls()
  local f = null_ls.builtins.formatting
  local d = null_ls.builtins.diagnostics
  local sources = {
    d.shellcheck.with({
      extra_args = function(params)
        return vim.endswith(params.bufname, '.bash') and { '--shell=bash' } or {}
      end
    }),
    f.shfmt.with({
      extra_args = { '-i', '2', '-ci', '-sr' }
    }),
    f.lua_format,
    lsp_flags.prettier_with_d and f.prettierd.with({
      filetypes = prettier_filetype
      -- command = 'PRETTIERD_LOCAL_PRETTIER_ONLY=true prettierd'
    }) or f.prettier.with({
      filetypes = prettier_filetype,
      only_local = 'node_modules/.bin'
    })
  }

  null_ls.setup {
    debug = lsp_flags.null_ls_debug,
    sources = sources,
    update_on_insert = true
  }
end

local function setup_cpp()
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

  lspconfig.sumneko_lua.setup(luadev.setup {
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
              'fnoop',
              'fconst'
            }
          }
        }
      }
    }
  })
  lspconfig.rust_analyzer.setup {}
  lspconfig.vimls.setup {}
  lspconfig.bashls.setup {}
  lspconfig.pyright.setup {}
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
        schemas = json_schemas
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

  setup_cpp()
  setup_ts_flow()
  setup_null_ls()
end

return M
