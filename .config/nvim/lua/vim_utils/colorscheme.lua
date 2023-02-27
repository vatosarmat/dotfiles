local nvim_set_hl = vim.api.nvim_set_hl

local M = {}

function M.expand(key, color_table, group_prefix, other_key_value)
  -- usually we need only fg or only bg
  -- so, kinds of tables: #-string treated as fg, or #-string treated as bg
  -- non-#-string is always treated as links
  -- & is ref

  local PATH_SEPARATOR = '/'
  local ret = {}
  local other_key = key == 'fg' and 'bg' or 'fg'

  local function iteration(group, color)
    local orig_group = group
    group = (group_prefix or '') .. group
    if type(color) == 'table' then
      ret[group] = vim.deepcopy(color)
      for _, bfg in ipairs { 'fg', 'bg' } do
        if color[bfg] then
          if vim.startswith(color[bfg], '&') then
            local ref = string.sub(color[bfg], 2)
            ret[group][bfg] = vim.tbl_get(color_table, unpack(
                                            vim.split(ref, PATH_SEPARATOR, {
                plain = true
              })))
          else
            ret[group][bfg] = color[bfg]
          end
        end
      end
    elseif vim.startswith(color, '#') then
      ret[group] = {
        [key] = color,
        [other_key] = other_key_value
      }
    elseif vim.startswith(color, '&') then
      local ref = string.sub(color, 2)
      iteration(orig_group, vim.tbl_get(color_table, unpack(
                                          vim.split(ref, PATH_SEPARATOR, {
          plain = true
        }))))
    else
      ret[group] = {
        link = color
      }
    end
  end

  for group, color in pairs(color_table) do
    iteration(group, color)
  end

  return ret
end

function M.fg(color_table, prefix, bg_value)
  return M.expand('fg', color_table, prefix, bg_value)
end

function M.bg(color_table, prefix, fg_value)
  return M.expand('bg', color_table, prefix, fg_value)
end

function M.validate(colorscheme)
  local bad_group = nil
  for group, hl in pairs(colorscheme) do
    if not type(hl) == 'table' then
      -- not a table
      bad_group = group
      break
    end
    for _, bfg in ipairs { 'fg', 'bg' } do
      if hl[bfg] and not vim.startswith(hl[bfg], '#') then
        -- invalid fg or bg
        bad_group = group
        break
      end
    end
  end
  if bad_group then
    vim.pretty_print(bad_group, colorscheme[bad_group])
  end
end

function M.boilerplate(name)
  vim.cmd('hi clear')

  vim.o.background = 'dark'
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax off')
    vim.cmd('syntax on')
  end

  vim.o.termguicolors = true
  vim.g.colors_name = name
end

function M.set_hl(cs)
  for group, hl in pairs(cs) do
    nvim_set_hl(0, group, hl)
  end
end

return M
