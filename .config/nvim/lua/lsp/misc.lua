local util = vim.lsp.util
local tbl_map, trim, api = vim.tbl_map, vim.trim, vim.api

local M = {}

function M.diagnostic_get_code(diagnostic)
  if diagnostic.code then
    return diagnostic.code
  end
  local u = diagnostic.user_data
  if u then
    local l = u.lsp
    if l and l.code then
      return l.code
    end
  end
  return diagnostic.severity
end

function M.get_bufnr(bufnr)
  if not bufnr or bufnr == 0 then
    return api.nvim_get_current_buf()
  end
  return bufnr
end

function M.locations_to_items(list, encoding)
  return tbl_map(function(item)
    item.text = trim(item.text)
    return item
  end, util.locations_to_items(list, encoding))
end

return M
