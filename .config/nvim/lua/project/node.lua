local M = {}

function M.configure()
  return {
    is_prettier = false,
    -- is_prettier = vim.fn.filereadable './.prettierrc' == 1
    --   or vim.fn.filereadable './.prettierrc.json' == 1,
  }
end

return M
