local gs = require 'gitsigns'

local function withIndexBufUpdate(f)
  return function()
    f()
    -- was intended for 3-diff view upate, but seems to be broken
    -- local back = vim.fn.win_getid()
    -- local indexBufname = vim.fn.FugitiveFind(':' .. vim.fn.bufname())
    -- if vim.fn.bufexists(indexBufname) then
    --   vim.fn.win_gotoid(vim.fn.bufwinid(indexBufname))
    --   vim.cmd('e ' .. indexBufname)
    --   vim.fn.win_gotoid(back)
    -- end
  end
end

local function with_nz(hunk)
  return function()
    hunk()
    if vim.g.UOPTS.nz then
      vim.cmd('normal! zz')
    end
  end
end

local _gitsigns = {}

_gitsigns.stage_hunk = withIndexBufUpdate(gs.stage_hunk)
_gitsigns.undo_stage_hunk = withIndexBufUpdate(gs.undo_stage_hunk)
_gitsigns.next_hunk = with_nz(gs.next_hunk)
_gitsigns.prev_hunk = with_nz(gs.prev_hunk)
_G._gitsigns = _gitsigns

gs.setup {
  -- signs = {
  --   add          = {hl = 'GitSignsAdd'   , text = ' +', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
  --   change       = {hl = 'GitSignsChange', text = ' │', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  --   delete       = {hl = 'GitSignsDelete', text = ' -', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
  --   topdelete    = {hl = 'GitSignsDelete', text = ' ‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
  --   changedelete = {hl = 'GitSignsChange', text = ' ~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},

  update_debounce = 500,
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

    ['n ]h'] = {
      expr = true,
      '&diff ? \']c\' : \'<cmd>lua _gitsigns.next_hunk()<CR>\''
    },
    ['n [h'] = {
      expr = true,
      '&diff ? \'[c\' : \'<cmd>lua _gitsigns.prev_hunk()<CR>\''
    },

    ['n <leader>hs'] = '<cmd>lua _gitsigns.stage_hunk()<CR>',
    ['n <leader>hu'] = '<cmd>lua _gitsigns.undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
  }
}
