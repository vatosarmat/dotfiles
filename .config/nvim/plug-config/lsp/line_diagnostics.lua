local api = vim.api
local lsp = vim.lsp
local find_if = require'pl.tablex'.find_if
local Text = require'before-plug.vim_utils'.Text
local map_buf = require'before-plug.vim_utils'.map_buf

-- LSP submodules
local cext = require 'plug-config.lsp.client_ext'
local pui = require 'plug-config.lsp.protocol_ui'

local function lookup_client_by_name(name, bufnr)
  local clients = lsp.buf_get_clients(bufnr)
  local idx = find_if(clients, function(client)
    return client.name == name
  end)
  return clients[idx]
end

local function show_line_diagnostics()
  local bufnr = api.nvim_get_current_buf()
  local range_params = lsp.util.make_range_params()
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
    local idx = diag_idx_by_line[api.nvim_win_get_cursor(0)[1]]
    local source = line_diagnostics[idx].source
    local fix_action_selector = cext[source].diagnostic_fix_action_selector
    if fix_action_selector then
      api.nvim_buf_delete(float_bufnr, {})
      local client = lookup_client_by_name(source, bufnr)
      -- There must be a client. If no, let error message
      range_params.context = {
        diagnostics = { line_diagnostics[idx] },
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

lsp.diagnostic.show_line_diagnostics = show_line_diagnostics
