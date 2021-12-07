local lsp = vim.lsp

local severities = {
  {
    name = 'Error',
    sign = '',
    hl_sign = 'DiagnosticSignError',
    hl_float = 'DiagnosticFloatingError',
    hl_virt = 'DiagnosticVirtualTextError'
  },
  {
    name = 'Warning',
    sign = '',
    hl_sign = 'DiagnosticSignWarn',
    hl_float = 'DiagnosticFloatingWarn',
    hl_virt = 'DiagnosticVirtualTextWarn'
  },
  {
    name = 'Information',
    sign = '',
    hl_sign = 'DiagnosticSignInfo',
    hl_float = 'DiagnosticFloatingInfo',
    hl_virt = 'DiagnosticVirtualTextInfo'
  },
  {
    name = 'Hint',
    sign = '',
    hl_sign = 'DiagnosticSignHint',
    hl_float = 'DiagnosticFloatingHint',
    hl_virt = 'DiagnosticVirtualTextHint'
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
  vim.fn.sign_define(sev.hl_sign, {
    texthl = sev.hl_sign,
    text = sev.sign,
    numhl = sev.hl_sign
  })
end

lsp.protocol.CompletionItemKind = {
  ' ',
  symbol_icons.Method,
  symbol_icons.Function,
  symbol_icons.Constructor,
  symbol_icons.Field,
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
