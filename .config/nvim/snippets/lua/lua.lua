return {
  -- func, f
  sfmt(
    'fuu',
    [[
function $1@($2@)
  $3@
end
]],
    i(1, 'name'),
    i(2),
    i(3)
  ),
  sfmt(
    'ful',
    [[
local function $1@($2@)
  $3@
end
]],
    i(1, 'name'),
    i(2),
    i(3)
  ),

  -- loop, l
  sfmt(
    'lfr',
    [[
for index, value in ipairs($1@) do
  $2@
end
]],
    i(1, 'list'),
    i(2)
  ),
  sfmt(
    'lfr',
    [[
for key, value in pairs($1@) do
  $2@
end
]],
    i(1, 'table'),
    i(2)
  ),
}
