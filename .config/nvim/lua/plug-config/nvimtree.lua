local map = require('vim_utils').map

local function default_mappings(api, opts)
  local set = vim.keymap.set

  set('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
  set('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
  set('n', '<C-k>', api.node.show_info_popup, opts 'Info')
  set('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
  set('n', '<C-t>', api.node.open.tab, opts 'Open: New Tab')
  set('n', '<C-v>', api.node.open.vertical, opts 'Open: Vertical Split')
  set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
  set('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
  set('n', '<CR>', api.node.open.edit, opts 'Open')
  set('n', '<Tab>', api.node.open.preview, opts 'Open Preview')
  set('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
  set('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
  set('n', '.', api.node.run.cmd, opts 'Run Command')
  set('n', '-', api.tree.change_root_to_parent, opts 'Up')
  set('n', 'a', api.fs.create, opts 'Create')
  set('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
  set('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle No Buffer')
  set('n', 'c', api.fs.copy.node, opts 'Copy')
  set('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Git Clean')
  set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
  set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
  set('n', 'd', api.fs.remove, opts 'Delete')
  set('n', 'D', api.fs.trash, opts 'Trash')
  set('n', 'E', api.tree.expand_all, opts 'Expand All')
  set('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
  set('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
  set('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
  set('n', 'F', api.live_filter.clear, opts 'Clean Filter')
  set('n', 'f', api.live_filter.start, opts 'Filter')
  set('n', 'g?', api.tree.toggle_help, opts 'Help')
  set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
  set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Dotfiles')
  set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Git Ignore')
  set('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
  set('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
  set('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
  set('n', 'o', api.node.open.edit, opts 'Open')
  set('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
  set('n', 'p', api.fs.paste, opts 'Paste')
  set('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
  set('n', 'q', api.tree.close, opts 'Close')
  set('n', 'r', api.fs.rename, opts 'Rename')
  set('n', 'R', api.tree.reload, opts 'Refresh')
  set('n', 's', api.node.run.system, opts 'Run System')
  set('n', 'S', api.tree.search_node, opts 'Search')
  set('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Hidden')
  set('n', 'W', api.tree.collapse_all, opts 'Collapse')
  set('n', 'x', api.fs.cut, opts 'Cut')
  set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
  set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
  set('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
  set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')
end

local function on_attach(bufnr)
  local api = require 'nvim-tree.api'

  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  default_mappings(api, opts)

  -- Mappings migrated from view.mappings.list
  --
  -- You will need to insert "your code goes here" for any mappings with a custom action_cb
  vim.keymap.set('n', 'f', api.node.open.preview, opts 'Open Preview')
  vim.keymap.set('n', '<C-f>', api.live_filter.start, opts 'Filter')
  vim.keymap.set('n', '<C-l>', api.node.open.vertical, opts 'Open: Vertical Split')
end

require('nvim-tree').setup {
  on_attach = on_attach,
  disable_netrw = true,
  hijack_netrw = true,

  -- open_on_setup = false,
  -- ignore_ft_on_setup = {},
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
      error = '',
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  system_open = {
    cmd = nil,
    args = {},
  },
  view = {
    width = {
      min = 20,
    },
    side = 'left',
    -- must be true to avoid wincmd =
    preserve_window_proportions = true,
  },
  git = {
    ignore = false,
  },
  actions = {
    open_file = {
      resize_window = false,
    },
  },
  filters = {
    custom = { '__pycache__', [[^\.null-ls_\.*]] },
  },
  notify = {
    threshold = vim.log.levels.WARN,
  },
  renderer = {
    root_folder_modifier = ':t',
    group_empty = false,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
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
          ignored = '◌',
        },
        folder = {
          arrow_open = '',
          arrow_closed = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
      },
    },
  },
}

map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
map('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>')
