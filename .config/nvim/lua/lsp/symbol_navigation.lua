local api = vim.api
local lsp = vim.lsp
local log = require 'vim.lsp.log'
local tablex = require 'pl.tablex'
local pui = require 'lsp.protocol_ui'

local symbol_icons = pui.symbol_icons
local util = lsp.util
local M = {}

local function symbol_lnum(symbol)
  if symbol.location then
    -- SymbolInformation type
    return symbol.location.range.start.line + 1
  else
    -- DocumentSymbol type
    return symbol.selectionRange.start.line + 1
  end
end

local function sort_symbols_by_lnum(list)
  table.sort(list, function(a, b)
    return symbol_lnum(a) < symbol_lnum(b)
  end)
  return list
end

-- Convert symbols to quickfix list
local function symbols_to_items(symbols, bufnr)
  local function _symbols_to_items(_symbols, _items, _bufnr)
    for _, symbol in ipairs(_symbols) do
      local lnum = symbol_lnum(symbol)
      if symbol.location then -- SymbolInformation type
        local range = symbol.location.range
        local kind = util._get_symbol_kind_name(symbol.kind)
        table.insert(_items, {
          filename = vim.uri_to_fname(symbol.location.uri),
          lnum = lnum,
          col = range.start.character + 1,
          kind = kind,
          -- text = '[' .. kind .. '] ' .. symbol.name
          text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name
        })
      elseif symbol.selectionRange then -- DocumentSymbol type
        local kind = util._get_symbol_kind_name(symbol.kind)
        local maybe_detail = symbol.detail and '  ' .. symbol.detail or ''
        table.insert(_items, { -- bufnr = _bufnr,
          filename = vim.api.nvim_buf_get_name(_bufnr),
          lnum = lnum,
          col = symbol.selectionRange.start.character + 1,
          kind = kind,
          -- text = '[' .. kind .. '] ' .. symbol.name
          text = (symbol_icons[kind] or kind) .. '  ' .. symbol.name .. maybe_detail
        })

        -- Don't go for children
        -- if symbol.children then
        --   for _, v in ipairs(
        --                 _symbols_to_items(symbol.children, _items, _bufnr)) do
        --     vim.list_extend(_items, v)
        --   end
        -- end
      end
    end
    return _items
  end
  return _symbols_to_items(symbols, {}, bufnr)
end

-- Render only line num and text in the list, don't show file names
local function loclist_set(title, items)
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

-- vim.g.igor = ''
local function parent_symbol_under_cursor(items)
  local pos = api.nvim_win_get_cursor(0)
  local cursor_line = pos[1] - 1
  local cursor_character = pos[2]
  local function _find_psuc(_items)
    -- Find if items have symbol under cursor
    local uc_idx = tablex.find_if(_items, function(item)
      local sr = item.location and item.location.range or item.range
      -- vim.g.igor = vim.g.igor ..
      --                string.format('%s: %d %d %d %d', item.name, sr.start.line,
      --                              sr.start.character, sr['end'].line, sr['end'].character) ..
      --                '\n'
      return (cursor_line > sr.start.line and cursor_line < sr['end'].line) or
               ((cursor_line == sr.start.line or cursor_line == sr['end'].line) and
                 (cursor_character >= sr.start.character and cursor_character <= sr['end'].character))
    end)
    -- If have and it has children, remember it and check its children
    -- if uc_idx then
    --   vim.g.igor = vim.g.igor .. _items[uc_idx].name .. '\n'
    -- end
    if uc_idx and _items[uc_idx].children then
      return _find_psuc(_items[uc_idx].children) or _items[uc_idx]
    end
  end
  return _find_psuc(items)
end

-- handler with filter_sort and on_done
local function make_symbol_handler(title, filter_sort, on_done)
  ---@diagnostic disable-next-line: unused-local
  return function(err, request_result, ctx, config)
    if not request_result or vim.tbl_isempty(request_result) then
      local _ = log.info() and log.info(ctx.method, 'No location found')
      if lsp.get_client_by_id(ctx.client_id).name ~= 'null-ls' then
        api.nvim_echo({ { 'No symbols found', 'WarningMsg' } }, true, {})
      end
      return
    end

    local psuc = parent_symbol_under_cursor(request_result)
    local a = filter_sort(psuc and psuc.children or request_result)
    local items = symbols_to_items(a, ctx.bufnr)
    loclist_set(psuc and psuc.name .. ': ' .. title or title, items)
    api.nvim_command 'lopen | wincmd p'
    on_done()
  end
end

local function loclist_sync()
  -- vim.cmd('lbefore | normal! \015')
  vim.cmd 'try | lbefore | catch /E553/ | lafter | endtry'
end

-- Pub selectors

function M.document_list_symbols(title, filter_sort, on_done)
  title = title or 'all symbols'
  filter_sort = filter_sort or sort_symbols_by_lnum
  on_done = on_done or loclist_sync
  local params = {
    textDocument = util.make_text_document_params()
  }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params,
                      make_symbol_handler(title, filter_sort, on_done))
end

function M.document_list_functions()
  local function filter_sort(items)
    local ret = {}
    for _, item in ipairs(items) do
      if vim.lsp.util._get_symbol_kind_name(item.kind) == 'Function' then
        table.insert(ret, item)
      end
    end
    return sort_symbols_by_lnum(ret)
  end
  M.document_list_symbols('functions', filter_sort)
end

function M.document_list_non_props()
  local function filter_sort(items)
    local ret = {}
    for _, item in ipairs(items) do
      if vim.lsp.util._get_symbol_kind_name(item.kind) ~= 'Property' then
        table.insert(ret, item)
      end
    end
    return sort_symbols_by_lnum(ret)
  end
  M.document_list_symbols('symbols', filter_sort)
end

return M
