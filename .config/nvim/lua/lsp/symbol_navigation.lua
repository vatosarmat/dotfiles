local api = vim.api
local lsp = vim.lsp
local log = require 'vim.lsp.log'
local pui = require 'lsp.protocol_ui'
local misc = require 'lsp.misc'

local symbol_icons = pui.symbol_icons
local util = lsp.util

--
-- Helpers 1
--

-- LSP range and pos. Zero-based
local function is_pos_in_range(range, pos)
  local pos_line, pos_char = unpack(pos)
  return (pos_line > range.start.line and pos_line < range['end'].line) or
           ((pos_line == range.start.line or pos_line == range['end'].line) and
             (pos_char >= range.start.character and pos_char <= range['end'].character))
end

-- local function get_cursor_pos()
--   -- zero-based line number
--   local pos = api.nvim_win_get_cursor(0)
--   pos[1] = pos[1] - 1
--   return pos
-- end

local function make_loclist_item(S, symbol)
  local item = S.make_loclist_item(symbol)
  item.symbol = symbol
  local line = api.nvim_buf_get_lines(0, item.lnum - 1, item.lnum, false)[1]
  if item.col > #line then
    item.col = 1
  end
  return item
end

-- DocumentSymbol: name:string, detail?:string, kind:SymbolKind, range:Range(body), selectionRange:Range(function name), children:DocumentSymbol[]
-- SymbolInformation: name:string, kind:SymbolKind, location:Location{uri:DocumentUri, range:Range}
-- Range{start:{line, character}, end{line, character}}

--
-- DocumentSymbol
--
local DocumentSymbol = {
  name = 'DocumentSymbol'
}
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

  function DocumentSymbol.is_cursor_on_symbol(symbol)
    local cursor_line = api.nvim_win_get_cursor(0)[1] - 1
    return cursor_line >= symbol.range.start.line and cursor_line <= symbol.range['end'].line
  end

  -- function DocumentSymbol.is_pos_in_symbol_range(symbol, pos)
  --   return is_pos_in_range(symbol.range, pos)
  -- end

  function DocumentSymbol.make_loclist_tree(symbols)
    local tree = {}
    local next_depth = {
      {
        parent = nil,
        children = symbols
      }
    }
    local depth = 0

    -- Make items from parents to children
    while #next_depth > 0 do
      local current_depth = next_depth
      next_depth = {}
      depth = depth + 1
      -- print('Depth ' .. depth)

      for _, parent_entry in ipairs(current_depth) do
        for _, symbol in ipairs(parent_entry.children) do
          local item = make_loclist_item(DocumentSymbol, symbol)
          -- print(item.symbol.name)
          item.parent = parent_entry.parent

          if item.parent then
            if not item.parent.children then
              item.parent.children = {}
              item.parent.text = item.parent.text .. ' ' .. pui.symbol_icons.has_children
            end
            table.insert(item.parent.children, item)
          else
            -- this item is top-level
            table.insert(tree, item)
          end

          -- If symbol has children - they gonna be on the next depth
          if symbol.children and #symbol.children > 0 then
            table.insert(next_depth, {
              parent = item,
              children = symbol.children
            })
          end
          symbol.children = nil
        end
      end
    end

    return tree
  end
end

--
-- SymbolInformation
--

-- interface Location {
-- 	uri: string;
-- 	range: {start{line, charachter}, end{line, character}};
-- }

-- export interface SymbolInformation {
-- 	name: string;
-- 	kind: SymbolKind;
-- 	tags?: SymbolTag[];
-- 	deprecated?: boolean;
-- 	location: Location;
-- 	containerName?: string;
-- }

