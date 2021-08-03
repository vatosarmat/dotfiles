local M = {}

function M.commentary()
  local map = require'before-plug.vim_utils'.map
  -- function comment(a)
  --   require'ts_context_commentstring.internal'.update_commentstring()
  --   if a == 1 then
  --     return "<Plug>Commentary"
  --   else
  --     return "<Plug>CommentaryLine"
  --   end
  -- end
  local opts = { noremap = false }
  map('n', '<C-_>', '<Plug>CommentaryLine', opts)
  map('x', '<C-_>', '<Plug>Commentary', opts)
end

function M.asterisk()
  local map = require'before-plug.vim_utils'.map
  local opts = { noremap = false }
  map({ 'n', 'x', 'o' }, '*', '<Plug>(asterisk-z*)', opts)
  map({ 'n', 'x', 'o' }, '#', '<Plug>(asterisk-z#)', opts)
  map({ 'n', 'x', 'o' }, 'g*', '<Plug>(asterisk-gz*)', opts)
  map({ 'n', 'x', 'o' }, 'g#', '<Plug>(asterisk-gz#)', opts)
end

function M.wordmotion()
  local map = require'before-plug.vim_utils'.map
  vim.g.wordmotion_nomap = 1
  local opts = { noremap = false }
  map({ 'n', 'x', 'o' }, '<M-w>', '<Plug>WordMotion_w', opts)
  map({ 'n', 'x', 'o' }, '<M-b>', '<Plug>WordMotion_b', opts)
  map({ 'n', 'x', 'o' }, '<M-e>', '<Plug>WordMotion_e', opts)
  map({ 'o' }, 'a<M-w>', '<Plug>WordMotion_aw', opts)
  map({ 'o' }, 'i<M-w>', '<Plug>WordMotion_iw', opts)
end

function M.surround()
  vim.g.surround_indent = 1
  require'before-plug.vim_utils'.map('x', 's', 'S', { noremap = false })
end

function M.scrollview()
  vim.g.scrollview_on_startup = 1
  vim.g.scrollview_winblend = 60
  vim.g.scrollview_column = 1
  vim.g.scrollview_auto_mouse = 0
end

return M
