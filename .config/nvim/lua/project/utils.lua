local utils = require 'utils'

local M = {}

-- @param current_buf_path string
function M.mates_same_basepath(current_buf_path)
  local full_path = vim.fn.fnamemodify(current_buf_path, ':p')
  local base_path = full_path:match '.*/[^/.]+'
  local ret = vim.fn.glob(base_path .. '.*', false, true)

  return ret
end

-- @param current_buf_path string
function M.mates_same_dir(current_buf_path)
  local dir_path = vim.fn.fnamemodify(current_buf_path, ':p:h')
  local ret = vim.fn.glob(dir_path .. '/*', false, true)

  return ret
end

-- @param list_of_mates string[][]
-- @param current_buf_path string
function M.mates_list(mates_list, current_buf_path)
  return vim.tbl_map(function(rel_path)
    return vim.fn.fnamemodify(rel_path, ':p')
  end, utils.find(mates_list, function(mates)
    return utils.find(mates, function(mate)
      return vim.endswith(current_buf_path, mate)
    end)
  end) or {})
end

return M
