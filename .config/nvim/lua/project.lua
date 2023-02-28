local utils = require 'utils'

--[[

kind
marker
exclude_files
package_webpage
exclude_mate_bufs
explorer_width
subkinds

--]]

local generic_exclude_files = { '.git', '.shada', '.staging' }
local node_exclude_files = vim.list_extend(vim.deepcopy(generic_exclude_files), {
  'node_modules',
  'coverage',
  'yarn.lock',
  'package.lock',
  'build',
  'dist',
  'yarn-error.log'
})

local project_kind_node = {
  kind = 'node',
  marker = 'package.json',
  exclude_files = node_exclude_files,
  package_webpage = 'https://www.npmjs.com/package/${package}',
  exclude_mate_bufs = {},
  explorer_width = 30,
  subkinds = {
    {
      kind = 'angular',
      marker = 'angular.json',
      exclude_files = { '.angular' },
      exclude_mate_bufs = { '.component.spec.ts', '.module.ts', '.component.css', '.component.scss' }
    },
    {
      kind = 'react',
      marker = 'src/index.tsx',
      exclude_files = { '.test.tsx', '.module.ts' }
    },
    {
      kind = 'next',
      marker = { 'next.config.js', 'pages/_app.js' },
      exclude_files = { '.next' }
    },
    {
      kind = 'vue',
      marker = { 'vue.config.ts', 'src/App.vue', 'vite.config.ts' }
    },
    {
      kind = 'nest',
      marker = 'nest-cli.json',
      exclude_files = { 'test' },
      exclude_mate_bufs = { '.controller.spec.ts', '.service.spec.ts', '.module.ts' }
    }
  }
}

local project_kind_generic = {
  kind = 'generic',
  exclude_files = generic_exclude_files,
  package_webpage = 'https://github.com/${package}',
  exclude_mate_bufs = {},
  explorer_width = 30,
  subkinds = {
    {
      kind = 'gnu',
      marker = 'Makefile.am',
      exclude_files = { '.ccls-cache', 'Debug', 'Release' }
    },
    {
      kind = 'cmake',
      marker = 'CMakeLists.txt',
      exclude_files = { '.ccls-cache', 'Debug', 'Release' }
    },
    {
      kind = 'rust',
      marker = 'Cargo.toml',
      exclude_files = { 'target' },
      package_webpage = 'https://docs.rs/${package}'
    },
    {
      kind = 'python',
      marker = { 'pyrightconfig.json', 'pyproject.toml' },
      exclude_files = { '.venv', '__pycache__', 'build' }
    },
    {
      kind = 'php',
      marker = { 'composer.json' },
      exclude_files = { 'vendor' },
      make_info = function()
        return {
          has_local_pint = vim.fn.filereadable('./vendor/bin/pint') == 1
        }
      end
    }
  }
}

local PROJECT_KEYS = { 'package_webpage', 'explorer_width', 'exclude_files', 'exclude_mate_bufs' }

local M = {}

local function is_marker_present(kind)
  if type(kind.marker) == 'string' then
    return vim.fn.filereadable(kind.marker) == 1
  end

  for _, file in ipairs(kind.marker) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end

  return false
end

function M.detect_type()
  local prototype, kind

  if vim.fn.filereadable(project_kind_node.marker) == 1 then
    prototype = project_kind_node
    kind = 'node'
  else
    prototype = project_kind_generic
  end
  local project = utils.pick(prototype, PROJECT_KEYS)
  project.kind = kind

  for _, subkind in ipairs(prototype.subkinds) do
    if is_marker_present(subkind) then
      utils.extend_keys(project, subkind, PROJECT_KEYS)
      if subkind.make_info then
        project.info = subkind.make_info()
      end
      project.kind = (kind and kind .. ',' or '') .. subkind.kind
      break
    end
  end

  local spellfiles = { '.spell_local.utf-8.add' }
  if project.kind then
    -- project.kind is comma-separated list
    local kinds = vim.split(project.kind, ',')
    spellfiles = vim.list_extend(vim.tbl_map(function(item)
      return ('%s/spell/%s.utf-8.add'):format(vim.fn.stdpath('config'), item)
    end, kinds), spellfiles)
  else
    project.kind = 'generic'
  end

  vim.g.project = project
  vim.opt.spellfile:append(spellfiles)
end

return M
