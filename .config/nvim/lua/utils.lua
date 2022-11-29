local tablex = require 'pl.tablex'

local M = {}

-- Such impl is slow
-- function M.omit(tbl, keys)
--   local res = tablex.deepcopy(tbl)
--
--   for _, key in ipairs(keys) do
--     res[key] = nil
--   end
--
--   return res
-- end

-- penlight index_by??
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

function M.extend_keys(dst, src, keys)
  for _, key in ipairs(keys) do
    local v = src[key]
    if v then
      if vim.tbl_islist(dst[key]) and vim.tbl_islist(v) then
        vim.list_extend(dst[key], v)
      else
        dst[key] = v
      end
    end
  end
end

return M
