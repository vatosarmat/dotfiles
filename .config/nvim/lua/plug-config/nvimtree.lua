local map = require'vim_utils'.map

require'nvim-tree'.setup {
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {},
  -- update_to_buf_dir = {
  --   enable = true,
  --   auto_open = true
  -- },
  open_on_tab = false,
  hijack_cursor = false,
  update_cwd = false,
  diagnostics = {
    enable = true,
    icons = {
      hint = '',
      info = '',
      warning = '',
      error = ''
    }
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {}
  },
  system_open = {
    cmd = nil,
    args = {}
  },
  view = {
    width = function()
      local p = vim.g.project
      if p then
        return p.explorer_width
      end
      return 30
    end,
    side = 'left',
    -- auto_resize = false,
    mappings = {
      custom_only = false,
      list = {}
    }
  },
  git = {
    ignore = false
  },
  filters = {
    -- custom = { '__pycache__' }
  },
  renderer = {
    root_folder_modifier = ':t',
    group_empty = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true
      },
      glyphs = {
        default = '',
        symlink = '',
        git = {
          unstaged = '✗',
          staged = '✓',
          unmerged = '',
          renamed = '➜',
          untracked = '★',
          deleted = '',
          ignored = '◌'
        },
        folder = {
          arrow_open = '',
          arrow_closed = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = ''
        }
      }
    }
  }
}

map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
map('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>')
