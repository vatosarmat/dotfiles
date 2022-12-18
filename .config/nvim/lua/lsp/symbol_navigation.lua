local api = vim.api
local lsp = vim.lsp
local tablex = require 'pl.tablex'
local log = require 'vim.lsp.log'
local ui_symbol = require'lsp.ui'.symbol
local misc = require 'lsp.misc'

local util = lsp.util
local symbol_navigation = _U.symbol_navigation

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

local function item_with_children(item)
  item.children = {}
  item.text = item.text .. ' ' .. ui_symbol.has_children.icon
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
      text = (ui_symbol[kind].icon or kind) .. '  ' .. symbol.name .. maybe_detail
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
        table.sort(parent_entry.children, function(a, b)
          -- sort by selectionRange start
          a = a.selectionRange.start
          b = b.selectionRange.start
          return a.line < b.line or a.line == b.line and a.character < b.character
        end)
        for _, symbol in ipairs(parent_entry.children) do
          local item = make_loclist_item(DocumentSymbol, symbol)
          -- print(item.symbol.name)
          item.parent = parent_entry.parent

          if item.parent then
            if not item.parent.children then
              item_with_children(item.parent)
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
      text = (ui_symbol[kind].icon or kind) .. '  ' .. symbol.name
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
        item_with_children(prev_item)
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

local function get_symbol_handler(symbol)
  if symbol.selectionRange then
    return DocumentSymbol
  end
  return SymbolInformation
end

local function SymbolNavigation(initial_symbols)
  -- const
  local top_level_title = 'Top level'
  local path_sep = '.'
  local S = get_symbol_handler(initial_symbols[1])

  -- priv
  local state = {
    tree = S.make_loclist_tree(initial_symbols),
    loclist_node = nil,
    loclist_node_path = {},

    get_loclist_items = function(self)
      return self.loclist_node and self.loclist_node.children or self.tree
    end
  }

  local function set_loclist()
    local items = state:get_loclist_items()
    local path = state.loclist_node_path

    local what = {
      items = items,
      title = #path > 0 and table.concat(path, path_sep) or top_level_title,
      context = {
        type = 'symbol_list'
      }
    }

    function what.quickfixtextfunc(info)
      return vim.tbl_map(function(item)
        -- return string.format('|%-5d| %s', item.lnum, item.text)
        return item.text
      end, vim.list_slice(items, info.start_idx, info.end_idx))
    end

    -- current winodw, {} ignored, ' ' - create new list, what - actual data
    -- what allows to specify textfunc, so use it instead of the 2 argument
    vim.fn.setloclist(0, {}, ' ', what)
    vim.fn['lsp#SymbolListOpen'](path)
  end

  local function sync_loclist(after_or_before)
    local items = state:get_loclist_items()
    local sync_fn = {
      after = 'lsp#Lafter',
      before = 'lsp#Lbefore'
    }

    local cursor = api.nvim_win_get_cursor(0)
    if cursor[1] < items[1].lnum then
      -- cursor is above the first item, move it forward
      vim.fn['lsp#Lafter']()
    elseif cursor[1] > items[#items].lnum then
      -- cursor is below the last item, move it backward
      vim.fn['lsp#Lbefore']()
    else
      -- cursor may be on one of the list items, select that item in list
      local index = tablex.find_if(items, function(item)
        return item.lnum == cursor[1] and item.lnum or nil
      end)
      if index then
        vim.cmd('ll ' .. index)
      else
        vim.fn[sync_fn[after_or_before]]()
      end
      api.nvim_win_set_cursor(0, cursor)
    end
  end

  -- constructor
  set_loclist()

  -- pub
  local pub = {}

  function pub.update(symbols)
    state.tree = S.make_loclist_tree(symbols)
    set_loclist()
  end

  function pub.up()
    if state.loclist_node then
      state.loclist_node = state.loclist_node.parent
      -- remove last element
      state.loclist_node_path = vim.list_slice(state.loclist_node_path, 1,
                                               #state.loclist_node_path - 1)
      set_loclist()
      sync_loclist('before')
    else
      api.nvim_echo({ { 'These symbols are top-level', 'WarningMsg' } }, true, {})
    end
  end

  function pub.down()
    local items = state:get_loclist_items()

    -- find node/item under cursor
    local node_at_cursor = nil
    for _, node in ipairs(items) do
      if S.is_cursor_on_symbol(node.symbol) then
        node_at_cursor = node
        break
      end
    end

    -- if it has children, populate loclist with them
    if node_at_cursor and node_at_cursor.children then
      state.loclist_node = node_at_cursor
      -- table.insert(state.loclist_node_path, {
      --   util._get_symbol_kind_name(node_at_cursor.symbol.kind),
      --   node_at_cursor.symbol.name
      -- })
      table.insert(state.loclist_node_path, node_at_cursor.symbol.name)
      set_loclist()
      sync_loclist('after')
    else
      api.nvim_echo({ { 'Symbol under cursor has no children', 'WarningMsg' } }, true, {})
    end

  end

  return pub
end

--
-- textDocument/documentSymbol handler and request
--
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
  local bufnr = misc.get_bufnr(ctx.bufnr)
  if not symbol_navigation[bufnr] then
    symbol_navigation[bufnr] = SymbolNavigation(symbols)
  else
    symbol_navigation[bufnr].update(symbols)
  end
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
  symbol_navigation[misc.get_bufnr()].down()
end

function M.loclist_depth_up()
  symbol_navigation[misc.get_bufnr()].up()
end

return M
