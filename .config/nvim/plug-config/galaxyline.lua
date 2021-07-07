local gl = require('galaxyline')
-- get my theme in galaxyline repo
-- local colors = require('galaxyline.theme').default
local colors = {
  bg = '#2E2E2E',
  yellow = '#DCDCAA',
  dark_yellow = '#D7BA7D',
  cyan = '#4EC9B0',
  green = '#608B4E',
  light_green = '#B5CEA8',
  string_orange = '#CE9178',
  orange = '#FF8800',
  purple = '#C586C0',
  magenta = '#D16D9E',
  grey = '#858585',
  blue = '#569CD6',
  vivid_blue = '#4FC1FF',
  light_blue = '#9CDCFE',
  red = '#D16969',
  error_red = '#F44747'
}
local condition = require('galaxyline.condition')
local gls = gl.section
gl.short_line_list = { 'coc-explorer', 'NvimTree', 'vista', 'dbui', 'packer' }

function addLeft(item)
  table.insert(gls.left, item)
end

function addRight(item)
  table.insert(gls.right, item)
end

function addShortLeft(item)
  table.insert(gls.short_line_left, item)
end

function addShortRight(item)
  table.insert(gls.short_line_right, item)
end

addLeft({
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {
        n = colors.blue,
        i = colors.green,
        v = colors.purple,
        ['\22'] = colors.purple,
        V = colors.purple,
        c = colors.magenta,
        no = colors.blue,
        s = colors.orange,
        S = colors.orange,
        ['\19'] = colors.orange,
        ic = colors.yellow,
        R = colors.red,
        Rv = colors.red,
        cv = colors.blue,
        ce = colors.blue,
        r = colors.cyan,
        rm = colors.cyan,
        ['r?'] = colors.cyan,
        ['!'] = colors.blue,
        t = colors.blue
      }
      vim.api
        .nvim_command('hi GalaxyViMode guifg=' .. mode_color[vim.fn.mode()])
      return '▊ '
    end,
    highlight = { colors.red, colors.bg }
  }
})
print(vim.fn.getbufvar(0, 'ts'))
vim.fn.getbufvar(0, 'ts')

addLeft({
  SFileName = {
    provider = 'SFileName',
    condition = condition.buffer_not_empty,
    highlight = { colors.grey, colors.bg }
  }
})

addLeft({
  GitIcon = {
    provider = function()
      return ' '
    end,
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.orange, colors.bg }
  }
})

addLeft({
  GitBranch = {
    provider = 'GitBranch',
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addLeft({
  DiffAdd = {
    provider = 'DiffAdd',
    condition = condition.hide_in_width,
    icon = '  ',
    highlight = { colors.green, colors.bg }
  }
})
addLeft({
  DiffModified = {
    provider = 'DiffModified',
    condition = condition.hide_in_width,
    icon = ' 柳',
    highlight = { colors.blue, colors.bg }
  }
})
addLeft({
  DiffRemove = {
    provider = 'DiffRemove',
    condition = condition.hide_in_width,
    icon = '  ',
    highlight = { colors.red, colors.bg }
  }
})

addRight({
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = { colors.error_red, colors.bg }
  }
})
addRight({
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = { colors.orange, colors.bg }
  }
})

addRight({
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = { colors.blue, colors.bg }
  }
})

addRight({
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = { colors.blue, colors.bg }
  }
})

addRight({
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function()
      local tbl = { ['dashboard'] = true, [' '] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = ' ',
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  LineInfo = {
    provider = 'LineColumn',
    separator = '  ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  PerCent = {
    provider = 'LinePercent',
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  Tabstop = {
    provider = function()
      return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. " "
    end,
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  BufferType = {
    provider = 'FileTypeName',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  FileEncode = {
    provider = 'FileEncode',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addRight({
  Space = {
    provider = function()
      return ' '
    end,
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.orange, colors.bg }
  }
})

addShortLeft({
  BufferType = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = { 'NONE', colors.bg },
    highlight = { colors.grey, colors.bg }
  }
})

addShortLeft({
  SFileName = {
    provider = 'SFileName',
    condition = condition.buffer_not_empty,
    highlight = { colors.grey, colors.bg }
  }
})

addShortRight({
  BufferIcon = { provider = 'BufferIcon', highlight = { colors.grey, colors.bg } }
})
