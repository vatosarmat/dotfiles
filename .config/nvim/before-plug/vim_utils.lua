local allowed_key_modes = {
  n = true,
  x = true,
  o = true,
  i = true,
  t = true,
  c = true
}

local function assert_key_mode(mode)
  assert(allowed_key_modes[mode], 'Unexpected key mode:' .. mode)
end

-- modes: 'n', 'nx', 'nxo', etc
-- rhs: vim-command string or lua function
local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap

  local setter
  if type(rhs) == 'function' then
    setter = function(mode)
      assert_key_mode(mode)
      if _map[mode] == nil then
        _map[mode] = {}
      end
      _map[mode][lhs] = rhs
      local rhs_str = string.format('<cmd>lua _map[\'%s\'][\'%s\']()<cr>', mode,
                                    string.gsub(lhs, '<', '<lt>'))
      vim.api.nvim_set_keymap(mode, lhs, rhs_str, opts)
    end
  else
    setter = function(mode)
      assert_key_mode(mode)
      vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
  end

  -- if type(modes) == 'table' then
  --   print(vim.inspect(debug.getinfo(2)))
  --   print(vim.inspect(debug.getinfo(1)))
  -- end
  -- print(modes)
  modes:gsub(".", setter)
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
        handler = string.format('lua _augroup[\'%s\'][\'%s\']()', group, event)
      end
      cmd = event_pat .. ' ' .. handler
    end
    vim.cmd('autocmd ' .. cmd)
  end
  vim.cmd [[augroup END]]
end

-- mapping: {lhs, rhs}
local function mk_shortmap(name, mappings)
  local shortmap = mappings
  -- for _, mp in ipairs(mappings) do
  --   local lhs, rhs = mp[1], mp[2]
  -- end
  _shortmap[name] = shortmap
end

return {
  map = map,
  mk_sourcer = mk_sourcer,
  autocmd = autocmd,
  assert_key_mode = assert_key_mode
}
