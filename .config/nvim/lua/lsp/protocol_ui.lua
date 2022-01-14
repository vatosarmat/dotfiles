local M = {}

M.severities = {
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

M.symbol_icons = {
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
  Object = '',
  Struct = '',
  Enum = 'ﴰ',
  EnumMember = '喝',
  TypeParameter = 'T',
  Module = '',

  has_children = '契'
}

function M.setup()
  for _, sev in ipairs(M.severities) do
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
