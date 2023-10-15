local M = {}

function M.Comment()
  local set = vim.keymap.set

  require('Comment').setup {
    pre_hook = function(ctx)
      -- Only calculate commentstring for tsx filetypes
      if vim.bo.filetype == 'typescriptreact' then
        local U = require 'Comment.utils'

        -- Determine whether to use linewise or blockwise commentstring
        local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'

        -- Determine the location where to calculate commentstring from
        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require('ts_context_commentstring.utils').get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require('ts_context_commentstring.utils').get_visual_start_location()
        end

        return require('ts_context_commentstring.internal').calculate_commentstring {
          key = type,
          location = location,
        }
      end
    end,
  }
  set('n', '<C-_>', '<Plug>(comment_toggle_linewise_current)')
  set('x', '<C-_>', '<Plug>(comment_toggle_linewise_visual)')
end

function M.asterisk()
  local map = require('vim_utils').map
  local opts = {
    noremap = false,
  }
  map('nxo', '*', '<Plug>(asterisk-z*)', opts)
  map('nxo', '#', '<Plug>(asterisk-z#)', opts)
  map('nxo', 'g*', '<Plug>(asterisk-gz*)', opts)
  map('nxo', 'g#', '<Plug>(asterisk-gz#)', opts)
end

M.wordmotion = {
  init = function()
    vim.g.wordmotion_nomap = 1
    vim.g.wordmotion_uppercase_spaces = { '[^[:keyword:]]' }
  end,
  config = function()
    local map = require('vim_utils').map
    local opts = {
      noremap = false,
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
  end,
}

M.emmet = {
  init = function()
    -- <Home> is C-m
    local set = vim.keymap.set

    set('i', '<Home>', '<Nop>')
    vim.g.user_emmet_leader_key = '<Home>'
    vim.g.user_emmet_complete_tag = nil
    vim.g.user_emmet_mode = 'i'
    vim.g.user_emmet_expandabbr_key = '<Home><Home>'
  end,
  config = function() end,
}

M.matchup = {
  init = function()
    vim.g.matchup_matchparen_offscreen = vim.empty_dict()
    vim.g.matchup_surround_enabled = false
    vim.g.matchup_transmute_enabled = false
    vim.g.matchup_motion_keepjumps = true
  end,
  config = function()
    local set = vim.keymap.set
    set({ 'n', 'x', 'o' }, '<M-%>', '<plug>(matchup-g%)')
  end,
}

M.scrollview = {
  init = function()
    vim.g.scrollview_on_startup = 1
    vim.g.scrollview_winblend = 60
    vim.g.scrollview_column = 1
    vim.g.scrollview_auto_mouse = 0
  end,
  config = function() end,
}

return M
