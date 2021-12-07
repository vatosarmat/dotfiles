local api = vim.api
local lsp = vim.lsp
local find_if = require'pl.tablex'.find_if
local reduce = require'pl.tablex'.reduce
local Text = require'before-plug.vim_utils'.Text
local map_buf = require'before-plug.vim_utils'.map_buf

-- LSP submodules
local cext = require 'plug-config.lsp.client_ext'
local pui = require 'plug-config.lsp.protocol_ui'

--
-- Utils
--
local function get_bufnr(bufnr)
  if not bufnr or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return bufnr
end

local function get_source(diagnostic)
  return cext[diagnostic.source].short_name or diagnostic.source or '?'
end

local function get_code(diagnostic)
  local u = diagnostic.user_data
  if u then
    local l = u.lsp
    if l and l.code then
      return l.code
    end
  end
  return pui.severities[diagnostic.severity].name
end

local function lookup_client_by_name(name, bufnr)
  local clients = lsp.buf_get_clients(bufnr)
  local idx = find_if(clients, function(client)
    return client.name == name
  end)
  return clients[idx]
end

local function severity_vim_to_lsp(severity)
  if type(severity) == 'string' then
    severity = vim.diagnostic.severity[severity]
  end
  return severity
end

local function diagnostic_vim_to_lsp(d)
  return vim.tbl_extend('error', {
    range = {
      start = {
        line = d.lnum,
        character = d.col
      },
      ['end'] = {
        line = d.end_lnum,
        character = d.end_col
      }
    },
    severity = severity_vim_to_lsp(d.severity),
    message = d.message,
    source = d.source
  }, d.user_data and (d.user_data.lsp or {}) or {})
end

--
-- Diagnostics float
--
local function show_line_diagnostics()
  local bufnr = api.nvim_get_current_buf()
  local range_params = lsp.util.make_range_params()
  local line_nr = api.nvim_win_get_cursor(0)[1] - 1
  local opts = {}
  local diag_idx_by_line = {}

  local line_diagnostics = vim.diagnostic.get(bufnr, {
    lnum = line_nr
  })
  if vim.tbl_isempty(line_diagnostics) then
    return
  end

  local text = Text:new()
  -- local diag_idx_by_text = {}
  for diag_idx, diagnostic in ipairs(line_diagnostics) do
    local name = get_source(diagnostic)
    local code = get_code(diagnostic)
    local hiname = pui.severities[diagnostic.severity].hl_float
    assert(hiname, 'unknown severity: ' .. tostring(diagnostic.severity))
    text:append(name .. '_' .. code .. ': ', hiname)
    local lines = vim.fn.split(diagnostic.message, '\n', true)
    for _, line in ipairs(lines) do
      local hl = cext[diagnostic.source].diagnostic_highlight
      if hl then
        hl(text, line)
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
    -- idx is determined by line under cursor when key pressed
    local idx = diag_idx_by_line[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local dl_pattern = cext[source].diagnostic_disable_line
    if dl_pattern then
      api.nvim_buf_delete(float_bufnr, {})
      local line = api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1]
      print(vim.inspect(line))
      local indent_spaces = string.sub(line, string.find(line, '%s*'))
      local dl = indent_spaces ..
                   string.gsub(dl_pattern, '%${code}', get_code(line_diagnostics[idx]))
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
                    string.gsub(diagnostic_webpage, '%${code}', get_code(line_diagnostics[idx])) or
                    diagnostic_webpage(line_diagnostics[idx])
      os.execute('$BROWSER ' .. uri)
    end
  end

  local function apply_fix()
    local idx = diag_idx_by_line[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local fix_action_selector = cext[source].diagnostic_fix_action_selector
    if fix_action_selector then
      api.nvim_buf_delete(float_bufnr, {})
      local client = lookup_client_by_name(source, bufnr)
      -- There must be a client. If no, let error message
      range_params.context = {
        diagnostics = { diagnostic_vim_to_lsp(line_diagnostics[idx]) },
        only = { 'quickfix' }
      }
      ---@diagnostic disable-next-line: unused-local
      client.request('textDocument/codeAction', range_params, function(err, result, ctx, config)
        -- save/write buffer after applying fix
        local default_apply_edit_handler = lsp.handlers['workspace/applyEdit']
        local with_write = function(...)
          local ret = default_apply_edit_handler(...)
          vim.cmd('write ' .. tostring(vim.fn.bufname(bufnr)))
          lsp.handlers['workspace/applyEdit'] = default_apply_edit_handler
          return ret
        end
        lsp.handlers['workspace/applyEdit'] = with_write

        local action_chosen = fix_action_selector(result)
        -- textDocument/codeAction can return either Command[] or CodeAction[].
        -- If it is a CodeAction, it can have either an edit, a command or both.
        -- Edits should be executed first
        if action_chosen.edit or type(action_chosen.command) == 'table' then
          if action_chosen.edit then
            lsp.util.apply_workspace_edit(action_chosen.edit)
          end
          if type(action_chosen.command) == 'table' then
            client.request('workspace/executeCommand', action_chosen.command)
          end
        else
          client.request('workspace/executeCommand', action_chosen)
        end
      end, bufnr)
    end
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

--
-- Virtual text
--

local function diagnostic_format(d)
  local format = cext[d.source].diagnostic_virtual_text
  if format then
    return format(d)
  else
    return string.format('%s:%s', get_source(d), get_code(d))
  end
end

---@diagnostic disable-next-line: unused-local
vim.diagnostic.handlers.virtual_text.show = function(namespace, bufnr, diagnostics, opts)
  bufnr = get_bufnr(bufnr)

  local ns = vim.diagnostic.get_namespace(namespace)
  if not ns.user_data.virt_text_ns then
    ns.user_data.virt_text_ns = vim.api.nvim_create_namespace('')
  end
  local virt_text_ns = ns.user_data.virt_text_ns

  local virt_text_per_line = reduce(function(ret, diagnostic)
    local lnum = diagnostic.lnum
    -- print(vim.inspect(diagnostic))
    -- print(vim.inspect(ret))
    local str = diagnostic_format(diagnostic)
    if str then
      local chunk = { str .. ' ', pui.severities[diagnostic.severity].hl_virt }
      if not ret[lnum] then
        ret[lnum] = { chunk }
      else
        -- Comma separated diagnostic list
        -- table.insert(ret[lnum], { ' ', 'Normal' })
        table.insert(ret[lnum], chunk)
      end
    end
    return ret
  end, diagnostics, {})

  for line, virt_text in pairs(virt_text_per_line) do
    vim.api.nvim_buf_set_extmark(bufnr, virt_text_ns, line, 0, {
      hl_mode = 'combine',
      virt_text = virt_text,
      virt_text_pos = 'right_align',
      virt_text_hide = true
    })
  end
  vim.diagnostic.save_extmarks(virt_text_ns, bufnr)
end

vim.diagnostic.config({
  virtual_text = function(_, _)
    return vim.g.uopts.ldv == 1
  end,
  underline = function(_, _)
    return vim.g.uopts.ldu == 1 and {
      -- severity_limit = 'Error'
    } or false
  end,
  signs = true,
  update_in_insert = false,
  severity_sort = true
})

vim.diagnostic.open_float = show_line_diagnostics
