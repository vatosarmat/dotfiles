call setenv("STD_PATH_CONFIG", stdpath('config'))
call setenv("LUA_PATH", printf('%s;%s/?.lua', $LUA_PATH, stdpath('config')))

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/utils_options.vim
lua << END
_G.service = {}
_G._augroup = {}
_G._map = {}
END
luafile $STD_PATH_CONFIG/plug.lua
