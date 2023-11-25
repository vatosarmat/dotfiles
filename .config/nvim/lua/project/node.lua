local M = {}

M.jsts_filetype = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.jsx',
}

M.prettier_filetype =
  vim.list_extend({ 'css', 'scss', 'jsonc', 'vue', 'handlebars' }, M.jsts_filetype)

function M.configure()
  return {
    prettier_filetype = M.prettier_filetype,
  }
end

return M
