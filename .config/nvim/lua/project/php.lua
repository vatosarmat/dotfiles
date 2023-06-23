local M = {}

function M.configure()
  return {
    pint = vim.fn.executable('./vendor/bin/pint') == 1 and './vendor/bin/pint' or 'pint'
  }
end

return M
