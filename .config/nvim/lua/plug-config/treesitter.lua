local ts_configs = require 'nvim-treesitter.configs'

function setup_textobject()
  local ret = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- ['as'] = '@statement.outer',
        -- ['ac'] = '@class.outer',
        -- ['ic'] = '@class.inner'
      }
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
      }
    }
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
    b = 'block',
    i = 'conditional',
    l = 'loop'
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
    enable_autocmd = false
  },
  highlight = {
    enable = true,
    disable = { 'help', 'markdown' } -- list of language that will be disabled
  },
  indent = {
    enable = true,
    disable = { 'lua', 'ruby' }
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
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
      '#d65d0e'
    }
  },
  refactor = {
    highlight_definitions = {
      enable = true
    }
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'm',
      node_incremental = 'm',
      node_decremental = '<Home>',
      scope_incremental = 'M'
    }
  },
  textobjects = setup_textobject(),
  autotag = {
    enable = true
  },
  matchup = {
    enable = true,
    include_match_words = true
  }
}
local filetype_to_parsername = require'nvim-treesitter.parsers'.filetype_to_parsername
filetype_to_parsername.javascript = 'tsx'
filetype_to_parsername.jsonc = 'json'

require('nvim-treesitter.highlight').set_custom_captures {
  ['punctuation.quote'] = 'UPunctQuote',
  -- ['jsx.expression.brace'] = 'JsxExpressionBrace',
  ['ecma.formal_parameters.brace'] = 'UDeclarationBrace',
  ['ecma.object.brace'] = 'UDeclarationBrace',
  ['ecma.object_pattern.brace'] = 'UPatternBrace',
  ['ecma.array_pattern.brace'] = 'UPatternBrace',
  ['ecma.arguments.brace'] = 'UCallBrace',
  ['ecma.subscript.brace'] = 'USubscriptBrace'
}

--
--
--
local ts_utils = require 'nvim-treesitter.ts_utils'
local map = require('vim_utils').map

local function package_webpage()
  local cache_file = vim.fn.stdpath('cache') .. '/package_webpage.txt'
  local p = vim.g.project
  if p.package_webpage then
    local maybe_package = vim.treesitter.query.get_node_text(ts_utils.get_node_at_cursor(0), 0)
    _, maybe_package = maybe_package:match '^%s*([\'"]?)(.*%S)%1'
    local uri = string.gsub(p.package_webpage, '%${package}', maybe_package)

    local good_uri = false
    local query_cache_cmd = string.format('grep -Fqsx %s %s', uri, cache_file)
    if os.execute(query_cache_cmd) ~= 0 then
      local test_uri_cmd = string.format(
                             'test "$(curl -Ls -o /dev/null -w "%%{http_code}" %s)" = "200"', uri)
      if os.execute(test_uri_cmd) == 0 then
        vim.fn.writefile({ uri }, cache_file, 'a')
        good_uri = true
      end
    else
      good_uri = true
    end

    if good_uri then
      os.execute('xdg-open ' .. uri)
    else
      vim.fn['utils#Warning']({ maybe_package, 'LspDiagnosticsSignInformation' },
                              ' webpage doesn\'t exist')
    end
  else
    vim.fn['utils#Warning']({ 'package_webpage', 'LspDiagnosticsSignInformation' },
                            ' is not available for project type ',
                            { p.kind, 'LspDiagnosticsSignInformation' })
  end
end

map('n', '<leader>np', package_webpage)
