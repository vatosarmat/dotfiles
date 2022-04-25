local api = vim.api

local M = {}

local function read_basename_mates()
  local basename = string.match(vim.fn.expand('%:t'), '^[^.]+')
  local dir = vim.fn.expand('%:p:h')
  local mate_file_names = vim.fn.readdir(dir, function(node)
    if vim.startswith(node, basename .. '.') then
      return 1
    end
    return 0
  end)

  return vim.tbl_map(function(name)
    return dir .. '/' .. name
  end, mate_file_names)
end

function M.cycle_mate_bufs()
  if vim.bo.buftype ~= '' then
    vim.fn['utils#Warning']('That\'s not a normal file buffer')
    return
  end

  local mate_bufs = vim.b.mate_bufs
  if not mate_bufs then
    mate_bufs = read_basename_mates()
    vim.b.mate_bufs = mate_bufs
  end
  if #mate_bufs == 1 then
    vim.fn['utils#Warning']('No mate bufs for this buffer')
    return
  end

  local exclude = vim.w.jumplist_exclude
  local current = vim.fn.expand('%:p')
  for current_idx, path in ipairs(mate_bufs) do
    if current == path then
      local target_nr
      if #mate_bufs == 2 then
        local target_name = mate_bufs[current_idx % #mate_bufs + 1]
        target_nr = vim.uri_to_bufnr(vim.uri_from_fname(target_name))
      else
        local idx = current_idx
        local go = true
        repeat
          idx = idx % #mate_bufs + 1
          if idx == current_idx then
            -- all bufs are excluded, so take the first next
            idx = idx % #mate_bufs + 1
            go = false
          end
          local target_name = mate_bufs[idx]
          target_nr = vim.uri_to_bufnr(vim.uri_from_fname(target_name))
        until not (go and exclude[tostring(target_nr)])
      end

      api.nvim_set_current_buf(target_nr)
      if not vim.b.mate_bufs then
        vim.b.mate_bufs = mate_bufs
      end
      return
    end
  end
end

function M.clear_mate_bufs()
  vim.b.mate_bufs = nil
end

return M
