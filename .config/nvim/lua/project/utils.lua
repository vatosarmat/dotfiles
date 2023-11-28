local utils = require 'utils'

local M = {}

-- @param current_buf_path string
function M.mates_same_basepath(current_buf_path)
  local full_path = vim.fn.fnamemodify(current_buf_path, ':p')
  local base_path = full_path:match '.*/[^/.]+'
  return vim.tbl_map(
    function(file_path)
      return vim.fn.fnamemodify(file_path, ':p')
    end,
    vim.fn.readdir(full_path, function(p)
      return vim.startswith(p, base_path) and 1 or 0
    end)
  )
end

-- @param current_buf_path string
function M.mates_same_dir(current_buf_path)
  local dir_path = vim.fn.fnamemodify(current_buf_path, ':p:h')
  return vim.tbl_map(
    function(file_name)
      return dir_path .. '/' .. file_name
    end,
    vim.fn.readdir(dir_path, function(p)
      return p ~= '.shada'
    end)
  )
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

function M.json_with_key_readable(json_path, ...)
  if vim.fn.filereadable(json_path) == 1 then
    local text = table.concat(vim.fn.readfile(json_path), '\n')
    local status, table = pcall(vim.json.decode, text)
    if status and table then
      return vim.tbl_get(table, ...)
    end
  end

  return false
end

return M
