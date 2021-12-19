
call setenv("STD_PATH_CONFIG", stdpath('config'))

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/ustate.vim
source $STD_PATH_CONFIG/before-plug/uopts.vim
packadd cfilter

lua << END
_G.pack = function(...) return { ... } end
if not service then
  _G.service = {}
end
if not _augroup then
  _G._augroup = {}
end
if not _map then
  _G._map = {
    global = {}
  }
end
if not _shortmap then
  _G._shortmap = {}
end

function _G.fnoop(...)
  return ...
end

function _G.pprint(value)
  print(vim.inspect(value))
end

function _G.fconst(v)
  return function()
    return v
  end
end

END
luafile $STD_PATH_CONFIG/lua/plug.lua
