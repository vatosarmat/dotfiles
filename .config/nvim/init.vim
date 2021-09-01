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
  _G._map = {
    global = {}
  }
end
if not _shortmap then
  _G._shortmap = {}
end
function _G.pprint(value)
  print(vim.inspect(value))
end
--Copied from packer_compiled.lua. Need rocks to be available before all other lua plugins
local package_path_str = "/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/igor/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end
END
luafile $STD_PATH_CONFIG/plug.lua
