local func = require 'pl.func'
local bind1 = require'pl.func'.bind1
local bind = require'pl.func'.bind
local dap = require "dap"
local widgets = require 'dap.ui.widgets'
local dutils = require 'dap.utils'
local shortmap = require 'before-plug.shortmap'

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
    host = function()
      local value = vim.fn.input('Host [127.0.0.1]: ')
      if value ~= "" then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      local val = tonumber(vim.fn.input('Port: '))
      assert(val, "Please provide a port number")
      return val
    end
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host, port = config.port })
end

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

  mapn('b', dap.toggle_breakpoint, '<C-b>')

  mapn('c', dap.continue)
  mapn('p', dap.pause)

  mapn('i', dap.step_into, '<M-o>')
  mapn('s', dap.step_over, 'o')
  mapn('o', dap.step_out, 'O')

  mapn('u', dap.up)
  mapn('d', dap.down)

  mapn('R', dap.repl.toggle)

  mapn('f', bind1(widgets.sidebar, widgets.frames))
  mapn('v', bind1(widgets.sidebar, widgets.scopes))
  mapn('h', widgets.hover, '<Home>')
  map('x', 'h', bind1(widgets.hover, dutilsget_visual_selection_text), '<Home>')

  mapn('K', bind1(shortmap.toggle, 'debug'))

  shortmap.define('debug', short_mappings)
end

vim.fn['utils#Cnoreabbrev']('osv', 'lua require"osv".launch()')
