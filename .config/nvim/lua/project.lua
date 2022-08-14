local common_exclude_files = { '.git', '.shada' }
local node_exclude_files = vim.list_extend(vim.deepcopy(common_exclude_files), {
  'node_modules',
  'coverage',
  'yarn.lock',
  'package.lock',
  'build',
  'dist',
  'yarn-error.log'
})

vim.g.project = {
  kind = 'common',
  exclude_files = common_exclude_files,
  package_webpage = 'https://github.com/${package}',
  mate_bufs_exclude = {},
  explorer_width = 30
}

local node_project = {
  kind = 'node',
  exclude_files = node_exclude_files,
  package_webpage = 'https://www.npmjs.com/package/${package}',
  mate_bufs_exclude = {},
  explorer_width = 30
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
      exclude_files = vim.list_extend(common_exclude_files, { 'target' }),
      package_webpage = 'https://docs.rs/${package}'
    }
  elseif vim.fn.filereadable('./package.json') == 1 then
    local project = vim.deepcopy(node_project)
    if vim.fn.filereadable('./angular.json') == 1 then
      project.kind = 'angular'
      vim.list_extend(project.exclude_files, { '.angular' })
      vim.list_extend(project.mate_bufs_exclude,
                      { '.component.spec.ts', '.module.ts', '.component.css', '.component.scss' })
    elseif vim.fn.filereadable('./src/index.tsx') == 1 then
      project.kind = 'react'
      vim.list_extend(project.mate_bufs_exclude, { '.test.tsx', '.module.ts' })
    elseif vim.fn.filereadable('./next.config.js') == 1 or vim.fn.filereadable('./pages/_app.js') ==
      1 then
      project.kind = 'next'
      vim.list_extend(project.exclude_files, { '.next' })
    elseif vim.fn.filereadable('./vite.config.ts') == 1 or vim.fn.filereadable('./src/App.vue') == 1 then
      project.kind = 'vue'
    elseif vim.fn.filereadable('./nest-cli.json') == 1 then
      project.kind = 'nest'
      vim.list_extend(project.exclude_files, { 'test' })
      vim.list_extend(project.mate_bufs_exclude,
                      { '.controller.spec.ts', '.service.spec.ts', '.module.ts' })
    end
    vim.g.project = project
  elseif vim.fn.filereadable('./pyproject.toml') == 1 or vim.fn.filereadable('./pyrightconfig.json') ==
    1 then
    vim.g.project = {
      kind = 'python',
      exclude_files = vim.list_extend(common_exclude_files, { '.venv', '__pycache__' })
    }
  end
end

return M
