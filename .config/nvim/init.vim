
call setenv("STD_PATH_CONFIG", stdpath('config'))

source $STD_PATH_CONFIG/before-plug/options.vim
source $STD_PATH_CONFIG/before-plug/ustate.vim
source $STD_PATH_CONFIG/before-plug/uopts.vim
packadd cfilter

lua << END

if not _U then
  _G._U = {
    lsp = {},
    augroup = {},
	    map = { global = {} },
    shortmap = {},
    symbol_navigation = {},
    buffer_navigation = {}
    }
else
  print('_U already defined!')
end

_G.pack = function(...) return { ... } end
_G.fnoop = function(...) return ... end
_G.fconst = function (v)  return function() return v end end

END
luafile $STD_PATH_CONFIG/lua/plug.lua
