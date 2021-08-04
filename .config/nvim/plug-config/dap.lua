local dap = require "dap"

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

local function map(key, command)
  require'before-plug.vim_utils'.map('n', '<leader>d' .. key, command)
end

map('b', dap.toggle_breakpoint)
map('c', dap.continue)

