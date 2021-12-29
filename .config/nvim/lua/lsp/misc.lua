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

return M
