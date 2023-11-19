local M = {}

M.jsts_filetype = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.jsx',
}

function M.configure()
  return {
    prettier_filetype = vim.list_extend(
      { 'css', 'scss', 'jsonc', 'vue', 'handlebars', 'html' },
      M.jsts_filetype
    ),
  }
end

return M
