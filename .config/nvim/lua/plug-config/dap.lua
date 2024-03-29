local b = require('utils').b
local dap = require 'dap'
local widgets = require 'dap.ui.widgets'
local dap_utils = require 'dap.utils'
local shortmap = require 'shortmap'

--
-- Langs
--
local function lua()
  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
      -- host = function()
      --   local value = vim.fn.input('Host [127.0.0.1]: ')
      --   if value ~= "" then
      --     return value
      --   end
      --   return '127.0.0.1'
      -- end,
      host = '127.0.0.1',
      port = '40001',
      -- port = function()
      --   local val = tonumber(vim.fn.input('Port: '))
      --   assert(val, "Please provide a port number")
      --   return val
      -- end
    },
  }

  dap.adapters.nlua = function(callback, config)
    callback {
      type = 'server',
      host = config.host,
      port = config.port,
    }
  end
end

local function cpp_rust()
  local function debugee_cmd_input(_config, done)
    local config = vim.deepcopy(_config)
    local from_clipboard = vim.trim(vim.fn.getreg '+')
    local cmd = vim.trim(vim.fn.input('Cmd to debug: ', from_clipboard, 'shellcmd'))
    local words = vim.gsplit(cmd, ' ', true)

    config.program = words()
    config.args = {}

    for w in words do
      table.insert(config.args, w)
    end

    done(config)
  end

  -- ADAPTERS
  dap.adapters.cppdbg = {
    type = 'executable',
    command = '${env:HOME}/.local/bin/OpenDebugAD7',
    name = 'gdb',
    enrich_config = debugee_cmd_input,
  }

  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode',
    name = 'lldb',
    enrich_config = debugee_cmd_input,
  }

  -- CONFIGURATIONS
  -- https://microsoft.github.io/debug-adapter-protocol/specification
  -- https://code.visualstudio.com/docs/editor/variables-reference#_predefined-variables-examples
  -- https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
  dap.configurations.cpp = {
    {
      name = 'LLDB launch',
      type = 'lldb',
      request = 'launch',
      cwd = '${workspaceFolder}',
      stopOnEntry = false,

      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
      --
      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      --
      -- Otherwise you might get the following error:
      --
      --    Error on launch: Failed to attach to the target process
      --
      -- But you should be aware of the implications:
      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
      -- runInTerminal = true
    },
    {
      {
        -- If you get an "Operation not permitted" error using this, try disabling YAMA:
        --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        name = 'Attach to process',
        type = 'lldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
        args = {},
      },
    },
    {
      name = 'GDB launch',
      type = 'cppdbg',
      request = 'launch',
      cwd = '${workspaceFolder}',
      stopOnEntry = true,
    },
    -- {
    --   name = 'Attach to gdbserver :1234',
    --   type = 'cppdbg',
    --   request = 'launch',
    --   MIMode = 'gdb',
    --   miDebuggerServerAddress = 'localhost:1234',
    --   miDebuggerPath = '/usr/bin/gdb',
    --   cwd = '${workspaceFolder}',
    --   program = function()
    --     return vim.fn
    --              .input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --   end
    -- }
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end

local function js_ts()
  -- dedicated plugin for adapter
  require('dap-vscode-js').setup {
    node_path = '/home/igor/Code/DistRun/asdf/installs/nodejs/18.16.1/bin/node', -- Path of node executable. Defaults to $NODE_PATH, and then "node"
    debugger_path = vim.fn.stdpath 'data' .. '/vscode-js-debug', -- Path to vscode-js-debug installation.
    -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
    -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
    -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
    -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
  }

  local C = dap.configurations

  -- https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md

  for _, language in ipairs { 'typescript', 'javascript' } do
    C[language] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'ts-node',
        --
        runtimeExecutable = './node_modules/.bin/ts-node',
        runtimeArgs = { 'src/index.ts' },
        skipFiles = {},
        outFiles = {
          '${workspaceFolder}/**/*.js',
          -- '!**/node_modules/**',
          -- '${workspaceFolder}/node_modules/@nestjs'
        },
        resolveSourceMapLocations = { '**' },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        --
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      -- {
      --   type = 'pwa-node',
      --   request = 'launch',
      --   name = 'NestJS build',
      --   --
      --   runtimeExecutable = './node_modules/.bin/nest',
      --   runtimeArgs = { 'build' },
      --   skipFiles = {},
      --   outFiles = {
      --     '${workspaceFolder}/**/*.js',
      --     -- '!**/node_modules/**',
      --     -- '${workspaceFolder}/node_modules/@nestjs'
      --   },
      --   resolveSourceMapLocations = { '**' },
      --   rootPath = '${workspaceFolder}',
      --   cwd = '${workspaceFolder}',
      --   --
      --   console = 'integratedTerminal',
      --   internalConsoleOptions = 'neverOpen',
      -- },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'NestJS start',
        --
        runtimeExecutable = './node_modules/.bin/nest',
        runtimeArgs = { 'start' },
        skipFiles = {},
        outFiles = {
          '${workspaceFolder}/**/*.js',
          -- '!**/node_modules/**',
          -- '${workspaceFolder}/node_modules/@nestjs'
        },
        resolveSourceMapLocations = { '**' },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        --
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Strapi develop',
        --
        runtimeExecutable = './node_modules/.bin/strapi',
        runtimeArgs = { 'develop' },
        skipFiles = {},
        outFiles = {
          '${workspaceFolder}/**/*.js',
          -- '!**/node_modules/**',
          -- '${workspaceFolder}/node_modules/@nestjs'
        },
        resolveSourceMapLocations = { '**' },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        --
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach',
        processId = b(dap_utils.pick_process, {
          filter = function(proc)
            return proc.name:find 'node%s+.*--inspect'
          end,
        }),
        cwd = '${workspaceFolder}',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Jest',
        -- trace = true, -- include debugger info
        -- runtimeExecutable = 'node',
        -- runtimeExecutable = './node_modules/.bin/jest',
        -- runtimeArgs = { '--runInBand' },
        runtimeArgs = {
          '${workspaceFolder}/node_modules/jest/bin/jest.js',
        },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      },
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Next.js dev',
        --
        runtimeExecutable = './node_modules/.bin/next',
        runtimeArgs = { 'dev' },
        skipFiles = {},
        outFiles = {
          '${workspaceFolder}/**/*.js',
          -- '!**/node_modules/**',
          -- '${workspaceFolder}/node_modules/@nestjs'
        },
        resolveSourceMapLocations = { '**' },
        rootPath = '${workspaceFolder}',
        cwd = '${workspaceFolder}',
        --
        console = 'integratedTerminal',
        internalConsoleOptions = 'neverOpen',
      }, -- {
      --   type = 'pwa-node',
      --   request = 'launch',
      --   name = 'Debug Mocha Tests',
      --   -- trace = true, -- include debugger info
      --   runtimeExecutable = 'node',
      --   runtimeArgs = { './node_modules/mocha/bin/mocha.js' },
      --   rootPath = '${workspaceFolder}',
      --   cwd = '${workspaceFolder}',
      --   console = 'integratedTerminal',
      --   internalConsoleOptions = 'neverOpen',
      -- },
    }
  end
