local tablex = require 'pl.tablex'

local utils = {}

function utils.omit(tbl, idx)
  local res = tablex.deepcopy(tbl)
  for i = 1,#idx do
    res[idx[i]] = nil
  end

  return res
end

return utils
