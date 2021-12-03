
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

function _G.noop(...)
  return ...
end

function _G.pprint(value)
  print(vim.inspect(value))
end
function _G.const(v)
  return function()
    return v
  end
end

local home = os.getenv('HOME')
local here = ".cache/nvim/packer_hererocks/2.1.0-beta3"
local paths = {
  "share/lua/5.1",
  "lib/luarocks/rocks-5.1"
}
local package_path_str = string.format('%s/?.lua', vim.fn.stdpath('config'))
for _, path in ipairs(paths) do
  package_path_str = string.format('%s;%s/%s/%s/?.lua', package_path_str, home, here, path)
  package_path_str = string.format('%s;%s/%s/%s/?/init.lua', package_path_str, home, here, path)
end
package.path = package_path_str
package.cpath = string.format('%s/%s/lib/lua/5.1/?.so', home, here)

END
luafile $STD_PATH_CONFIG/plug.lua
