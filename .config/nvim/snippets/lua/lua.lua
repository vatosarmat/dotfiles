return {
  -- logging, printing
  sfmt('cl', 'vim.print($1@)', i(1, 'args')),

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
    'lfl',
    [[
for $1@, $2@ in ipairs($3@) do
  $4@
end
]],
    i(1, 'index'),
    i(2, 'item'),
    i(3, 'list'),
    i(4)
  ),
  sfmt(
    'lft',
    [[
for $1@, $2@ in pairs($3@) do
  $4@
end
]],
    i(1, 'key'),
    i(2, 'item'),
    i(3, 'table'),
    i(4)
  ),

  -- require, r
  sfmt('rr', [[local $2@ = require('$1@')]], i(1, 'module'), i(2)),
}
