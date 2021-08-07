local map = require'before-plug.vim_utils'.map

vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_root_folder_modifier = ':t'

vim.g.nvim_tree_show_icons = {
  git = 1,
  folders = 1,
  files = 1,
  folder_arrows = 1
}

vim.g.nvim_tree_icons = {
  default = '',
  symlink = '',
  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★",
    deleted = "",
    ignored = "◌"
  },
  folder = {
    arrow_open = "",
    arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = ""
  },
  lsp = { hint = "", info = "", warning = "", error = "" }
}

vim.g.nvim_tree_special_files = {}

map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')