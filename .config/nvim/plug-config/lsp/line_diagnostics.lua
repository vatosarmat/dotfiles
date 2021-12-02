local api = vim.api
local lsp = vim.lsp
local Text = require'before-plug.vim_utils'.Text
local map_buf = require'before-plug.vim_utils'.map_buf

-- LSP submodules
local cext = require 'plug-config.lsp.client_ext'
local pui = require 'plug-config.lsp.protocol_ui'

local function diagnostic_highlight(text, line)
  local type_hl_idx = 0
  local pats = {
    {
      [[[tT]ype '[^']+']],
      function()
        local ret = type_hl_idx % 2 == 0 and 'TSType' or 'TSKeyword'
        type_hl_idx = (type_hl_idx + 1) % 2
        return ret
      end
    },
    { [[[sS]ignature '[^']+']], const('TSInclude') },
    { [[[oO]verload %d of %d, '[^']+']], const('TSFunction') }
  }
  local rest = line
  local done = true
  while #rest > 0 do
    local q1, q2 = string.find(rest, [['[^']+']])

    -- found something in quotes
    if q1 then
      local quote_area = string.sub(rest, 0, q2)

      for _, pat in ipairs(pats) do
        local rexp, hl_func = unpack(pat)
        local _, e = string.find(quote_area, rexp)
        -- quote_area is one of interested pats
        if e == q2 then
          text:append(string.sub(rest, 0, q1)) -- prefix
          text:append(string.sub(rest, q1 + 1, q2 - 1), hl_func()) -- type
          text:append('\'')
          rest = string.sub(rest, q2 + 1)
          done = false
          break
        end
      end
    end

    if done then
      text:append(rest)
      return
    end
    done = true
  end
end

local function show_line_diagnostics()
  local bufnr = api.nvim_get_current_buf()
  local line_nr = api.nvim_win_get_cursor(0)[1] - 1
  local opts = {}
  local diag_idx_by_line = {}

  local line_diagnostics = lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts)
  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  local text = Text:new()
  -- local diag_idx_by_text = {}
  for diag_idx, diagnostic in ipairs(line_diagnostics) do
    local name = '?'
    local code = diagnostic.code or diagnostic.severity
    if diagnostic.source then
      name = cext[diagnostic.source].short_name or diagnostic.source
    end
    local hiname = pui.severities[diagnostic.severity].hl_float
    assert(hiname, 'unknown severity: ' .. tostring(diagnostic.severity))
    text:append(name .. '_' .. code .. ': ', hiname)
    local lines = vim.fn.split(diagnostic.message, '\n', true)
    for _, line in ipairs(lines) do
      if name == 'TS' then
        diagnostic_highlight(text, line)
      else
        text:append(line)
      end
      text:newline()
      table.insert(diag_idx_by_line, diag_idx)
    end
  end

  opts.focus_id = 'line_diagnostics'
  opts.max_width = math.floor(vim.fn.winwidth(0) * 0.8)
  local float_bufnr, float_winnr = text:render_in_float(opts)

  local function disable()
    -- Current window is diagnostic float
    local idx = diag_idx_by_line[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local dl_pattern = cext[source].diagnostic_disable_line
    if dl_pattern then
      api.nvim_buf_delete(float_bufnr, {})
      local line = api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
      print(vim.inspect(line))
      local indent_spaces = string.sub(line, string.find(line, '%s*'))
      local dl = indent_spaces .. string.gsub(dl_pattern, '%${code}', line_diagnostics[idx].code)
      api.nvim_buf_set_lines(bufnr, line_nr, line_nr, false, { dl })
      vim.cmd('write ' .. tostring(vim.fn.bufname(bufnr)))
    end
  end

  local function webpage()
    local idx = diag_idx_by_line[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local diagnostic_webpage = cext[source].diagnostic_webpage
    if diagnostic_webpage then
      local uri = type(diagnostic_webpage) == 'string' and
                    string.gsub(diagnostic_webpage, '%${code}', line_diagnostics[idx].code) or
                    diagnostic_webpage(line_diagnostics[idx])
      os.execute('$BROWSER ' .. uri)
    end
  end

  local function apply_fix()

  end

  map_buf(float_bufnr, 'n', 'd', disable, {
    silent = true,
    nowait = true
  })
  map_buf(float_bufnr, 'n', 'p', webpage, {
    silent = true,
    nowait = true
  })
  map_buf(float_bufnr, 'n', 'a', apply_fix, {
    silent = true,
    nowait = true
  })

  return float_bufnr, float_winnr
end

lsp.diagnostic.show_line_diagnostics = show_line_diagnostics
