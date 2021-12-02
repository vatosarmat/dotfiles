local function tsserver_diagnostic_highlight(text, line)
  local type_hl_idx = 0
  local pats = {
    {
      [[[tT]ype '[^']+']],
      function()
        local ret = type_hl_idx % 2 == 0 and 'TSType' or 'TSKeyword'
        type_hl_idx = (type_hl_idx + 1) % 2
        return ret
      end
    },
    { [[[sS]ignature '[^']+']], const('TSInclude') },
    { [[[oO]verload %d of %d, '[^']+']], const('TSFunction') }
  }
  local rest = line
  local done = true
  while #rest > 0 do
    local q1, q2 = string.find(rest, [['[^']+']])

    -- found something in quotes
    if q1 then
      local quote_area = string.sub(rest, 0, q2)

      for _, pat in ipairs(pats) do
        local rexp, hl_func = unpack(pat)
        local _, e = string.find(quote_area, rexp)
        -- quote_area is one of interested pats
        if e == q2 then
          text:append(string.sub(rest, 0, q1)) -- prefix
          text:append(string.sub(rest, q1 + 1, q2 - 1), hl_func()) -- type
          text:append('\'')
          rest = string.sub(rest, q2 + 1)
          done = false
          break
        end
      end
    end

    if done then
      text:append(rest)
      return
    end
    done = true
  end
end

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
    short_name = 'TS',
    diagnostic_highlight = tsserver_diagnostic_highlight
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
client_ext['typescript'] = client_ext['tsserver']

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
