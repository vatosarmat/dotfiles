local api = vim.api
local lsp = vim.lsp
-- local null_ls = require 'null-ls'
local null_ls_namespace = require'null-ls.diagnostics'.get_namespace
local null_ls_available_sources = require'null-ls.sources'.get_available
local pui = require 'plug-config.lsp.protocol_ui'
local cext = require 'plug-config.lsp.client_ext'

local separator = {
  clients = '][',
  diagnostics = ' ',
  progress = '|'
}

local function diagnostic_lines(_, namespace)
  local diagnostics = {}
  -- loop over vim severities
  -- M.severity = {
  -- ERROR = 1,
  -- WARN = 2,
  -- INFO = 3,
  -- HINT = 4,
  -- }
  local i = 1
  while i <= 4 do
    local opts = {
      severity = i,
      namespace = namespace
    }
    local count = #vim.diagnostic.get(0, opts)
    if count > 0 then
      table.insert(diagnostics, '%' .. i .. '*' .. pui.severities[i].sign .. ' %*' .. count)
    end
    i = i + 1
  end

  return diagnostics
end

local function status_line()
  local clients = lsp.buf_get_clients(0)
  local client_strings = {}
  -- exclude null-ls
  for _, client in pairs(clients) do
    if client.name ~= 'null-ls' then
      local namespace = lsp.diagnostic.get_namespace(client.id)
      local diagnostics = diagnostic_lines(client.name, namespace)

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
  end

  local null_ls_sources = null_ls_available_sources(api.nvim_buf_get_option(0, 'ft'))
  for _, source in ipairs(null_ls_sources) do
    local diagnostics = diagnostic_lines('null-ls', null_ls_namespace(source.id))
    local linter_str = cext[source.name].short_name or source.name

    if next(diagnostics) then
      linter_str = linter_str .. ':' .. table.concat(diagnostics, separator.diagnostics)
    end

    table.insert(client_strings, linter_str)
  end

  return table.concat(client_strings, separator.clients)
end

return status_line
