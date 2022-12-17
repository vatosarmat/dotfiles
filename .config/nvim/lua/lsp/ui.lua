local M = {}

M.severity = {
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

M.symbol = {
  -- Function-like
  Function = {
    icon = 'F',
    hl_icon = 'SymbolIconFunction',
    hl_name = '@function',
    hl_detail = '@type'
  },
  Method = {
    icon = 'M',
    hl_icon = 'SymbolIconFunction',
    hl_name = '@method',
    hl_detail = '@type'
  },
  Constructor = {
    icon = '',
    hl_icon = 'SymbolIconFunction',
    hl_name = '@constructor',
    hl_detail = '@type'
  },

  -- Value-like
  Variable = {
    icon = 'V',
    hl_icon = 'SymbolIconVariable',
    hl_name = '@variable',
    hl_detail = '@type'
  },
  Constant = {
    icon = 'C',
    hl_icon = 'SymbolIconVariable',
    hl_name = '@variable',
    hl_detail = '@type'
  },
  Property = {
    icon = 'P',
    hl_icon = 'SymbolIconVariable',
    hl_name = '@property',
    hl_detail = '@type'
  },
  Field = {
    icon = '',
    hl_icon = 'SymbolIconVariable',
    hl_name = '@property',
    hl_detail = '@type'
  },
  EnumMember = {
    icon = '喝',
    hl_icon = 'SymbolIconVariable',
    hl_name = '@property',
    hl_detail = '@property'
  },

  -- Value-like
  Module = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@include'
  },
  Namespace = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@namespace'
  },
  Interface = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },
  Class = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },
  Struct = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },
  Object = {
    icon = '',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },
  Enum = {
    icon = 'ﴰ',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },
  TypeParameter = {
    icon = 'T',
    hl_icon = 'SymbolIconClass',
    hl_name = '@type'
  },

  has_children = {
    icon = '契'
  }
}

function M.setup()
  for _, sev in ipairs(M.severity) do
    vim.fn.sign_define(sev.hl_sign, {
      texthl = sev.hl_sign,
      text = sev.sign,
      numhl = sev.hl_sign
    })
  end
end

function M.severity_lsp_to_vim(severity)
  if type(severity) == 'string' then
    severity = vim.lsp.protocol.DiagnosticSeverity[severity]
  end
  return severity
end

function M.severity_vim_to_lsp(severity)
  if type(severity) == 'string' then
    severity = vim.diagnostic.severity[severity]
  end
  return severity
end

return M
