call setenv("STD_PATH_CONFIG", stdpath('config'))
call setenv("LUA_PATH", printf('%s/?.lua', stdpath('config')))
call setenv("LUA_CPATH", '')

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/utils_options.vim
lua << END
_G.service = {}
_G._augroup = {}
_G._map = {}
_G._shortmap = {}
function _G.pprint(value)
  print(vim.inspect(value))
end
END
luafile $STD_PATH_CONFIG/plug.lua
