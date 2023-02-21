local lsp = vim.lsp
local bind1 = require'pl.func'.bind1
local lspconfig = require 'lspconfig'
local lspconfig_util = require 'lspconfig.util'
local autocmd = require'vim_utils'.autocmd
local lsp_flags = require 'lsp.flags'
local null_ls = require 'null-ls'
local neodev = require 'neodev'
local ts_utils = require 'nvim-lsp-ts-utils'
local typescript = require 'typescript'
local typescript_null_ls = require('typescript.extensions.null-ls.code-actions')
local schemastore = require('schemastore')

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
local prettier_filetype = vim.list_extend({ 'css', 'scss', 'json', 'jsonc', 'vue', 'handlebars' },
                                          jsts_filetype)
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
  if client.server_capabilities.documentHighlightProvider then
    autocmd('LSP_buffer', -------------------------------------------------------
    {
      { 'CursorHold', document_highlight }, -----------------------
      { 'CursorMoved', lsp.buf.clear_references }
    }, {
      buffer = true
    })
  end
end

local function setup_tsserver()

  -- {predicate, post}
  -- string
  --
  local function setup(pp, server_name, setup_params)
    local server_config = lspconfig[server_name]
    -- vim.pretty_print(server_config)
    if type(setup_params) == 'function' then
      setup_params()
    else
      server_config.setup(setup_params or {})
    end
    local server_manager_add = server_config.manager.add
    server_config.manager.add = function(...)
      local res
      if not pp.predicate or (pp.predicate and pp.predicate()) then
        res = server_manager_add(...)
        if pp.post then
          pp.post()
        end
      end
      return res
    end
  end

  setup({
    post = function()
      vim.b.flow_active = true
    end
  }, 'flow')

  -- local tsserver = lspconfig.tsserver
  -- local ts_utils_settings = {
  --   -- debug = true,
  --   -- import_all_scan_buffers = 100
  --   -- I really need this?
  --   -- eslint_bin = 'eslint_d',
  --   -- eslint_enable_diagnostics = true,
  --   -- eslint_opts = {
  --   --   condition = function(utils)
  --   --     return utils.root_has_file('.eslintrc.js')
  --   --   end,
  --   --   diagnostics_format = '#{m} [#{c}]'
  --   -- },
  --   -- enable_formatting = true,
  --   -- formatter = 'eslint_d',
  --   -- update_imports_on_move = true,
  --   -- filter out dumb module warning
  --   -- https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
  --   filter_out_diagnostics_by_code = {
  --     6133, -- '{0}' is declared but its value is never read.
  --     6196, -- '{0}' is declared but never used.
  --     80001, -- "File is a CommonJS module; it may be converted to an ES module."
  --     80006 -- "This may be converted to an async function."
  --   }
  -- }
  -- setup({
  --   predicate = function()
  --     return not vim.b.flow_active
  --     -- and vim.g.project.kind ~= 'vue'
  --   end
  -- }, 'tsserver', {
  --   -- filetypes = vim.list_extend(jsts_filetype, { 'vue' }),
  --   on_attach = function(client, bufnr)
  --     client.server_capabilities.documentFormattingProvider = false
  --     -- client.resolved_capabilities.rangeFormatting = false
  --     default_on_attach(client, bufnr)
  --
  --     ts_utils.setup(ts_utils_settings)
  --     ts_utils.setup_client(client)
  --
  --     -- map_buf(bufnr, 'n', 'gs', '<cmd>TSLspOrganize<CR>')
  --     -- map_buf(bufnr, 'n', 'gI', '<cmd>TSLspRenameFile<CR>')
  --     -- map_buf(bufnr, 'n', 'go', '<cmd>TSLspImportAll<CR>')
  --     -- map_buf(bufnr, 'n', 'qq', '<cmd>TSLspFixCurrent<CR>')
  --   end
  --   -- root_dir = lspconfig_util.find_git_ancestor
  -- })

  setup({
    predicate = function()
      return vim.g.project.kind == 'vue'
    end,
    post = function()
      vim.b.volar_active = true
    end
  }, 'volar', {
    filetypes = vim.list_extend(jsts_filetype, { 'vue' }),
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      -- client.resolved_capabilities.rangeFormatting = false
      default_on_attach(client, bufnr)
    end
  })

  setup({
    predicate = function()
      return not (vim.b.flow_active or vim.b.volar_active)
    end
  }, 'tsserver', bind1(typescript.setup, {
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    go_to_source_definition = {
      fallback = true -- fall back to standard LSP definition on failure
    },
    server = { -- pass options to lspconfig's setup method
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        -- client.resolved_capabilities.rangeFormatting = false
        default_on_attach(client, bufnr)
      end
    }
  }))

  -- setup({
  --   predicate = function()
  --     return vim.g.project.kind == 'vue'
  --   end
  -- }, 'vuels', {
  --   -- filetypes = vim.list_extend(jsts_filetype, { 'vue' })
  -- })

  setup({
    predicate = function()
      return vim.g.project.kind == 'angular'
    end
  }, 'angularls')

