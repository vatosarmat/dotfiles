call setenv("STD_PATH_CONFIG", stdpath('config'))
call setenv("LUA_PATH", printf('%s/?.lua', stdpath('config')))
call setenv("LUA_CPATH", '')

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/utils_options.vim
lua << END
if not service then
  _G.service = {}
end
if not _augroup then
  _G._augroup = {}
end
if not _map then
  _G._map = {}
end
if not _shortmap then
  _G._shortmap = {}
end
function _G.pprint(value)
  print(vim.inspect(value))
end
END
luafile $STD_PATH_CONFIG/plug.lua
