local function setup()
  local api = vim.api
  local set = vim.keymap.set

  vim.fn['operator#sandwich#set']('all', 'all', 'hi_duration', 0)

  -- Among others, adds recipes for: spaces, new lines
  vim.cmd([[runtime macros/sandwich/keymap/surround.vim]])

  set('x', '<C-s>', '<Plug>(sandwich-add)')

  local shortcut = { '\'', '"', '$', '(', '{', '`' }
  for _, q in ipairs(shortcut) do
    set('x', q, '<Plug>(sandwich-add)' .. q)
  end

  local shortcut_m = { '[', 't', 'f', 'g', 'p', '>' }
  for _, q in ipairs(shortcut_m) do
    set('x', '<M-' .. q .. '>', '<Plug>(sandwich-add)' .. q)
  end

  vim.g['sandwich#recipes'] = vim.list_extend(vim.g['sandwich#recipes'], {
    {
      buns = { '${', '}' },
      input = { '$' }
    }
  })

  -- %() - non-capturing group in Vim regexps, \h - [A-Za-z_], \w - [0-9A-Za-z_]
  -- vim.g['sandwich#magicchar#f#patterns'] = vim.list_extend(vim.g['sandwich#magicchar#f#patterns'], {
  --   {
  --     header = [[\<\%(\h\k*\.\)*\h\k*]],
  --     bra = '(',
  --     ket = ')',
  --     footer = ''
  --   }
  -- })
  vim.g['sandwich#magicchar#f#patterns'] = {
    {
      header = [[\<\%(\h\k*\.\)*\h\k*]],
      bra = '(',
      ket = ')',
      footer = ''
    }
  }

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
  api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'typescript', 'typescriptreact' },
    desc = 'Setup sandwich recipes for typescript',
    callback = function()
      vim.fn['sandwich#util#addlocal']({
        {
          buns = { 'Promise<', '>' },
          input = { 'p' }
        },
        {
          buns = { 'sandwich#magicchar#f#fname("<")', '">"' },
          kind = { 'add', 'replace' },
          action = { 'add' },
          expr = 1,
          input = { 'g' }
        }
      })
    end
  })

end

setup()