local SymbolInformation = {
  name = 'SymbolInformation'
}

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

  function SymbolInformation.is_cursor_on_symbol(symbol)
    local cursor_line = api.nvim_win_get_cursor(0)[1] - 1
    return cursor_line >= symbol.location.range.start.line and cursor_line <=
             symbol.location.range['end'].line
  end

  function SymbolInformation.is_pos_in_symbol_range(symbol, pos)
    return is_pos_in_range(symbol.location.range, pos)
  end

  function SymbolInformation.make_loclist_tree(symbols)
    -- sort symbols list
    -- build tree

    table.sort(symbols, function(a, b)
      -- sort by range start
      a = a.location.range.start
      b = b.location.range.start
      return a.line < b.line or a.line == b.line and a.character < b.character
    end)

    local prev_item = make_loclist_item(SymbolInformation, symbols[1])
    local tree = { prev_item }
    local parent_stack = {}
    symbols = { unpack(symbols, 2) }

    -- assume that if start is in range, whole symbol is in range
    for _, symbol in ipairs(symbols) do
      local current_item = make_loclist_item(SymbolInformation, symbol)
      local current_item_start = {
        symbol.location.range.start.line,
        symbol.location.range.start.character
      }

      local where_to_add
      local parent
      if SymbolInformation.is_pos_in_symbol_range(prev_item.symbol, current_item_start) then
        -- new parent, save it onto stack

        parent = prev_item
        prev_item.children = {}
        prev_item.text = prev_item.text .. ' ' .. pui.symbol_icons.has_children
        where_to_add = prev_item.children
        table.insert(parent_stack, prev_item)
      else
        -- find parent in stack
        parent = nil
        local new_stack_top
        for i = 1, #parent_stack do
          local idx = #parent_stack + 1 - i
          local p = parent_stack[idx]
          if SymbolInformation.is_pos_in_symbol_range(p.symbol, current_item_start) then
            parent = p
            new_stack_top = idx
            break
          end
        end

        if parent then
          where_to_add = parent.children
          parent_stack = { unpack(parent_stack, 1, new_stack_top) }
        else
          where_to_add = tree
          parent_stack = {}
        end
      end

      current_item.parent = parent
      table.insert(where_to_add, current_item)
      prev_item = current_item
    end

    return tree
  end
end

local SymbolHandler = {
  ['SymbolInformation'] = SymbolInformation,
  ['DocumentSymbol'] = DocumentSymbol
}

--
-- Helpers 2
--
local function get_symbol_handler(symbol)
  if symbol.selectionRange then
    return DocumentSymbol
  end
  return SymbolInformation
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
  vim.fn['lsp#SymbolListOpen']()
end

--
-- textDocument/documentSymbol handler and request
--
local top_level_title = 'Top level'
---@diagnostic disable-next-line: unused-local
local function document_symbol_handler(err, request_result, ctx, config)
  -- Handle missing result
  if not request_result or #request_result == 0 then
    local _ = log.info() and log.info(ctx.method, 'No location found')
    if lsp.get_client_by_id(ctx.client_id).name ~= 'null-ls' then
      api.nvim_echo({ { 'No symbols found', 'WarningMsg' } }, true, {})
    end
    return
  end

  local symbols = request_result
  local S = get_symbol_handler(symbols[1])

  local bufnr = misc.get_bufnr(ctx.bufnr)
  if not symbol_navigation[bufnr] then
    symbol_navigation[bufnr] = {
      S = S,
      tree = nil, -- items array
      loclist_depth = 0,
      loclist_root = nil -- item, its children currently in loclist
    }
  end
  symbol_navigation[bufnr].tree = S.make_loclist_tree(symbols)
  set_loclist(top_level_title, symbol_navigation[bufnr].tree)
  vim.fn['lsp#SymbolListSync']()
end

local M = {}

function M.document_symbol_request()
  local params = {
    textDocument = util.make_text_document_params()
  }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, document_symbol_handler)
end

--
-- loclist controls
--
function M.loclist_depth_down()
  -- set children of the symbol under cursor into the loclist
  local sn = symbol_navigation[misc.get_bufnr()]
  local depth_nodes = sn.loclist_root and sn.loclist_root.children or sn.tree

  local node_at_pos = nil
  for _, node in ipairs(depth_nodes) do
    if sn.S.is_cursor_on_symbol(node.symbol) then
      node_at_pos = node
      break
    end
  end

  if node_at_pos and node_at_pos.children then
    -- if children present it is not empty
    set_loclist(node_at_pos.symbol.name, node_at_pos.children)
    sn.loclist_root = node_at_pos
    sn.loclist_depth = sn.loclist_depth + 1
    vim.cmd('lafter')
  else
    api.nvim_echo({ { 'Symbol under cursor has no children', 'WarningMsg' } }, true, {})
  end
end

function M.loclist_depth_up()
  local sn = symbol_navigation[misc.get_bufnr()]

  if sn.loclist_root then
    local new_root = sn.loclist_root.parent
    local title, items
    if new_root then
      title = new_root.symbol.name
      items = new_root.children
    else
      title = top_level_title
      items = sn.tree
    end
    set_loclist(title, items)
    sn.loclist_root = new_root
    sn.loclist_depth = sn.loclist_depth - 1
    vim.cmd('lbefore')
  else
    api.nvim_echo({ { 'These symbols are top-level', 'WarningMsg' } }, true, {})
  end
end

return M
