local M = {}

function M.configure()
  return {
    is_prettier = true,
    -- is_prettier = vim.fn.filereadable './.prettierrc' == 1
    --   or vim.fn.filereadable './.prettierrc.json' == 1,
  }
end

return M
