local M = {}

function M.Comment()
  require('Comment').setup({
    pre_hook = function(ctx)
      -- Only calculate commentstring for tsx filetypes
      if vim.bo.filetype == 'typescriptreact' then
        local U = require('Comment.utils')

        -- Determine whether to use linewise or blockwise commentstring
        local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'

        -- Determine the location where to calculate commentstring from
        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require('ts_context_commentstring.utils').get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require('ts_context_commentstring.utils').get_visual_start_location()
        end

        return require('ts_context_commentstring.internal').calculate_commentstring({
          key = type,
          location = location
        })
      end
    end
  })
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
  map('nxo', 'S', 'gE', opts)
end

function M.scrollview()
  vim.g.scrollview_on_startup = 1
  vim.g.scrollview_winblend = 60
  vim.g.scrollview_column = 1
  vim.g.scrollview_auto_mouse = 0
end

return M
