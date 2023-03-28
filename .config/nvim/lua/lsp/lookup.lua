local api = vim.api
local lsp = vim.lsp
local log = require 'vim.lsp.log'
local util = lsp.util
local misc = require 'lsp.misc'
local cext = require 'lsp.client_ext'

local M = {}

local function location_fname(location)
  return vim.uri_to_fname(location.uri or location.targetUri)
end

local function location_pos(location)
  local range = location.range or location.targetSelectionRange
  local row = range.start.line
  local col = util._get_line_byte_from_position(0, range.start)

  return { row + 1, col }
end

local function make_definition_handler(ui)
  return function(_, result, ctx, _)
    -- Handle "not-found"
    local client_name = lsp.get_client_by_id(ctx.client_id).name
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, 'No location found')
      if client_name ~= 'null-ls' then
        api.nvim_echo({ { 'No definition found', 'WarningMsg' } }, true, {})
      end
      return nil
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)

    -- Either jump or list location
    local jump_location, list_location
    if vim.tbl_islist(result) then
      local filter = cext[client_name].definition_filter
      if filter then
        result = filter(ctx.method, result)
      end
      if #result == 1 then
        jump_location = result[1]
      else
        list_location = result
      end
    else
      jump_location = result
    end

    local win_cmd = {
      tabe = 'tabe',
      split = 'split',
      vsplit = 'vsplit'
    }
    if win_cmd[ui] then
      if jump_location then
        vim.cmd(win_cmd[ui] .. ' ' .. location_fname(jump_location))
        api.nvim_win_set_cursor(0, location_pos(jump_location))
      else
        vim.cmd(win_cmd[ui])
        vim.fn['lsp#DefinitionList'](misc.locations_to_items(list_location, client.offset_encoding))
      end
      vim.cmd('clearjumps')
    elseif ui == 'preview' then
      util.preview_location(jump_location and jump_location or list_location[1])
    else
      -- ui == 'jump' then
      if jump_location then
        util.jump_to_location(jump_location, client.offset_encoding)
      else
        local a = misc.locations_to_items(list_location, client.offset_encoding)
        vim.fn['lsp#DefinitionList'](a)
      end
    end
  end
end

function M.definition(ui)
  local params = util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/definition', params, make_definition_handler(ui))
end

function M.type_definition(ui)
  local params = util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, make_definition_handler(ui))
end

return M
