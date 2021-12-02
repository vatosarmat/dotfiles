local api = vim.api
local lsp = vim.lsp
local lint = require 'lint'
local pui = require 'plug-config.lsp.protocol_ui'
local cext = require 'plug-config.lsp.client_ext'

local separator = {
  clients = '][',
  diagnostics = ' ',
  progress = '|'
}

local function get_linters()
  local ft = api.nvim_buf_get_option(0, 'filetype')
  return lint.linters_by_ft[ft] or {}
end

local function diagnostic_lines(client_id)
  local diagnostics = {}
  for i, sev in ipairs(pui.severities) do
    local sev_count = lsp.diagnostic.get_count(0, sev.name, client_id)
    if sev_count > 0 then
      table.insert(diagnostics, '%' .. i .. '*' .. sev.sign .. ' %*' .. sev_count)
    end
  end

  return diagnostics
end

local function status_line()
  local clients = lsp.buf_get_clients(0)
  local client_strings = {}
  for _, client in pairs(clients) do
    local diagnostics = diagnostic_lines(client.id)

    local progress = {}
    for token, item in pairs(client.messages.progress) do
      if not item or item.done then
        client.messages.progress[token] = nil
      else
        local title = item.title and item.title or ''
        local message = item.message and '(' .. item.message .. ')' or ''
        local percentage = item.percentabe and item.percentage .. '%%' or ''
        table.insert(progress, title .. message .. '...' .. percentage)
      end
    end

    local client_str = cext[client.name].short_name or client.name

    -- If at least one present, separate it from the client name
    if next(diagnostics) or next(progress) then
      client_str = client_str .. ':' .. table.concat(diagnostics, separator.diagnostics)
    end
    if next(diagnostics) and next(progress) then
      -- If both present, separate them
      client_str = client_str .. '|'
    end
    client_str = client_str .. table.concat(progress, separator.progress)
    table.insert(client_strings, client_str)
  end

  local linters = get_linters()
  for i, name in ipairs(linters) do
    local diagnostics = diagnostic_lines(1000 + i)
    local linter_str = cext[name].short_name or name

    if next(diagnostics) then
      linter_str = linter_str .. ':' .. table.concat(diagnostics, separator.diagnostics)
    end

    table.insert(client_strings, linter_str)
  end

  return table.concat(client_strings, separator.clients)
end

return status_line
