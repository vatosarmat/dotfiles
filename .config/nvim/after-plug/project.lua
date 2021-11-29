local common_exclude_files = { '.git', '.shada' }

vim.g.project = {
  kind = 'common',
  exclude_files = common_exclude_files
}

local M = {}

function M.detect_type()
  if vim.fn.filereadable('./Makefile.am') == 1 then
    vim.g.project = {
      kind = 'gnu',
      exclude_files = vim.list_extend(common_exclude_files, { '.ccls-cache', 'Debug', 'Release' })
    }
  elseif vim.fn.filereadable('./CMakeLists.txt') == 1 then
    vim.g.project = {
      kind = 'cmake',
      exclude_files = vim.list_extend(common_exclude_files, { '.ccls-cache', 'Debug', 'Release' })
    }
  elseif vim.fn.filereadable('./Cargo.toml') == 1 then
    vim.g.project = {
      kind = 'rust',
      exclude_files = vim.list_extend(common_exclude_files, { 'target' })
    }
  elseif vim.fn.filereadable('./package.json') == 1 then
    vim.g.project = {
      kind = 'node',
      exclude_files = vim.list_extend(common_exclude_files, {
        'node_modules',
        'coverage',
        'yarn.lock',
        'package.lock',
        'build',
        'yarn-error.log'
      }),
      package_webpage = 'https://www.npmjs.com/package/${package}'
    }
  elseif vim.fn.filereadable('./pyproject.toml') == 1 then
    vim.g.project = {
      kind = 'python',
      exclude_files = vim.list_extend(common_exclude_files, { '.venv', ' __pycache__' })
    }
  end
end

return M
