local lsp = vim.lsp

local severities = {
  {
    name = 'Error',
    sign_name = 'DiagnosticSignError',
    sign = '',
    hl_sign = 'LspDiagnosticsSignError',
    hl_float = 'LspDiagnosticsFloatingError'
  },
  {
    name = 'Warning',
    sign_name = 'DiagnosticSignWarn',
    sign = '',
    hl_sign = 'LspDiagnosticsSignWarning',
    hl_float = 'LspDiagnosticsFloatingWarning'
  },
  {
    name = 'Information',
    sign_name = 'DiagnosticSignInfo',
    sign = '',
    hl_sign = 'LspDiagnosticsSignInformation',
    hl_float = 'LspDiagnosticsFloatingInformation'
  },
  {
    name = 'Hint',
    sign_name = 'DiagnosticSignHint',
    sign = '',
    hl_sign = 'LspDiagnosticsSignHint',
    hl_float = 'LspDiagnosticsFloatingHint'
  }
}

local symbol_icons = {
  Function = 'F',
  Method = 'M',
  Variable = 'V',
  Constant = 'C',
  Property = 'P',
  Field = '',
  Namespace = '',
  Interface = '',
  Constructor = '',
  Class = '',
  Struct = '',
  Enum = 'ﴰ',
  EnumMember = '喝'
}

for _, sev in ipairs(severities) do
  vim.fn.sign_define(sev.sign_name, {
    texthl = sev.hl_sign,
    text = sev.sign,
    numhl = sev.hl_sign
  })
end

lsp.protocol.CompletionItemKind = {
  ' ',
  ' ',
  symbol_icons.Function,
  ' ',
  'ﰠ ',
  symbol_icons.Variable,
  symbol_icons.Class,
  symbol_icons.Interface,
  ' ',
  symbol_icons.Property,
  ' ',
  ' ',
  symbol_icons.Enum,
  ' ',
  '﬌ ',
  ' ',
  ' ',
  ' ',
  ' ',
  symbol_icons.EnumMember,
  symbol_icons.Constant,
  symbol_icons.Struct,
  '⌘ ',
  ' ',
  ' '
}

return {
  severities = severities,
  symbol_icons = symbol_icons
}
