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

---@param behavior string Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... table
---@return table Merged table
function M.merge_tables(behavior, ...)
  if behavior ~= 'error' and behavior ~= 'keep' and behavior ~= 'force' then
    error('invalid "behavior": ' .. tostring(behavior))
  end

  if select('#', ...) < 2 then
    error(
      'wrong number of arguments (given '
        .. tostring(1 + select('#', ...))
        .. ', expected at least 3)'
    )
  end

  local ret = {}
  if vim._empty_dict_mt ~= nil and getmetatable(select(1, ...)) == vim._empty_dict_mt then
    ret = vim.empty_dict()
  end

  local function is_mergable(v)
    return type(v) == 'table' and (vim.tbl_isempty(v) or not vim.tbl_islist(v))
  end

  for i = 1, select('#', ...) do
    local source_tbl = select(i, ...)
    vim.validate { ['after the second argument'] = { source_tbl, 't' } }

    for key, source_val in pairs(source_tbl) do
      if vim.tbl_islist(source_val) and vim.tbl_islist(ret[key]) then
        vim.list_extend(ret[key], source_val)
      elseif is_mergable(source_val) and is_mergable(ret[key]) then
        ret[key] = M.merge_tables(behavior, ret[key], source_val)
      elseif behavior ~= 'force' and ret[key] ~= nil then
        if behavior == 'error' then
          error('key found in more than one map: ' .. key)
        end -- Else behavior is "keep".
      else
        ret[key] = source_val
      end
    end
  end

  return ret
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
