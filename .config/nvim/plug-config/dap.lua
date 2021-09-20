local func = require 'pl.func'
local bind1 = require'pl.func'.bind1
local bind = require'pl.func'.bind
local dap = require "dap"
local widgets = require 'dap.ui.widgets'
local dutils = require 'dap.utils'
local shortmap = require 'before-plug.shortmap'

local function debugee_cmd_input(_config, done)
  local config = vim.deepcopy(_config)
  local from_clipboard = vim.trim(vim.fn.getreg('+'))
  local cmd = vim.trim(vim.fn
                         .input('Cmd to debug: ', from_clipboard, 'shellcmd'))
  local words = vim.gsplit(cmd, ' ', true)

  config.program = words()
  config.args = {}

  for w in words do
    table.insert(config.args, w)
  end

  done(config)
end

vim.fn.sign_define('DapBreakpoint', {
  text = '',
  texthl = 'DapBreakpointSign',
  linehl = 'DapBreakpointLine'
})

vim.fn.sign_define('DapStopped', {
  text = '',
  texthl = 'DapStoppedSign',
  linehl = 'DapStoppedLine'
})

dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = "Attach to running Neovim instance",
    -- host = function()
    --   local value = vim.fn.input('Host [127.0.0.1]: ')
    --   if value ~= "" then
    --     return value
    --   end
    --   return '127.0.0.1'
    -- end,
    host = '127.0.0.1',
    port = '40001'
    -- port = function()
    --   local val = tonumber(vim.fn.input('Port: '))
    --   assert(val, "Please provide a port number")
    --   return val
    -- end
  }
}

dap.adapters.nlua = function(callback, config)
  callback({
    type = 'server',
    host = config.host,
    port = config.port
  })
end

dap.adapters.cppdbg = {
  type = 'executable',
  command = '/home/igor/.local/bin/OpenDebugAD7',
  name = 'gdb',
  enrich_config = debugee_cmd_input
}

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode',
  name = "lldb",
  enrich_config = debugee_cmd_input
}

-- https://microsoft.github.io/debug-adapter-protocol/specification
-- https://code.visualstudio.com/docs/editor/variables-reference#_predefined-variables-examples
-- https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
dap.configurations.cpp = {
  {
    name = "LLDB launch",
    type = "lldb",
    request = "launch",
    cwd = '${workspaceFolder}',
    stopOnEntry = false

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
  }, {
    {
      -- If you get an "Operation not permitted" error using this, try disabling YAMA:
      --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      name = "Attach to process",
      type = 'lldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {}
    }
  }, {
    name = "GDB launch",
    type = "cppdbg",
    request = "launch",
    cwd = '${workspaceFolder}',
    stopOnEntry = true
  }
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

--
--
-- Mappings
--
do
  local short_mappings = {}

  local function map(mode, key, command, short)
    key = '<leader>d' .. key
    require'before-plug.vim_utils'.map(mode, key, command)
    if short then
      table.insert(short_mappings, { mode, short, key })
    end
  end

  local mapn = bind(map, 'n', func._1, func._2, func._3)

  local function sidebar_frames() widgets.sidebar(widgets.frames).open() end

  local function sidebar_scopes() widgets.sidebar(widgets.scopes).open() end

  mapn('b', dap.toggle_breakpoint, '<C-b>')

  mapn('c', dap.continue)
  mapn('p', dap.pause)
  mapn('r', dap.run_to_cursor, 'r')

  mapn('i', bind1(dap.step_into, {
    steppingGranularity = 'statement',
    askForTargets = true
  }), 'i')
  mapn('s', dap.step_over, 'o')
  mapn('o', dap.step_out, 'O')

  mapn('u', dap.up)
  mapn('d', dap.down)

  mapn('h', widgets.hover, '<Home>')
  map('x', 'h', bind1(widgets.hover, dutils.get_visual_selection_text), '<Home>')

  mapn('R', dap.repl.toggle)
  mapn('f', sidebar_frames, 'gf')
  mapn('v', sidebar_scopes, 'gv')
  mapn('<M-f>', bind1(widgets.centered_float, widgets.frames), '<M-f>')
  mapn('<M-v>', bind1(widgets.centered_float, widgets.scopes), '<M-v>')

  mapn('K', bind1(shortmap.toggle, 'debug'))

  shortmap.define('debug', short_mappings)
end

vim.fn['utils#Cnoreabbrev']('osv', 'lua require"osv".launch({port = 40001})')
vim.fn['utils#Cnoreabbrev']('osvl',
                            'lua require"osv".launch({log = true, port = 40001})')
