local M = {}

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

function M.single_or_list(dst, item)
  if dst == nil then
    return item
  end
  table.insert(dst, item)
  return dst
end

function M.b(func, ...)
  local ba = { ... }
  return function(...)
    func(unpack(ba), ...)
  end
end

function M.reduce(array, cb, initial)
  local accum = initial
  for i, v in ipairs(array) do
    accum = cb(accum, v, i)
  end
  return accum
end

function M.find(array, cb)
  for i, v in ipairs(array) do
    if cb(v, i) then
      return v, i
    end
  end

  return nil, nil
end

function M.make_set(array)
  local ret = {}
  for _, v in ipairs(array) do
    ret[v] = true
  end

  return ret
end

function M.compose(...)
  local fnchain = { ... }
  return function(...)
    local args = { ... }
    for _, fn in ipairs(fnchain) do
      args = { fn(unpack(args)) }
    end
    return unpack(args)
  end
end

function M.times(str, n)
  local ret = ''
  while n > 0 do
    ret = ret .. str
    n = n - 1
  end

  return ret
end

return M
