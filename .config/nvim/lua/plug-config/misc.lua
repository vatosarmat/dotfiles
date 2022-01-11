local M = {}

function M.commentary()
  local map = require'vim_utils'.map
  -- function comment(a)
  --   require'ts_context_commentstring.internal'.update_commentstring()
  --   if a == 1 then
  --     return "<Plug>Commentary"
  --   else
  --     return "<Plug>CommentaryLine"
  --   end
  -- end
  local opts = {
    noremap = false
  }
  map('n', '<C-_>', '<Plug>CommentaryLine', opts)
  map('x', '<C-_>', '<Plug>Commentary', opts)
end

function M.asterisk()
  local map = require'vim_utils'.map
  local opts = {
    noremap = false
  }
  map('nxo', '*', '<Plug>(asterisk-z*)', opts)
  map('nxo', '#', '<Plug>(asterisk-z#)', opts)
  map('nxo', 'g*', '<Plug>(asterisk-gz*)', opts)
  map('nxo', 'g#', '<Plug>(asterisk-gz#)', opts)
end

function M.wordmotion()
  local map = require'vim_utils'.map
  vim.g.wordmotion_nomap = 1
  vim.g.wordmotion_uppercase_spaces = { '[^[:keyword:]]' }
  local opts = {
    noremap = false
  }
  map('nxo', 'S', 'gE', opts)

  map('nxo', 'w', '<Plug>WordMotion_W', opts)
  map('nxo', 'b', '<Plug>WordMotion_B', opts)
  map('nxo', 'e', '<Plug>WordMotion_E', opts)
  map('nxo', 's', '<Plug>WordMotion_gE', opts)
  map('nxo', '<M-w>', '<Plug>WordMotion_w', opts)
  map('nxo', '<M-b>', '<Plug>WordMotion_b', opts)
  map('nxo', '<M-e>', '<Plug>WordMotion_e', opts)
  map('nxo', '<M-s>', '<Plug>WordMotion_ge', opts)
  map('o', 'a<M-w>', '<Plug>WordMotion_aw', opts)
  map('o', 'i<M-w>', '<Plug>WordMotion_iw', opts)
end

function M.surround()
  local map = require'vim_utils'.map
  vim.g.surround_indent = 1
  local opts = {
    noremap = false
  }
  map('n', ',', '<Plug>Ysurround', opts)
  map('x', ',', '<Plug>VSurround', opts)
end

function M.scrollview()
  vim.g.scrollview_on_startup = 1
  vim.g.scrollview_winblend = 60
  vim.g.scrollview_column = 1
  vim.g.scrollview_auto_mouse = 0
end

return M
