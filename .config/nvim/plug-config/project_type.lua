vim.g.project_type = 'generic'

if vim.fn.filereadable(vim.fn.FindRootDirectory() .. '/CMakeLists.txt') then
  vim.g.project_type = 'cmake'
end
