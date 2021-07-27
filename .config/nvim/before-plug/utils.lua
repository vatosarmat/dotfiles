local tablex = require 'pl.tablex'

local M = {}

function M.omit(tbl, idx)
  local res = tablex.deepcopy(tbl)
  for i = 1, #idx do
    res[idx[i]] = nil
  end

  return res
end

return M
