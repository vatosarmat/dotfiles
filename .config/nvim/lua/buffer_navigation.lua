local utils = require 'utils'
local api = vim.api

local M = {}

local function get_mate_bufs(current_buf_path)
  -- @type string[]
  local mate_bufs = vim.b.mate_bufs

  if not mate_bufs then
    -- get mate_bufs according to project
    mate_bufs = vim.tbl_filter(function(path)
      return vim.fn.filereadable(path) == 1
    end, vim.g.project.mate_bufs.get(current_buf_path))

    if not mate_bufs or #mate_bufs == 0 then
      mate_bufs = { current_buf_path }
    end

    local default_skip = vim.g.project.mate_bufs.default_skip

    if default_skip then
      -- apply default_skip according to project
      local buffer_skip = vim.w.buffer_skip

      for _, mate_buf in ipairs(mate_bufs) do
        -- default_skip is either function or array of patterns to check against
        local skip = (vim.is_callable(default_skip) and default_skip(mate_buf))
          or utils.find(default_skip, function(pattern)
            return mate_buf:match(pattern)
          end)
        if skip then
          buffer_skip[mate_buf] = true
        end
      end

      vim.w.buffer_skip = buffer_skip
    end

    vim.b.mate_bufs = mate_bufs
  end

  return mate_bufs
end

-- this function doesn't depend of the way of initializing mate_bufs
function M.cycle_mate_bufs()
  if vim.bo.buftype ~= '' then
    vim.fn['utils#Warning'] 'That\'s not a normal file buffer'
    return
  end

  local current_buf_path = vim.fn.expand '%:p'
  local mate_bufs = get_mate_bufs(current_buf_path)

  local target_name
  if #mate_bufs == 1 then
    vim.fn['utils#Warning'] 'No mate bufs for this buffer'
    return
  elseif #mate_bufs == 2 then
    target_name = current_buf_path == mate_bufs[1] and mate_bufs[2] or mate_bufs[1]
  else
    local skip_bufs = vim.w.buffer_skip
    for mate_idx, mate_path in ipairs(mate_bufs) do
      if current_buf_path == mate_path then
        local idx = mate_idx
        local i = 0
        -- find first not excluded
        repeat
          i = i + 1
          idx = idx % #mate_bufs + 1
          if idx == mate_idx then
            -- circle closed, all excluded
            -- If all excluded, get the nearest next
            target_name = mate_bufs[idx % #mate_bufs + 1]
          elseif not skip_bufs[mate_bufs[idx]] then
            target_name = mate_bufs[idx]
          end
        until target_name
        break
      end
    end
  end

  vim.fn['jumplist#MateBuf']()
  api.nvim_set_current_buf(vim.uri_to_bufnr(vim.uri_from_fname(target_name)))
end

function M.clear_mate_bufs()
  -- list of mate bufs including current one
  vim.b.mate_bufs = nil
end

return M
