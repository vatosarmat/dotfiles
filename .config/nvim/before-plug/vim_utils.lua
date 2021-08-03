local map_key = vim.api.nvim_set_keymap

-- noremap by default, multiple modes
-- rhs: vim-command string or lua function
local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == 'string' then
    modes = { modes }
  end
  if type(rhs) == 'function' then
    for _, mode in ipairs(modes) do
      if _map[mode] == nil then
        _map[mode] = {}
      end
      _map[mode][lhs] = rhs
      local rhs_str = string.format('lua _map.%s.%s()', mode, lhs)
      map_key(mode, lhs, rhs_str, opts)
    end
  else
    for _, mode in ipairs(modes) do
      map_key(mode, lhs, rhs, opts)
    end
  end
end

local function map_cmd(modes, lhs, rhs, opts)
  return map(modes, lhs, '<cmd>lua ' .. rhs .. '<cr>', opts)
end

local function mk_sourcer(path)
  if vim.endswith(path, '.vim') then
    return string.format('vim.cmd(\'source %s\')', path)
  else
    return string.format('require \'%s\'', path)
  end
end

-- cmd is either string or tuple
-- cmds is either array of string-cmd's and tuple-cmd's or single string-cmd
local function autocmd(group, cmds, clear)
  clear = clear == nil and true or clear
  if type(cmds) == 'string' then
    cmds = { cmds }
  end
  vim.cmd('augroup ' .. group)
  if clear then
    vim.cmd [[au!]]
  end
  for _, cmd in ipairs(cmds) do
    if type(cmd) == 'table' then
      local event_pat = cmd[1]
      local event = vim.split(event_pat, ' ', true)[1]
      local handler = cmd[2]
      if type(handler) == 'function' then
        if _augroup[group] == nil then
          _augroup[group] = {}
        end
        _augroup[group][event] = handler
        handler = string.format('lua _augroup.%s.%s()', group, event)
      end
      cmd = event_pat .. ' ' .. handler
    end
    vim.cmd('autocmd ' .. cmd)
  end
  vim.cmd [[augroup END]]
end

return { map = map, mk_sourcer = mk_sourcer, autocmd = autocmd }
