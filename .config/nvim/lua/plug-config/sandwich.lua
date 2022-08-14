local function setup()
  local api = vim.api
  local set = vim.keymap.set

  vim.fn['operator#sandwich#set']('all', 'all', 'hi_duration', 0)
  vim.cmd([[runtime macros/sandwich/keymap/surround.vim]])

  set('x', '<C-s>', '<Plug>(sandwich-add)')

  local shortcut = { '\'', '(', '{', '`' }
  for _, q in ipairs(shortcut) do
    set('x', q, '<Plug>(sandwich-add)' .. q)
  end

  local shortcut_m = { '"', '[', 't', 'f' }
  for _, q in ipairs(shortcut_m) do
    set('x', '<M-' .. q .. '>', '<Plug>(sandwich-add)' .. q)
  end

  local augroup = api.nvim_create_augroup('Sandwich', {})
  api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'typescriptreact', 'javascriptreact' },
    desc = 'Setup sandwich recipes for React',
    callback = function()
      vim.fn['sandwich#util#addlocal']({
        {
          buns = { '<>', '</>' },
          input = { '<' }
        }
      })
    end
  })

end

setup()
