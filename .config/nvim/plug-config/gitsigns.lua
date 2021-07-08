local gs = require 'gitsigns'

local pcgs = {}

function pcgs.setup()
  gs.setup {
    -- signs = {
    --   add          = {hl = 'GitSignsAdd'   , text = ' +', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    --   change       = {hl = 'GitSignsChange', text = ' │', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    --   delete       = {hl = 'GitSignsDelete', text = ' -', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    --   topdelete    = {hl = 'GitSignsDelete', text = ' ‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    --   changedelete = {hl = 'GitSignsChange', text = ' ~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},

    signs = {
      add = {
        hl = 'GitSignsAdd',
        text = ' ┃',
        numhl = 'GitSignsAddNr',
        linehl = 'GitSignsAddLn'
      },
      change = {
        hl = 'GitSignsChange',
        text = ' ┃',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn'
      },
      delete = {
        hl = 'GitSignsDelete',
        text = ' ▸',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn'
      },
      topdelete = {
        hl = 'GitSignsDelete',
        text = ' ▼',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn'
      },
      changedelete = {
        hl = 'GitSignsChange',
        text = ' ▸',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn'
      }
    },
    -- keymaps = {
    --   -- Default keymap options
    --   noremap = true,
    --   buffer = true,

    --   ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
    --   ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

    --   ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    --   ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    --   ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    --   ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    --   ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    --   ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

    --   -- Text objects
    --   ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
    --   ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
    -- },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ['n ]c'] = {
        expr = true,
        "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"
      },
      ['n [c'] = {
        expr = true,
        "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"
      },

      ['n <leader>hs'] = '<cmd>lua require"plug-config.gitsigns".stage_hunk()<CR>',
      ['n <leader>hu'] = '<cmd>lua require"plug-config.gitsigns".undo_stage_hunk()<CR>',
      ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
      ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

      -- Text objects
      ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
      ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
    }
  }
end

local function withIndexBufUpdate(f)
  return function()
    f()
    local indexBufname = vim.fn.FugitiveFind(':' .. vim.fn.bufname())
    if vim.fn.bufexists(indexBufname) then
      vim.fn.win_gotoid(vim.fn.bufwinid(indexBufname))
      vim.cmd('e ' .. indexBufname)
      -- vim.wait(100, function() end)
      -- vim.fn.win_gotoid(b)
    end
  end
end

pcgs.stage_hunk = withIndexBufUpdate(gs.stage_hunk)
pcgs.undo_stage_hunk = withIndexBufUpdate(gs.undo_stage_hunk)

return pcgs
