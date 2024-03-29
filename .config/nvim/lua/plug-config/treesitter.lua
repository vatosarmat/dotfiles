local b = require('utils').b
local utils = require 'utils'
local ts_configs = require 'nvim-treesitter.configs'
-- local styled_components = require 'plug-config.styled_components'
local keymap = vim.keymap

-- styled_components.directives()

local function setup_textobject()
  local ret = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- ['as'] = '@statement.outer',
        -- ['ac'] = '@class.outer',
        -- ['ic'] = '@class.inner'
      },
    },
    move = {
      enable = true,
      set_jumps = false, -- whether to set jumps in the jumplist
      goto_next_start = {
        -- [')'] = '@statement.outer'
        -- [']]'] = '@class.outer'
      },
      goto_next_end = {
        -- ['<M-)>'] = '@statement.outer'
        -- [']['] = '@class.outer'
      },
      goto_previous_start = {
        -- ['('] = '@statement.outer'
        -- ['[['] = '@class.outer'
      },
      goto_previous_end = {
        -- ['<M-(>'] = '@statement.outer'
        -- ['[]'] = '@class.outer'
      },
    },
    -- lsp_interop = {
    --   enable = true,
    --   border = 'none',
    --   peek_definition_code = {
    --     ['<M-j>'] = '@function.outer'
    --   }
    -- }
  }
  local select_maps = ret.select.keymaps
  local moves = ret.move

  local inner_outer = {
    f = 'function',
    c = 'call',
    a = 'parameter',
    k = 'block',
    i = 'conditional',
    l = 'loop',
  }
  for letter, obj in pairs(inner_outer) do
    local outer = '@' .. obj .. '.outer'
    local inner = '@' .. obj .. '.inner'
    select_maps['a' .. letter] = outer
    select_maps['i' .. letter] = inner
    moves.goto_next_start[']' .. letter] = outer
    moves.goto_next_end[string.format(']<M-%s>', letter)] = outer
    moves.goto_previous_start['[' .. letter] = outer
    moves.goto_previous_end[string.format('[<M-%s>', letter)] = outer
  end

  return ret
end

ts_configs.setup {
  ensure_installed = 'all',
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  highlight = {
    enable = true,
    disable = {},

    -- additional_vim_regex_highlighting = true,
  },
  indent = { enable = true },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
  },
  rainbow = {
    enable = false,
    extended_mode = false,
    colors = {
      '#abb2bf',
      '#d79921',
      '#b16286',
      '#cc241d',
      '#ffffff',
      -- '#a89984',
      '#539d55',
      -- '#458588',
      '#d65d0e',
    },
  },
  refactor = {
    highlight_definitions = {
      enable = true,
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'm',
      node_incremental = 'm',
      node_decremental = '<Home>',
      scope_incremental = 'M',
    },
  },
  textobjects = setup_textobject(),
  autotag = {
    enable = true,
  },
  matchup = {
    enable = true,
    include_match_words = true,
  },
}
local filetype_to_parsername = require('nvim-treesitter.parsers').filetype_to_parsername
-- filetype_to_parsername.javascript = 'tsx'
-- filetype_to_parsername.jsonc = 'json'
-- filetype_to_parsername.blade = 'vue'
-- filetype_to_parsername.ejs = 'embedded_template'
keymap.set('n', '<leader>tp', '<cmd>TSPlaygroundToggle<cr>')
-- keymap.set('n', '<leader>tl', function()
--   _G._U.ts_inc_sel_injected = not _G._U.ts_inc_sel_injected
--   print('ts_inc_sel_injected ' .. tostring(_G._U.ts_inc_sel_injected))
-- end)

-- styled_components.queries()
--
--
--
local ts_utils = require 'nvim-treesitter.ts_utils'
local ts_indent = require 'nvim-treesitter.indent'

local function package_webpage()
  local cache_file = vim.fn.stdpath 'cache' .. '/package_webpage.txt'
  local p = vim.g.project
  if p.package_webpage then
    local maybe_package = vim.treesitter.get_node_text(ts_utils.get_node_at_cursor(0), 0)
    _, maybe_package = maybe_package:match '^%s*([\'"]?)(.*%S)%1'
    local uri = string.gsub(p.package_webpage, '%${package}', maybe_package)

    local good_uri = false
    local query_cache_cmd = string.format('grep -Fqsx %s %s', uri, cache_file)
    if os.execute(query_cache_cmd) ~= 0 then
      local test_uri_cmd =
        string.format('test "$(curl -Ls -o /dev/null -w "%%{http_code}" %s)" = "200"', uri)
      if os.execute(test_uri_cmd) == 0 then
        vim.fn.writefile({ uri }, cache_file, 'a')
        good_uri = true
      end
    else
      good_uri = true
    end

    if good_uri then
      os.execute('xdg-open ' .. uri .. ' 2>/dev/null')
    else
      vim.fn['utils#Warning'](
        { maybe_package, 'LspDiagnosticsSignInformation' },
        ' webpage doesn\'t exist'
      )
    end
  else
    vim.fn['utils#Warning'](
      { 'package_webpage', 'LspDiagnosticsSignInformation' },
      ' is not available for project type ',
      { p.kind, 'LspDiagnosticsSignInformation' }
    )
  end
end

keymap.set('n', '<leader>np', package_webpage)

--
--
--
local neogen = require 'neogen'
neogen.setup {
  snippet_engine = 'luasnip',
  placeholders_hl = 'None',
}

keymap.set(
  'n',
  '<leader>af',
  b(neogen.generate, {
    type = 'func',
  })
)
keymap.set(
  'n',
  '<leader>ac',
  b(neogen.generate, {
    type = 'class',
  })
)
keymap.set(
  'n',
  '<leader>at',
  b(neogen.generate, {
    type = 'type',
  })
)
keymap.set(
  'n',
  '<leader>aF',
  b(neogen.generate, {
    type = 'file',
  })
)
