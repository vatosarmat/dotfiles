local client_ext = {
  ['shellcheck'] = {
    kind = 'linter',
    short_name = 'SC',
    diagnostic_disable_line = '#shellcheck disable=${code}',
    diagnostic_webpage = 'https://github.com/koalaman/shellcheck/wiki/SC${code}'
  }, -- ['clang-tidy'] = { kind = 'linter', short_name = 'CT' },
  ['cppcheck'] = {
    kind = 'linter',
    short_name = 'CC'
  },
  ['clangd'] = {
    short_name = 'CD'
  },
  ['sumneko_lua'] = {
    short_name = 'SL',
    diagnostic_disable_line = '---@diagnostic disable-next-line: ${code}'
  },
  ['rust_analyzer'] = {
    short_name = 'RA'
  },
  ['tsserver'] = {
    short_name = 'TS'
  },
  ['typescript'] = {
    short_name = 'TS'
  },
  ['eslint'] = {
    short_name = 'ES',
    diagnostic_disable_line = '//eslint-disable-next-line ${code}',
    diagnostic_webpage = function(diagnostic)
      return diagnostic.codeDescription.href
    end
  }
}

client_ext['Lua Diagnostics.'] = client_ext['sumneko_lua']

setmetatable(client_ext, {
  __index = function(tbl, key)
    local v = rawget(tbl, key)
    if not v then
      v = {}
      rawset(tbl, key, v)
    end
    return v
  end
})

return client_ext
