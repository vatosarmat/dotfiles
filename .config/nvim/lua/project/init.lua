local utils = require 'utils'

--[[
name
marker            - string, {a or b}, predicate function 
exclude_files
package_webpage
exclude_mate_bufs
[name]            - project-specific stuff
subtypes
--]]

local PROJECT_TYPES = {
  { name = 'dotfiles', marker = { '.config/nvim/init.vim', '.config/nvim/init.lua' } },
  {
    name = 'node',
    marker = { 'package.json', 'manifest.json' },
    exclude_files = {
      'node_modules',
      'coverage',
      'yarn.lock',
      'package-lock.json',
      'build',
      'dist',
      'yarn-error.log',
      '.yarn',
      'log',
    },
    package_webpage = 'https://www.npmjs.com/package/${package}',
    exclude_mate_bufs = {},
    node = require('project.node').configure(),
    subtypes = {
      {
        name = 'angular',
        marker = function()
          if vim.fn.filereadable 'package.json' == 1 then
            local text = table.concat(vim.fn.readfile 'package.json', '\n')
            local table = vim.json.decode(text)
            return vim.tbl_get(table, 'dependencies', 'angular')
          end
          return false
        end,
        exclude_files = { '.angular' },
        exclude_mate_bufs = {
          '.component.spec.ts',
          '.module.ts',
          '.component.css',
          '.component.scss',
        },
      },
      {
        -- detect by package name in package.json
        name = 'react',
        marker = function()
          if vim.fn.filereadable 'package.json' == 1 then
            local text = table.concat(vim.fn.readfile 'package.json', '\n')
            local table = vim.json.decode(text)
            return vim.tbl_get(table, 'dependencies', 'react')
          end
          return false
        end,
        exclude_files = { '.test.tsx', '.module.ts' },
      },
      {
        name = 'next',
        marker = { 'next.config.js', 'pages/_app.js' },
        exclude_files = { '.next' },
      },
      {
        name = 'vue',
        marker = { 'vue.config.ts', 'src/App.vue' },
      },
      {
        name = 'nest',
        marker = 'nest-cli.json',
        exclude_files = { 'test' },
        exclude_mate_bufs = { '.controller.spec.ts', '.service.spec.ts', '.module.ts' },
      },
    },
  },
  {
    name = 'gnu',
    marker = 'Makefile.am',
    exclude_files = { '.ccls-cache', 'Debug', 'Release' },
  },
  {
    name = 'cmake',
    marker = 'CMakeLists.txt',
    exclude_files = { '.ccls-cache', 'Debug', 'Release', 'build' },
  },
  {
    name = 'rust',
    marker = 'Cargo.toml',
    exclude_files = { 'target' },
    package_webpage = 'https://docs.rs/${package}',
  },
  {
    name = 'python',
    marker = { 'pyrightconfig.json', 'pyproject.toml' },
    exclude_files = { '.venv', '__pycache__', 'build' },
  },
  {
    name = 'php',
    marker = { 'composer.json', 'index.php' },
    exclude_files = {
      'vendor',
      'runtime/debug',
      'runtime/logs',
      'web/assets',
      'composer.lock',
      'composer.phar',
    },
    php = require('project.php').configure(),
    subtypes = {
      {
        name = 'yii',
        marker = 'yii',
        exclude_files = {},
      },
      {
        name = 'laravel',
        marker = 'artisan',
        exclude_files = {
          'storage/framework',
          'storage/logs',
          'bootstrap/cache',
          'database/migrations',
          '.phpstorm.meta.php',
          '_ide_helper.php',
          'public',
        },
      },
      { name = 'bitrix', marker = 'bitrix/bitrix.php', exclude_files = { 'bitrix', 'upload' } },
    },
  },
}

local function is_marker_present(project_type)
  local markers = vim.tbl_flatten { project_type.marker }
  ilog('', markers)

  for _, marker in ipairs(markers) do
    local marker_type = type(marker)

    if marker_type == 'function' then
      return marker()
    elseif marker_type == 'string' then
      if vim.fn.filereadable(marker) == 1 then
        return true
      end
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

      -- set project-type-specific stuff
      if type_item[type_item.name] then
        result_type[type_item.name] = type_item[type_item.name]
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
    exclude_files = { '.git', '.shada', '.staging', '.github', 'tests' },
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
      return ('%s/spell/%s.utf-8.add'):format(vim.fn.stdpath 'config', name_item)
    end, project_type_inferred.name)
  end
  table.insert(spellfiles, '.spell.utf-8.add')

  vim.g.project = project_type_inferred
  vim.opt.spellfile:append(spellfiles)
end

return M
