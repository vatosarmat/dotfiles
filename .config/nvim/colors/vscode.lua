local Colorscheme_utils = require 'vim_utils.colorscheme'

local function expand_diagnostic(diagnostic_table)
  local ret = {}
  for severity, kinds in pairs(diagnostic_table) do
    for kind, color in pairs(kinds) do
      local group = string.format('Diagnostic%s%s', kind, severity)
      if vim.startswith(color, '#') then
        ret[group] = {
          fg = color
        }
      else
        -- color is actual kind, e.g. Floating = 'Sign'
        ret[group] = {
          link = string.format('Diagnostic%s%s', color, severity)
        }
      end
    end
    ret[string.format('Diagnostic%s', severity)] = {
      link = string.format('DiagnosticSign%s', severity)
    }
  end
  return ret
end

local fg = Colorscheme_utils.fg
local bg = Colorscheme_utils.bg

local function make_colorscheme()
  -- Palette formed from various known colorschemes + my own Self nd Brace
  local P = {
    Vscode = {
      comment = '#608b4e',
      keyword = '#569cd6',
      keyword2 = '#c586c0',
      variable = '#9cdcfe',
      ['function'] = '#dcdcaa',
      number = '#b5cea8',
      string = '#ce9178',
      char = '#d7ba7d',
      type = '#4ec9b0',
      saturated_blue = '#4fc1ff',
      red = '#d16969'
    },
    Alacritty = {
      normal = {
        -- Vscode.red-like
        red = '#cc6666',
        -- Number-like
        green = '#b5bd68',
        -- Duplicates Darcula.gold
        yellow = '#f0c674',
        -- weak and Keyword-like
        blue = '#81a2be',
        -- weak and Keyword2-like
        magenta = '#b294bb',
        -- weak
        cyan = '#8abeb7'
      },
      bright = {
        -- Vscode.red-like
        red = '#d54e53',
        --
        green = '#b9ca4a',
        --
        yellow = '#e7c547',
        -- Keyword-like
        blue = '#7aa6da',
        -- Keyword2-like
        magenta = '#c397d8',
        -- Type-like
        cyan = '#70c0b1'
      }
      -- Dim has too low contrast with background
    },
    Darcula = {
      -- [0] = '#6796e6',
      -- [1] = '#6a8759',
      -- [2] = '#707070',
      -- [3] = '#7a9ec2',
      -- [4] = '#9e7bb0',
      -- [5] = '#a5c261',
      -- [6] = '#b267e6',
      -- [7] = '#cc8242',
      -- [8] = '#cccccc',
      -- [9] = '#cd9731',
      -- [10] = '#f44747',
      -- [11] = '#ffc66d'
      -- ['keyword'] = '#6796e6',
      -- ['comment'] = '#6a8759',
      ['weak'] = '#7a9ec2',
      ['pudark'] = '#9e7bb0',
      ['green'] = '#a5c261',
      ['purple'] = '#b267e6',
      ['brown'] = '#cc8242',
      ['gold'] = '#cd9731',
      ['red'] = '#f44747',
      ['orange'] = '#ffc66d'
    },
    Winter = {
      -- '#00bff9',
      -- '#4fb4d8',
      -- '#57cdff',
      -- '#5abeb0',
      -- '#6bff81',
      -- '#6dbdfa',
      -- '#78bd65',
      -- '#7fdbca',
      -- '#80cbc4',
      -- '#82aaff', --
      -- '#87aff4', --
      -- '#8dec95',
      -- '#91dacd',
      -- '#92b6f4', --
      -- '#99d0f7',
      -- '#a170c6',
      -- ['215_weak'] = '#a1bde6' --
      -- '#a4ceee',
      -- '#addb67',
      -- '#bce7ff',
      -- '#bcf0c0',
      -- '#c63ed3',
      -- '#c792ea',
      -- '#cbcdd2',
      -- '#d29ffc',
      -- '#d3eed6',
      -- '#d6deeb',
      -- '#d7dbe0',
      -- '#e0aff5',
      -- '#ec9cd2',
      -- '#ece7cd',
      -- '#eeffff',
      -- '#f29fd8',
      -- '#f3b8c2',
      -- '#f7ecb5'
    },
    Nord = {
      '#5e81ac',
      '#616e88',
      '#81a1c1',
      '#88c0d0',
      '#8fbcbb',
      '#a3be8c',
      '#b48ead',
      '#bf616a',
      '#d08770',
      '#d8dee9',
      '#ebcb8b',
      '#eceff4'
    },
    OneDarkPro = {
      '#56b6c2',
      '#5c6370',
      '#61afef',
      '#7f848e',
      '#98c379',
      '#abb2bf',
      '#be5046',
      '#c678dd',
      '#d19a66',
      '#e06c75',
      '#e5c07b',
      '#f44747'
    },
    Self = {
      comment = '#777777',
      operator = '#e6d0d0',
      bracket = '#d0d0d0',
      property = '#83ccd2',
      constant = '#90c0fe'
    },
    Brace = {
      declaration = '#4bc3ff',
      -- call = '#c552c5',
      call = '#dc7c40',
      pattern = '#afff69'
    }
  }

  -- Actual colorscheme - highlight groups mapped to structures {fg,bg,italic,...}
  local C = {}

  -- Special
  -- Tag, SpecialChar, Delimiter, SpecialComment, Debug
  -- @: constant.builtin, function.builtin, constructor

  -- SpecialChar
  -- @: string.escape, string.special, character.special

  -- Constant
  -- String, Character, Number, Boolean
  -- @: constant

  local function common()
    -- Free
    -- Darcula.weak, Darcula.gold

    -- Syntax palette
    C.Vscode = fg(P.Vscode, 'Vscode_')
    C.Alac_norm = fg(P.Alacritty.normal, 'Alac_norm_')
    C.Alac_bright = fg(P.Alacritty.bright, 'Alac_bright_')
    C.Darcula = fg(P.Darcula, 'Darc_')
    C.Self = fg(P.Self, 'Self_')

    C.Syntax = fg {
      Comment = P.Self.comment,

      Keyword = P.Vscode.keyword,
      Keyword2 = P.Vscode.keyword2,
      Keyword3 = P.Darcula.pudark,

      Operator = P.Self.operator,
      Delimiter = 'Normal',
      Bracket = P.Self.bracket,

      Identifier = P.Vscode.variable,
      Constant = P.Self.constant,
      Function = P.Vscode['function'],
      ['@function.builtin'] = {
        fg = '&Function',
        italic = true
      },
      ['@variable.special'] = P.Vscode.comment,
      ['@variable.builtin'] = P.Vscode.saturated_blue,

      String = P.Vscode.string,
      Number = P.Vscode.number,
      SpecialChar = P.Vscode.char,
      ['@null'] = P.Vscode.red,
      ['@boolean'] = P.Darcula.brown,

      Type = P.Vscode.type,
      ['@property'] = P.Self.property,
      ['@constructor'] = P.Darcula.orange,

      --
      -- links
      --
      ['@punctuation.delimiter'] = 'Delimiter',
      ['@punctuation.bracket'] = 'Bracket',
      ['@punctuation.special'] = 'Bracket',

      Statement = 'Keyword',
      Include = 'Keyword3',
      Conditional = 'Keyword2',
      Repeat = 'Keyword2',
      Exception = 'Keyword2',
      PreProc = 'Keyword2',
      ['@keyword.return'] = 'Keyword2',

      Label = 'Identifier',
      ['@variable'] = 'Identifier',

      Special = '@null'
    }

    C.TextHihglight = bg {
      Visual = '#264f78',
      Search = '#613214',
      YankHighlight = '#1d3a3a',

      LspReferenceRead = '#304030',
      LspReferenceWrite = '#502842',

      LspReferenceText = 'QuickFixLine'
    }

    -- All(but Self.comment) grey shades here
    C.Ui = bg {
      Normal = {
        fg = '#abb2bf',
        bg = '#1e1e1e'
      },
      Title = {
        fg = '#e6eeff',
        bold = true
      },
      StatusLine = {
        fg = '&Normal/fg',
        bg = '#000000'
      },
      StatusLineNC = {
        fg = '#5c6370',
        bg = '#191919'
      },
      Pmenu = {
        fg = '&Title/fg',
        bg = '#282c34'
      },
      LineNr = {
        fg = '#858585'
      },
      WinSeparator = {
        fg = '#3a3a3a'
      },
      QuickFixLine = '#3e4452',
      CursorLine = '#2b2b2b',
      MatchParen = {
        underline = true
      },
      -- MatchWord = '',
      -- MatchWordCur = '',
      -- MatchParenCur = '',

      Error = 'DiagnosticFloatingError',
      ErrorMsg = 'Error',
      WarningMsg = 'DiagnosticFloatingWarn',
      TabLineFill = '&WinSeparator/fg',
      TabLine = 'StatusLineNC',
      TabLineSel = 'StatusLine',

      NonText = 'LineNr',

      CursorColumn = 'CursorLine',

      SignColumn = '&Normal/bg',

      ScrollView = '&StatusLine/bg',

      Directory = 'Keyword',

      PmenuSbar = 'Pmenu',
      PmenuThumb = '&Normal/fg',
      PmenuSel = {
        fg = '&Title/fg',
        bg = C.TextHihglight.Visual.bg
      },

      Folded = 'Normal',
      UfoFoldedBg = 'CursorLine'
    }

    C.NvimTree = fg({
      IndentMarker = 'Normal',
      FolderIcon = 'Keyword',
      RootFolder = 'Title',
      ExecFile = 'Function',
      SpecialFile = 'Keyword2',
      GitDirty = '@property',
      GitNew = 'NvimTreeGitDirty'
    }, 'NvimTree')

    -- Diagnostic
    C.Diagnostic = expand_diagnostic {
      Error = {
        VirtualText = '#a01212',
        Sign = '#f41d1d',
        Floating = '#f44747'
      },
      Warn = {
        VirtualText = '#a05200',
        Sign = '#ff8800',
        Floating = 'Sign'
      },
      Info = {
        VirtualText = '#276180',
        Sign = '#4fc1ff',
        Floating = 'Sign'
      },
      Hint = {
        VirtualText = '#278027',
        Sign = '#3bc03d',
        Floating = 'Sign'
      }
    }
    C.Diagnostic.SpellBad = {
      undercurl = true,
      sp = C.Diagnostic.DiagnosticSignInfo.fg
    }

    C.StatusLineDiagnostic = fg({
      User1 = C.Diagnostic.DiagnosticSignError.fg,
      User2 = C.Diagnostic.DiagnosticSignWarn.fg,
      User3 = C.Diagnostic.DiagnosticSignInfo.fg,
      User4 = C.Diagnostic.DiagnosticSignHint.fg
    }, nil, C.Ui.StatusLine.bg)

    -- Dap
    C.DapLine = bg({
      BreakpointLine = '#100010',
      StoppedLine = '#400040'
    }, 'Dap')

    C.DapSign = fg({
      BreakpointSign = '#d098f4',
      StoppedSign = '#9e1cf4'
    }, 'Dap')

    C.StatusLineDap = {
      User8 = {
        fg = C.DapSign.DapStoppedSign.fg,
        bg = C.Ui.StatusLine.bg
      }
    }

    --
    C.SymbolIcon = fg({
      Function = '#c0c000',
      Variable = '#0080c0',
      Class = '#008064'
    }, 'SymbolIcon')

    -- CmpItem
    C.CmpItemAbbr = fg({
      Deprecated = {
        strikethrough = true,
        fg = C.Ui.StatusLineNC.fg
      },
      Match = 'Keyword',
      MatchFuzzy = 'Identifier'
    }, 'CmpItemAbbr')

    C.CmpItemKind = fg({
      Variable = 'Identifier',
      Interface = 'Identifier',
      Text = 'Identifier',
      Function = 'Keyword2',
      Method = 'Keyword2',
      Keyword = C.Ui.Pmenu.fg,
      Property = C.Ui.Pmenu.fg,
      Unit = C.Ui.Pmenu.fg
    }, 'CmpItemKind')
  end

  local function git()
    C.Diff = bg({
      Add = '#151e00',
      Delete = '#101010',
      Change = '#01181e',
      Text = '#1e0000',
      ConflictMarker = {
        fg = C.Ui.StatusLine.bg,
        bg = C.Ui.LineNr.fg
      }
    }, 'Diff')

    C.StatusLineDiff = fg({
      User5 = '#727c5d',
      User6 = '#76959d',
      User7 = '#946f71'
    }, nil, C.Ui.StatusLine.bg)

    C.GitSigns = fg({
      Add = '#587c0c',
      Change = '#0c7d9d',
      Delete = '#94151b'
    }, 'GitSigns')

    C.Fugitive = fg({
      UnstagedModifier = P.Vscode.red,
      UntrackedModifier = P.Vscode.string
    }, 'fugitive')
  end

  local function help()
    C.Help = fg({
      Header = 'Function'
    }, 'help')
  end

  local function makrdown()
    C.Makrdown = fg {
      Tag = P.Darcula.green,
      htmlArg = '@property',
      ['@tag.attribute'] = '@property',
      ['@tag.delimiter'] = '@operator',
      ['@text.uri'] = P.Vscode.keyword2,
      ['@text.reference'] = P.Vscode.string,
      ['@text.title'] = 'Title',
      ['@text.title.h2'] = P.Vscode.saturated_blue,
      ['@text.title.h3'] = P.Vscode.comment,
      ['@text.literal'] = P.Darcula.brown,
      ['@text'] = 'Normal',

      ['@tag'] = 'Tag'
    }
  end

  local function ecma()
    C.Ecma = fg({
      ['object.brace'] = P.Brace.declaration,
      ['array.brace'] = P.Brace.declaration,
      ['formal_parameters.brace'] = P.Brace.declaration,
      ['object_pattern.brace'] = P.Brace.pattern,
      ['array_pattern.brace'] = P.Brace.pattern,
      ['subscript.brace'] = P.Brace.call,
      ['arguments.brace'] = P.Brace.call
    }, '@ecma.')
  end

  common()
  git()
  help()
  makrdown()
  ecma()

  return vim.tbl_extend('error', unpack(vim.tbl_values(C)))
end

local colorscheme = make_colorscheme()

_U.colorscheme = colorscheme

-- Colorscheme_utils.validate(colorscheme)
Colorscheme_utils.boilerplate('vscode')
Colorscheme_utils.set_hl(colorscheme)
