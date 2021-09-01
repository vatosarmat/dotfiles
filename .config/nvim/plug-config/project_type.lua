vim.g.project_type = 'generic'

local root = vim.fn.FindRootDirectory()

if vim.fn.filereadable(root .. '/CMakeLists.txt') == 1 then
  vim.g.project_type = 'cmake'
elseif vim.fn.filereadable(root .. '/Cargo.toml') == 1 then
  vim.g.project_type = 'rust'
end
