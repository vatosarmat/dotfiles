local utils = require 'utils'

--[[
name
marker            - string, {a or b}, predicate function 
exclude_files
package_webpage
exclude_mate_bufs
subtypes
--]]

local PROJECT_TYPES = {
  {
    name = 'node',
    marker = 'package.json',
    exclude_files = {
      'node_modules',
      'coverage',
      'yarn.lock',
      'package-lock.json',
      'build',
      'dist',
      'yarn-error.log',
      '.yarn'
    },
    package_webpage = 'https://www.npmjs.com/package/${package}',
    exclude_mate_bufs = {},
    subtypes = {
      {
        name = 'angular',
        marker = 'angular.json',
        exclude_files = { '.angular' },
        exclude_mate_bufs = {
          '.component.spec.ts',
          '.module.ts',
          '.component.css',
          '.component.scss'
        }
      },
      {
        -- detect by package name in package.json
        name = 'react',
        marker = 'src/index.tsx',
        exclude_files = { '.test.tsx', '.module.ts' }
      },
      {
        name = 'next',
        marker = { 'next.config.js', 'pages/_app.js' },
        exclude_files = { '.next' }
      },
      {
        name = 'vue',
        marker = { 'vue.config.ts', 'src/App.vue', 'vite.config.ts' }
      },
      {
        name = 'nest',
        marker = 'nest-cli.json',
        exclude_files = { 'test' },
        exclude_mate_bufs = { '.controller.spec.ts', '.service.spec.ts', '.module.ts' }
      }
    }
  },
  {
    name = 'gnu',
    marker = 'Makefile.am',
    exclude_files = { '.ccls-cache', 'Debug', 'Release' }
  },
  {
    name = 'cmake',
    marker = 'CMakeLists.txt',
    exclude_files = { '.ccls-cache', 'Debug', 'Release' }
  },
  {
    name = 'rust',
    marker = 'Cargo.toml',
    exclude_files = { 'target' },
    package_webpage = 'https://docs.rs/${package}'
  },
  {
    name = 'python',
    marker = { 'pyrightconfig.json', 'pyproject.toml' },
    exclude_files = { '.venv', '__pycache__', 'build' }
  },
  {
    name = 'php',
    marker = { 'composer.json' },
    exclude_files = {
      'vendor',
      'runtime/debug',
      'runtime/logs',
      'web/assets',
      'composer.lock',
      'composer.phar'
    },
    subtypes = {
      {
        name = 'yii',
        marker = 'yii',
        exclude_files = {}
      }
    }
  }
}

local function is_marker_present(project_type)
  if type(project_type.marker) == 'string' then
    return vim.fn.filereadable(project_type.marker) == 1
  end

  for _, file in ipairs(project_type.marker) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end

  return false
end

local function infer_project_type(type_list, result_type)
  for _, type_item in ipairs(type_list) do
    if is_marker_present(type_item) then

      -- append name
      table.insert(result_type.name, type_item.name)

      -- override package_webpage
      if type_item.package_webpage then
        result_type.package_webpage = type_item.package_webpage
      end

      -- append exclude_files
      if type_item.exclude_files then
        vim.list_extend(result_type.exclude_files, type_item.exclude_files)
      end

      -- override exclude_mate_bufs 
      if type_item.exclude_mate_bufs then
        result_type.exclude_mate_bufs = type_item.exclude_mate_bufs
      end

      if type_item.subtypes then
        infer_project_type(type_item.subtypes, result_type)
      end
    end
  end
end

local M = {}

function M.configure()

  local project_type_inferred = {
    name = {},
    exclude_files = { '.git', '.shada', '.staging' }
  }
  infer_project_type(PROJECT_TYPES, project_type_inferred)

  if project_type_inferred.package_webpage == nil then
    project_type_inferred.package_webpage = 'https://github.com/${package}'
  end

  local spellfiles
  if #project_type_inferred.name == 0 then
    table.insert(project_type_inferred.name, 'generic')
    spellfiles = {}
  else
    spellfiles = vim.tbl_map(function(name_item)
      return ('%s/spell/%s.utf-8.add'):format(vim.fn.stdpath('config'), name_item)
    end, project_type_inferred.name)
  end
  table.insert(spellfiles, '.spell.utf-8.add')

  vim.g.project = project_type_inferred
  vim.opt.spellfile:append(spellfiles)
end

return M
