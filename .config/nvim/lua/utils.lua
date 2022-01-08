local tablex = require 'pl.tablex'

local M = {}

function M.omit(tbl, keys)
  local res = tablex.deepcopy(tbl)

  for _, key in ipairs(keys) do
    res[key] = nil
  end

  return res
end

function M.pick(tbl, keys)
  local res = {}

  for _, key in ipairs(keys) do
    res[key] = tbl[key]
  end

  return res
end

function M.key_by(lst, key)
  local res = {}
  for _, v in ipairs(lst) do
    res[v[key]] = v
  end
  return res
end

return M