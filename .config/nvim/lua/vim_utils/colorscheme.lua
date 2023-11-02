local nvim_set_hl = vim.api.nvim_set_hl

local M = {}

-- Terms:
--  colorscheme - ending result
--  highlight table - M.set_hl argument, contains all the hl definitions
--  highlight subtable - M.expand/fg/bg argument, contains subset of the hl definitions

--- @alias HighlightInfo table<'fg'|'bg'|'italc'|'bold', string>
--- @alias Highlight string | ColorTable

--- @param key 'fg'|'bg'
--- @param hl_subtable table<string,Highlight>
--- @param group_prefix? string
--- @param other_key_value? string
--- @param referenced_subtable? string
function M.expand(key, hl_subtable, group_prefix, other_key_value)
  -- usually we need only fg or only bg
  -- so, kinds of tables: #-string treated as fg color, or #-string treated as bg color
  -- non-#-string is always treated as links
  -- & is ref, it needed for subtable to reference itself
  -- ref in HighlightInfo value references one of the previous hl_subtable elements and takes its value
  -- ref as hl_subtable element re-runs iteration with one of the previous hl_subtable elements

  local PATH_SEPARATOR = '/'
  local ret = {}
  local other_key = key == 'fg' and 'bg' or 'fg'

  --- @param group string
  --- @param highlight Highlight
  local function iteration(group, highlight)
    local orig_group = group
    group = (group_prefix or '') .. group
    ilog(group, highlight)
    if type(highlight) == 'table' then
      -- color is a HighlightInfo
      ret[group] = vim.deepcopy(highlight)
      for _, bfg in ipairs { 'fg', 'bg' } do
        if highlight[bfg] then
          if vim.startswith(highlight[bfg], '&') then
            -- HighlightInfo value is ref
            local ref = string.sub(highlight[bfg], 2)
            ret[group][bfg] = vim.tbl_get(
              hl_subtable,
              unpack(vim.split(ref, PATH_SEPARATOR, {
                plain = true,
              }))
            )
          else
            -- HighlightInfo value is value
            ret[group][bfg] = highlight[bfg]
          end
        end
      end
    elseif vim.startswith(highlight, '#') then
      -- highlight is a color value
      ret[group] = {
        [key] = highlight,
        [other_key] = other_key_value,
      }
    elseif vim.startswith(highlight, '&') then
      -- highlight is a ref
      local ref = string.sub(highlight, 2)
      iteration(
        orig_group,
        vim.tbl_get(
          hl_subtable,
          unpack(vim.split(ref, PATH_SEPARATOR, {
            plain = true,
          }))
        )
      )
    else
      -- highlight is HL group name
      ret[group] = {
        link = highlight,
      }
    end
  end

  for group, highlight in pairs(hl_subtable) do
    iteration(group, highlight)
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
  vim.cmd 'hi clear'

  vim.o.background = 'dark'
  if vim.fn.exists 'syntax_on' then
    vim.cmd 'syntax off'
    vim.cmd 'syntax on'
  end

  vim.o.termguicolors = true
  vim.g.colors_name = name
end

function M.set_hl(highlight_table)
  for group, hl in pairs(highlight_table) do
    -- ilog(group, hl)
    nvim_set_hl(0, group, hl)
  end
end

return M
