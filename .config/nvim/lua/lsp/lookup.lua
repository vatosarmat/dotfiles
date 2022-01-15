local api = vim.api
local lsp = vim.lsp
local log = require 'vim.lsp.log'
local util = lsp.util

local M = {}

local function make_definition_handler(ui_func)
  return function(_, result, ctx, _)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, 'No location found')
      if lsp.get_client_by_id(ctx.client_id).name ~= 'null-ls' then
        api.nvim_echo({ { 'No definition found', 'WarningMsg' } }, true, {})
      end
      return nil
    end

    local jump_location
    if vim.tbl_islist(result) then
      if #result > 1 then
        vim.fn['lsp#DefinitionList'](util.locations_to_items(result))
        return
      else
        jump_location = result[1]
      end
    else
      jump_location = result
    end
    ui_func(jump_location)
  end
end

local function location_fname(location)
  return vim.uri_to_fname(location.uri or location.targetUri)
end

local function location_pos(location)
  local range = location.range or location.targetSelectionRange
  local row = range.start.line
  local col = util._get_line_byte_from_position(0, range.start)

  return { row + 1, col }
end

local ui_handler = {
  ['tab'] = make_definition_handler(function(location)
    vim.cmd('tabe ' .. location_fname(location))
    api.nvim_win_set_cursor(0, location_pos(location))
    vim.cmd('clearjumps')
  end),
  ['split'] = make_definition_handler(function(location)
    vim.cmd('split' .. location_fname(location))
    api.nvim_win_set_cursor(0, location_pos(location))
    vim.cmd('clearjumps')
  end),
  ['vsplit'] = make_definition_handler(function(location)
    vim.cmd('vsplit' .. location_fname(location))
    api.nvim_win_set_cursor(0, location_pos(location))
    vim.cmd('clearjumps')
  end),
  ['jump'] = make_definition_handler(util.jump_to_location),
  ['preview'] = make_definition_handler(util.preview_location)
}

function M.definition(ui)
  local params = util.make_position_params()
  local handler = ui_handler[ui] or ui_handler['jump']
  vim.lsp.buf_request(0, 'textDocument/definition', params, handler)
end

function M.type_definition(ui)
  local params = util.make_position_params()
  local handler = ui_handler[ui] or ui_handler['jump']
  vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, handler)
end

return M