end

local function setup_null_ls()
  local f = null_ls.builtins.formatting
  local d = null_ls.builtins.diagnostics
  local sources = {
    d.shellcheck.with({
      runtime_condition = function(params)
        return not string.match(params.bufname, '%.env%.?%l*$')
      end,

      extra_args = function(params)
        return vim.endswith(params.bufname, '.bash') and { '--shell=bash' } or {}
      end
    }),
    f.shfmt.with({
      extra_args = { '-i', '2', '-ci', '-sr' }
    }),
    f.lua_format,
    lsp_flags.prettier_with_d and f.prettierd.with({
      filetypes = prettier_filetype,
      env = {
        PRETTIERD_DEFAULT_CONFIG = os.getenv('HOME') .. '/.config/.prettierrc.json'
      }
    }) or f.prettier.with({
      filetypes = prettier_filetype
      -- only_local = 'node_modules/.bin'
    }),
    f.autopep8,
    typescript_null_ls,
    -- f.phpcsfixer.with {
    --   env = {
    --     PHP_CS_FIXER_IGNORE_ENV = 'true'
    --   }
    -- },
    f.pint.with {
      dynamic_command = function(params)
        -- {
        --   bufname = "/home/igor/Code/Playground/php-pg/src/foo.php",
        --   bufnr = 3,
        --   client_id = 2,
        --   col = 0,
        --   command = "./vendor/bin/pint",
        --   content = ....
        --   ft = "php",
        --   lsp_method = "textDocument/formatting",
        --   method = "NULL_LS_FORMATTING",
        --   options = {
        --     insertSpaces = true,
        --     tabSize = 4
        --   },
        --   root = "/home/igor/Code/Playground/php-pg",
        --   row = 7
        -- }
        --
        -- vim.pretty_print(params)
        return vim.g.project.has_local_pint and params.command or 'pint'
      end
    },
    f.blade_formatter
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

  neodev.setup({})

  local cache = vim.fn.stdpath('cache')
  lspconfig.sumneko_lua.setup({
    cmd = { 'sumneko', '2>', vim.fn.stdpath 'cache' .. '/sumneko.log' },
    settings = {
      Lua = {
        completion = {
          workspaceWord = false,
          showWord = 'Disable',
          callSnippet = 'Replace'
        },
        diagnostics = {
          globals = { 'vim', '_U', 'use', 'pack', 'use_rocks', 'fnoop', 'fconst' }
        },
        workspace = {
          library = { cache .. '/rocks' }
        }
      }
    }
  })
  lspconfig.rust_analyzer.setup {}
  lspconfig.vimls.setup {}
  lspconfig.bashls.setup {}
  lspconfig.pyright.setup {}
  lspconfig.cmake.setup {}
  lspconfig.html.setup {
    -- init_options = {
    --   provideFormatter = false
    -- }
  }
  lspconfig.cssls.setup {}
  lspconfig.jsonls.setup {
    filetypes = { 'jsonc' },
    init_options = {
      provideFormatter = false
    },
    settings = {
      json = {
        schemas = schemastore.json.schemas(),
        validate = {
          enable = true
        }
      }
    }
  }
  lspconfig.yamlls.setup {}
  lspconfig.eslint.setup {
    -- settings = {
    --   format = true,
    --   workingDirectory = {
    --     mode = 'location'
    --   }
    -- }
    -- root_dir = lspconfig_util.find_git_ancestor
  }
  lspconfig.solargraph.setup {}
  lspconfig.intelephense.setup {
    filetypes = { 'php', 'blade' },
    on_attach = function(client, bufnr)
      -- client.server_capabilities.formatting = false
      client.server_capabilities.documentFormattingProvider = false
      -- client.resolved_capabilities.rangeFormatting = false
      default_on_attach(client, bufnr)
    end
  }
  -- lspconfig.phpactor.setup {
  --   capabilities = capabilities
  -- }
  -- require'lspconfig'.tailwindcss.setup {}

  setup_cpp()
  setup_tsserver()
  setup_null_ls()
end

return M
