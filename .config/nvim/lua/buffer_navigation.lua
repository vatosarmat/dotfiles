-- This is logica dependency marker
-- require 'project'
local api = vim.api
local buffer_navigation = _U.buffer_navigation

local M = {}

local function read_basename_mates(current_bufname)
  local basename = string.match(vim.fn.fnamemodify(current_bufname, ':t'), '^[^.]+')
  local dir = vim.fn.fnamemodify(current_bufname, ':p:h')
  local exclude_mate_bufs = vim.g.project.exclude_mate_bufs
  local mate_bufs = {}
  local exclude_bufs = {}
  vim.fn.readdir(dir, function(node)
    if vim.startswith(node, basename .. '.') then
      local full = dir .. '/' .. node
      table.insert(mate_bufs, full)
      for _, suf in ipairs(exclude_mate_bufs) do
        if vim.endswith(node, suf) then
          table.insert(exclude_bufs, full)
          break
        end
      end
    end
    return 0
  end)

  return mate_bufs, exclude_bufs
end

local function init_mate_bufs(current_bufname)
  if buffer_navigation[current_bufname] then
    vim.b.mate_bufs = buffer_navigation[current_bufname]
    return buffer_navigation[current_bufname]
  end

  local mate_bufs, mate_exclude_bufs = read_basename_mates(current_bufname)
  for _, buf in ipairs(mate_bufs) do
    buffer_navigation[buf] = mate_bufs
  end
  if #mate_exclude_bufs > 0 then
    local exclude_bufs = vim.w.jumplist_exclude
    for _, buf in ipairs(mate_exclude_bufs) do
      exclude_bufs[buf] = 1
    end

    vim.w.jumplist_exclude = exclude_bufs
  end

  vim.b.mate_bufs = mate_bufs
  return mate_bufs
end

function M.cycle_mate_bufs()
  if vim.bo.buftype ~= '' then
    vim.fn['utils#Warning']('That\'s not a normal file buffer')
    return
  end

  local current_bufname = vim.fn.expand('%:p')
  local mate_bufs = vim.b.mate_bufs

  if not mate_bufs then
    mate_bufs = init_mate_bufs(current_bufname)
  end

  if #mate_bufs == 1 then
    vim.fn['utils#Warning']('No mate bufs for this buffer')
    return
  end

  local exclude_bufs = vim.w.jumplist_exclude
  for current_idx, path in ipairs(mate_bufs) do
    if current_bufname == path then
      local target_name = nil
      if #mate_bufs == 2 then
        -- If only 2 mate bufs, get the nearest next
        target_name = mate_bufs[current_idx % #mate_bufs + 1]
      else
        local idx = current_idx
        local i = 0
        repeat
          i = i + 1
          idx = idx % #mate_bufs + 1
          if idx == current_idx then
            -- If all excluded, get the nearest next
            target_name = mate_bufs[idx % #mate_bufs + 1]
          elseif not exclude_bufs[mate_bufs[idx]] then
            target_name = mate_bufs[idx]
          end
        until target_name
      end
      --
      vim.fn['jumplist#MateBuf']()
      api.nvim_set_current_buf(vim.uri_to_bufnr(vim.uri_from_fname(target_name)))
      return
    end
  end
end

function M.clear_mate_bufs()
  vim.b.mate_bufs = nil
end

return M
