local utils = require 'utils'
local pu = require 'project.utils'

-- @class MateBufs
-- @field get fun(current_buf_path: string): string[]
-- @field default_skip? string[] | fun(buf_path: string): boolean

-- @class Project
-- @field name string | string[]
-- @field marker string | string[] | fun(): boolean
-- @field exclude_files? string[]
-- @field package_webpage? string
-- @files mate_bufs? MateBufs
-- @field specific? any
-- @field subtypes? Project[]

-- @type Project
local GENERIC_PROJECT = {
  name = 'generic',
  package_webpage = 'https://github.com/${package}',
  exclude_files = { '.git', '.shada' },
  mate_bufs = {
    get = pu.mates_same_basepath,
  },
}

-- @type Project[]
local PROJECT_TYPES = {
  { name = 'dotfiles', marker = 'bashrc.bash' },
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
    specific = require('project.node').configure(),
    subtypes = {
      {
        name = 'angular',
        marker = function()
          return pu.json_with_key_readable('package.json', 'dependencies', 'angular')
        end,
        exclude_files = { '.angular' },
        mate_bufs = {
          default_skip = {
            '.component.spec.ts',
            '.module.ts',
            '.component.css',
            '.component.scss',
          },
        },
      },
      {
        -- detect by package name in package.json
        name = 'react',
        marker = function()
          return pu.json_with_key_readable('package.json', 'dependencies', 'react')
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
        mate_bufs = {
          default_skip = { '.controller.spec.ts', '.service.spec.ts', '.module.ts' },
        },
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
    specific = require('project.php').configure(),
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

local function apply_project_subtype(project, subtype)
  -- override package_webpage
  if subtype.package_webpage then
    project.package_webpage = subtype.package_webpage
  end

  -- append exclude_files
  if subtype.exclude_files then
    vim.list_extend(project.exclude_files, subtype.exclude_files)
  end

  if subtype.mate_bufs then
    -- override mate_bufs.get method
    if subtype.mate_bufs.get then
      project.mate_bufs.get = subtype.mate_bufs.get
    end

    -- override mate_bufs.default_skip methods/tables
    if subtype.mate_bufs.default_skip then
      -- merge lists, compose functions
      project.mate_bufs.default_skip = subtype.mate_bufs.default_skip
    end
  end

  -- set project-type-specific stuff
  if subtype.specific then
    if type(subtype.specific) == 'function' then
      project.specific = subtype.specific(project.specific)
    else
      project.specific = vim.tbl_extend('force', project.specific or {}, subtype.specific)
    end
  end
end

local function infer_project_type(result_type, subtype_list)
  if type(result_type.name) == 'string' then
    result_type.name = { result_type.name }
  end

  for _, subtype in ipairs(subtype_list) do
    if is_marker_present(subtype) then
      -- append name
      table.insert(result_type.name, subtype.name)

      apply_project_subtype(result_type, subtype)

      if subtype.subtypes then
        result_type = infer_project_type(result_type, subtype.subtypes)
      end

      break
    end
  end

  return result_type
end

local function configure_spell(project_type_inferred)
  local spellfiles
  if project_type_inferred.name[1] == 'generic' then
    spellfiles = {}
  else
    spellfiles = vim.tbl_map(function(name_item)
      return ('%s/spell/%s.utf-8.add'):format(vim.fn.stdpath 'config', name_item)
    end, project_type_inferred.name)
  end
  table.insert(spellfiles, '.spell.utf-8.add')

  return spellfiles
end

local M = {}

function M.configure()
  local project_type_inferred = infer_project_type(GENERIC_PROJECT, PROJECT_TYPES)

  local status, project_local = pcall(require, 'project_local')
  if status then
    apply_project_subtype(project_type_inferred, project_local.read_config())
  end

  if #project_type_inferred.name > 1 then
    -- remove 'generic'
    table.remove(project_type_inferred.name, 1)
  end

  vim.g.project = project_type_inferred
  vim.opt.spellfile:append(configure_spell(project_type_inferred))
end

return M
