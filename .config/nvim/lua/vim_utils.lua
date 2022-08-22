local tablex = require 'pl.tablex'
local func = require 'pl.func'

-- local function get_visual_selection()
--   local bufnr = vim.api.nvim_win_get_buf(0)
--   local start = vim.fn.getpos('v') -- [bufnum, lnum, col, off]
--   local _end = vim.fn.getpos('.') -- [bufnum, lnum, col, off]
--   return {
--     bufnr = bufnr,
--     mode = vim.fn.mode(),
--     pos = { start[2], start[3], _end[2], _end[3] }
--   }
-- end

local function buf_append_line(buf_or_line, maybe_line_or_hl_ranges, maybe_hl_ranges)
  local buf, line, hl_ranges
  if type(buf_or_line) == 'number' then
    buf = buf_or_line
    line = maybe_line_or_hl_ranges
    hl_ranges = maybe_hl_ranges
  else
    buf = 0
    line = buf_or_line
    hl_ranges = maybe_line_or_hl_ranges
  end

  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
  if hl_ranges then
    for _, hl in ipairs(hl_ranges) do
      vim.api.nvim_buf_add_highlight(buf, -1, hl.group, -1, hl.from, hl.to)
    end
  end
end

local allowed_key_modes = {
  n = true,
  x = true,
  o = true,
  i = true,
  t = true,
  c = true,
  s = true
}

local function assert_key_mode(mode)
  assert(allowed_key_modes[mode], 'Unexpected key mode:' .. mode)
end

-- modes: 'n', 'nx', 'nxo', etc
-- rhs: vim-command string or lua function
local function map_buf(bufnr, modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  local set_keymap = bufnr and func.bind1(vim.api.nvim_buf_set_keymap, bufnr) or
                       vim.api.nvim_set_keymap
  local setter
  if type(rhs) == 'function' then
    local store_key = 'global'
    if bufnr then
      store_key = 'bufnr_' .. tostring(bufnr)
      if not _U.map[store_key] then
        _U.map[store_key] = {}
      end
    end
    setter = function(mode)
      assert_key_mode(mode)
      if _U.map[store_key][mode] == nil then
        _U.map[store_key][mode] = {}
      end
      _U.map[store_key][mode][lhs] = rhs
      local rhs_str
      if opts.expr then
        rhs_str = string.format('luaeval(\'_U.map[\'\'%s\'\'][\'\'%s\'\'][\'\'%s\'\']()\')',
                                store_key, mode, string.gsub(lhs, '<', '<lt>'))
      else
        rhs_str = string.format('<cmd>lua _U.map[\'%s\'][\'%s\'][\'%s\']()<cr>', store_key, mode,
                                string.gsub(lhs, '<', '<lt>'))
      end
      set_keymap(mode, lhs, rhs_str, opts)
    end
  else
    setter = function(mode)
      assert_key_mode(mode)
      set_keymap(mode, lhs, rhs, opts)
    end
  end

  modes:gsub('.', setter)
end

local map = func.bind1(map_buf, nil)

-- cmd is either string or tuple
-- cmds is either array of string-cmd's and tuple-cmd's or single string-cmd
local function autocmd(group, cmds, opts)
  opts = opts or {}
  opts.clear = opts.clear == nil and true or opts.clear
  if type(cmds) == 'string' then
    cmds = { cmds }
  end
  vim.cmd('augroup ' .. group)
  if clear then
    local maybe_buffer = opts.buffer and ' * <buffer>' or ''
    vim.cmd('au!' .. maybe_buffer)
  end
  local maybe_buffer = opts.buffer and ' <buffer> ' or ''
  for _, cmd in ipairs(cmds) do
    if type(cmd) == 'table' then
      local event_pat = cmd[1]
      local event = vim.split(event_pat, ' ', true)[1]
      local handler = cmd[2]
      if type(handler) == 'function' then
        if _U.augroup[group] == nil then
          _U.augroup[group] = {}
        end
        _U.augroup[group][event] = handler
        handler = string.format('lua _U.augroup[\'%s\'][\'%s\']()', group, event)
      end
      cmd = event_pat .. maybe_buffer .. ' ' .. handler
    end
    vim.cmd('autocmd ' .. cmd)
  end
  vim.cmd [[augroup END]]
end

-- Text with highlights
local Text = {}
Text.__index = Text

-- type hl_range = {group:string, from:number, to:number}
-- type line = {text:string, hl_ranges:hl_range[]}
-- string?, string?
function Text:new(initial_text, maybe_hl)
  local initial_line = {
    text = initial_text or '',
    hl_ranges = {}
  }
  if maybe_hl then
    initial_line.hl_ranges = {
      {
        group = maybe_hl,
        from = 0,
        to = string.len(initial_line.text)
      }
    }
  end
  return setmetatable({
    lines = { initial_line }
  }, self)
end

-- string, string?
function Text:append(text, maybe_hl)
  local last_line = self.lines[#self.lines]
  if maybe_hl then
    local from = #last_line.text
    local to = from + #text
    table.insert(last_line.hl_ranges, {
      group = maybe_hl,
      from = from,
      to = to
    })
  end
  last_line.text = last_line.text .. text
end

function Text:newline()
  table.insert(self.lines, {
    text = '',
    hl_ranges = {}
  })
end

function Text:render_in_float(opts)
  local lines = tablex.imap(function(line)
    return line.text
  end, self.lines)
  local bufnr, winnr = vim.lsp.util.open_floating_preview(lines, 'plaintext', opts)
  for i, line in ipairs(self.lines) do
    for _, hl_range in ipairs(line.hl_ranges) do
      vim.api.nvim_buf_add_highlight(bufnr, -1, hl_range.group, i - 1, hl_range.from, hl_range.to)
    end
  end
  return bufnr, winnr
end

function Text:render_in_buf(bufnr)
  for _, line in ipairs(self.lines) do
    buf_append_line(bufnr, line.text, line.hl_ranges)
  end
end

function Text:render_in_virt_text()
  -- virt_text is expected to have only 1 line
  local line = self.lines[0]
  return vim.tbl_map(function(hl)
    return { string.sub(line.str, hl.from + 1, hl.to), hl.group }
  end, line.hl_ranges)
end

return {
  map_buf = map_buf,
  map = map,
  autocmd = autocmd,
  assert_key_mode = assert_key_mode,
  Text = Text,
  buf_append_line = buf_append_line
}
