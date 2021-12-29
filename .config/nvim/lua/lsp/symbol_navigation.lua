local api = vim.api
local lsp = vim.lsp
local log = require 'vim.lsp.log'
local tablex = require 'pl.tablex'
local pui = require 'lsp.protocol_ui'

local symbol_icons = pui.symbol_icons
local util = lsp.util
local M = {}

--
-- LSP range and pos. Zero-based
--
local function is_pos_in_range(range, pos)
  local pos_line, pos_char = unpack(pos)
  return (pos_line > range.start.line and pos_line < range['end'].line) or
           ((pos_line == range.start.line or pos_line == range['end'].line) and
             (pos_char >= range.start.character and pos_char <= range['end'].character))
end

local function get_cursor_pos()
  -- zero-based line number
  local pos = api.nvim_win_get_cursor(0)
  pos[1] = pos[1] - 1
  return pos
end

local function get_loclist_item_lsp_pos(item)
  return { item.lnum - 1, item.col - 1 }
end

-- DocumentSymbol: name:string, detail?:string, kind:SymbolKind, range:Range(body), selectionRange:Range(function name), children:DocumentSymbol[]
-- SymbolInformation: name:string, kind:SymbolKind, location:Location{uri:DocumentUri, range:Range}
-- Range{start:{line, character}, end{line, character}}

--
-- DocumentSymbol
--
local DocumentSymbol = {}
do
  function DocumentSymbol.make_loclist_item(symbol)
    local start = symbol.selectionRange.start
    local kind = util._get_symbol_kind_name(symbol.kind)
    local maybe_detail = symbol.detail and '  ' .. symbol.detail or ''
    return {
      filename = vim.api.nvim_buf_get_name(0),
      lnum = start.line + 1,
      col = start.character + 1,
      text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name .. maybe_detail
    }
  end

  function DocumentSymbol.is_pos_in_symbol_range(symbol, pos)
    return is_pos_in_range(symbol.range, pos)
  end

  function DocumentSymbol.get_deepest_children(symbols, cursor_pos)
    -- deepest children under cursor
    local function get_deepest_parent(_items)
      -- deepest parent - i.e. symbol with non-empty children symbols
      local uc_idx = tablex.find_if(_items, function(item)
        return is_pos_in_range(item.range, cursor_pos)
      end)
      if uc_idx and _items[uc_idx].children then
        return get_deepest_parent(_items[uc_idx].children) or _items[uc_idx]
      end
    end
    return get_deepest_parent(symbols)
  end
end

--
-- SymbolInformation
--
local SymbolInformation = {}

do
  function SymbolInformation.make_loclist_item(symbol)
    local start = symbol.location.range.start
    local kind = util._get_symbol_kind_name(symbol.kind)
    return {
      filename = vim.uri_to_fname(symbol.location.uri),
      lnum = start.line + 1,
      col = start.character + 1,
      text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name
    }
  end

  function SymbolInformation.is_pos_in_symbol_range(symbol, pos)
    return is_pos_in_range(symbol.location.range, pos)
  end
end

--
-- Helpers 2
--
local function get_symbol_handler(symbol)
  if symbol.selectionRange then
    return DocumentSymbol
  end
  return SymbolInformation
end

local function make_loclist_item(S, symbol)
  local item = S.make_loclist_item(symbol)
  item.symbol = symbol
  local line = api.nvim_buf_get_lines(0, item.lnum - 1, item.lnum, false)[1]
  if item.col > #line then
    item.col = 1
  end
  return item
end

local function make_loclist(S, symbols, predicate)
  -- Turn symbols into sorted and filtered loclist
  if #symbols == 0 then
    return {}
  end
  local items = {}
  for _, symbol in ipairs(symbols) do
    -- print(not predicate or predicate(symbol))
    if not predicate or predicate(symbol) then
      table.insert(items, make_loclist_item(S, symbol))
    end
  end
  table.sort(items, function(a, b)
    return a.lnum < b.lnum
  end)
  return items
end

local function infer_children_by_range(S, cursor_pos, loclist_items)
  local siblings = {}
  -- Previous item
  local prev_symbol
  -- The range where the cursor is in
  local parent_symbol
  -- The range where the cursor is not in
  local skip_symbol

  for _, item in ipairs(loclist_items) do
    local item_pos = get_loclist_item_lsp_pos(item)

    if parent_symbol and not S.is_pos_in_symbol_range(parent_symbol, item_pos) then
      break
    end

    if not (skip_symbol and S.is_pos_in_symbol_range(skip_symbol, item_pos)) then
      skip_symbol = nil

      if prev_symbol and S.is_pos_in_symbol_range(prev_symbol, item_pos) then
        if S.is_pos_in_symbol_range(prev_symbol, cursor_pos) then
          -- Either items from the range should be the only content of siblings returned
          siblings = { item }
          parent_symbol = prev_symbol
        else
          -- or they must be skipped
          skip_symbol = prev_symbol
        end
        prev_symbol = nil
      else
        -- Either no prev_range or the current item is not in it
        prev_symbol = item.symbol
        table.insert(siblings, item)
      end
    end
  end

  return siblings, parent_symbol and parent_symbol.name
end

local function set_loclist(title, items)
  local what = {
    title = title,
    items = items
  }

  function what.quickfixtextfunc(info)
    return vim.tbl_map(function(item)
      return string.format('|%-5d| %s', item.lnum, item.text)
    end, vim.list_slice(items, info.start_idx, info.end_idx))
  end

  vim.fn.setloclist(0, {}, ' ', what)
end

--
-- textDocument/documentSymbol
--
local function make_symbol_handler(initial_title, filter_predicate)
  ---@diagnostic disable-next-line: unused-local
  return function(err, request_result, ctx, config)
    -- Handle missing result
    if not request_result or #request_result == 0 then
      local _ = log.info() and log.info(ctx.method, 'No location found')
      if lsp.get_client_by_id(ctx.client_id).name ~= 'null-ls' then
        api.nvim_echo({ { 'No symbols found', 'WarningMsg' } }, true, {})
      end
      return
    end

    local symbols = request_result
    -- print(#symbols)
    local title = initial_title
    local S = get_symbol_handler(symbols[1])
    local pos = get_cursor_pos()
    if S.get_deepest_children then
      local parent = S.get_deepest_children(symbols, pos)
      if parent then
        title = parent.name .. ': ' .. initial_title
        symbols = parent.children
      end
      -- print(#symbols)
    end

    local loclist_items = make_loclist(S, symbols, filter_predicate)
    -- print(#loclist_items)
    local loclist_items2, parent_name = infer_children_by_range(S, pos, loclist_items)
    -- print(#loclist_items2)
    if parent_name then
      title = parent_name .. ': ' .. initial_title
    end
    set_loclist(title, loclist_items2)
    vim.fn['lsp#SymbolList']()
  end
end

-- Pub selectors

function M.document_list_symbols(title, filter_predicate)
  title = title or 'all symbols'
  local params = {
    textDocument = util.make_text_document_params()
  }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params,
                      make_symbol_handler(title, filter_predicate))
end

function M.document_list_functions()
  M.document_list_symbols('functions', function(symbol)
    return util._get_completion_item_kind_name(symbol.kind) == 'Function'
  end)
end

function M.document_list_non_props()
  M.document_list_symbols('symbols', function(symbol)
    return util._get_completion_item_kind_name(symbol.kind) ~= 'Property'
  end)
end

return M
