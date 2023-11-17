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

-- local LOG = true

---@diagnostic disable-next-line: undefined-global
if LOG then
  local log_file_path = vim.fn.stdpath 'cache' .. '/ilog.log'

  vim.loop.fs_unlink(log_file_path)
  -- created file access mode
  -- 0660 = 432
  local log_file = vim.loop.fs_open(log_file_path, 'a', 432)

  _G.ilog = function(title, body)
    local name = debug.getinfo(2, 'n').name
    local bodyStr = body and '\n' .. vim.inspect(body) or ''

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.loop.fs_write(log_file, (name or 'NO_NAME') .. ': ' .. title .. bodyStr .. '\n\n')
  end
else
  _G.ilog = function() end
end

require 'plug'