end

local function php()
  dap.adapters.php = {
    type = 'executable',
    command = 'node',
    args = { vim.fn.stdpath 'data' .. '/vscode-php-debug/out/phpDebug.js' },
  }

  dap.configurations.php = {
    {
      type = 'php',
      request = 'launch',
      name = 'Xdebug stopped',
      port = 9003,
      stopOnEntry = true,
    },
    {
      type = 'php',
      request = 'launch',
      name = 'Xdebug running',
      port = 9003,
      stopOnEntry = false,
    },
  }
end

--
-- Mappings and UI
--
local function mappings()
  local short_mappings = {}

  local function common()
    local function map(mode, key, command, short)
      key = '<leader>d' .. key
      require('vim_utils').map(mode, key, command)
      if short then
        table.insert(short_mappings, { mode, short, key })
      end
    end

    local mapn = b(map, 'n')

    local function sidebar_frames()
      widgets.sidebar(widgets.frames).open()
    end

    local function sidebar_scopes()
      widgets.sidebar(widgets.scopes).open()
    end

    mapn('b', dap.toggle_breakpoint, '<C-b>')
    mapn('<M-B>', dap.set_exception_breakpoints, '<M-B>')
    -- mapn('<M-b>', set_exception_breakpoints, '<C-M-b>')

    mapn('c', dap.continue, 'c')
    mapn('p', dap.pause, 'p')
    mapn('r', dap.run_to_cursor, 'r')

    mapn(
      'i',
      b(dap.step_into, {
        steppingGranularity = 'statement',
        askForTargets = true,
      }),
      'i'
    )
    mapn('s', dap.step_over, 'o')
    mapn('o', dap.step_out, 'O')

    mapn('u', dap.up, 'U')
    mapn('d', dap.down, 'D')

    mapn('h', widgets.hover, '<Home>')
    map('x', 'h', b(widgets.hover, dap_utils.get_visual_selection_text), '<Home>')

    mapn('R', dap.repl.toggle, 'R')
    -- open sidebar
    mapn('f', sidebar_frames, 'gf')
    mapn('v', sidebar_scopes, 'gv')
    -- toggle centered float
    mapn('<M-f>', b(widgets.centered_float, widgets.frames), '<M-f>')
    mapn('<M-v>', b(widgets.centered_float, widgets.scopes), '<M-v>')

    mapn('K', b(shortmap.toggle, 'debug'))

    shortmap.define('debug', short_mappings)
  end

  local function osv()
    vim.fn['utils#Cnoreabbrev']('osv', 'lua require"osv".launch({port = 40001})')
    vim.fn['utils#Cnoreabbrev']('osvl', 'lua require"osv".launch({log = true, port = 40001})')
  end

  common()
  osv()
end

local function ui()
  vim.api.nvim_create_autocmd('BufHidden', {
    pattern = '\\[dap-terminal\\]*',
    callback = function(arg)
      vim.schedule(function()
        vim.api.nvim_buf_delete(arg.buf, {
          force = true,
        })
      end)
    end,
  })

  vim.fn.sign_define('DapBreakpoint', {
    text = '',
    texthl = 'DapBreakpointSign',
    linehl = 'DapBreakpointLine',
  })

  vim.fn.sign_define('DapStopped', {
    text = '',
    texthl = 'DapStoppedSign',
    linehl = 'DapStoppedLine',
  })
end

--
lua()
cpp_rust()
js_ts()
php()
--
mappings()
ui()
