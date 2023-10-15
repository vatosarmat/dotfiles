vim.cmd [[
call setenv("STD_PATH_CONFIG", stdpath('config'))
source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/ustate.vim
source $STD_PATH_CONFIG/before-plug/uopts.vim

packadd cfilter
]]

if not _U then
  _G._U = {
    lsp = {},
    augroup = {},
    map = { global = {} },
    shortmap = {},
    symbol_navigation = {},
    buffer_navigation = {},
    ts_inc_sel_injected = false,
  }
else
  print '_U already defined!'
end

_G.pack = function(...)
  return { ... }
end
_G.fnoop = function(...)
  return ...
end
_G.fconst = function(v)
  return function()
    return v
  end
end

-- local log_file = vim.fn.stdpath 'cache' .. '/ilog.log'

-- vim.fn.delete(log_file)

_G.ilog = function(str)
  -- local name = debug.getinfo(2, 'n').name
  -- vim.fn.writefile({ (name or 'NO_NAME') .. ': ' .. str }, log_file, 'a')
end

require 'plug'
