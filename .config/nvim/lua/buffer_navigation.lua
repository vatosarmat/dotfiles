local api = vim.api

local M = {}

local function read_basename_mates()
  local basename = vim.fn.expand('%:t:r')
  local dir = vim.fn.expand('%:p:h')
  local mate_file_names = vim.fn.readdir(dir, function(node)
    if vim.startswith(node, basename) then
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

  local current = vim.fn.expand('%:p')
  for idx, path in ipairs(mate_bufs) do
    if current == path then
      local target_name = mate_bufs[(idx - 1 + 1) % #mate_bufs + 1]
      local target_nr = vim.uri_to_bufnr(vim.uri_from_fname(target_name))
      api.nvim_set_current_buf(target_nr)
      return
    end
  end
end

function M.clear_mate_bufs()
  vim.b.mate_bufs = nil
end

return M
