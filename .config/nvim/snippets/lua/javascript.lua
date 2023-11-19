-- i(jump-index, 'placeholder')
-- l(l._jump-index-ref-num, jump-index-refs)

return {
  -- generic
  sfmt('cl', 'console.log($1@)', i(1, 'args')),
  sfmt(
    'pr',
    [[
new Promise((resolve, reject) => {
  $1@
})
]],
    i(1)
  ),

  -- const, c
  sfmt('c', 'const $1@ = $2@', i(1, 'name'), i(2)),
  sfmt('co', 'const $1@ = {$2@}', i(1, 'name'), i(2)),
  sfmt('ca', 'const $1@ = [$2@]', i(1, 'name'), i(2)),
  sfmt(
    'cf',
    [[
const $1@ = async ($2@) => {
  $3@
}
]],
    i(1, 'name'),
    i(2),
    i(3)
  ),
  sfmt(
    'cs',
    [[
const $1@ = ($2@) => {
  $3@
}
]],
    i(1, 'name'),
    i(2),
    i(3)
  ),

  -- func, f
  sfmt(
    'fua',
    [[
async function $1@($2@) {
  $3@
}
]],
    i(1, 'func'),
    i(2),
    i(3)
  ),

  -- loop, l
  sfmt(
    'lfr',
    [[
for (const $1@ of $2@) {
  $3@
}
]],
    i(1, 'item'),
    i(2, 'array'),
    i(3)
  ),
  sfmt(
    'lfe',
    [[
for (const [$1@, $2@] of Object.entries($3@)) {
  $4@
}
]],
    i(1, 'key'),
    i(2, 'value'),
    i(3, 'obj'),
    i(4)
  ),

  -- import, m
  sfmt(
    'mm',
    [[
import {$2@} from '$1@'
    ]],
    i(1, 'module'),
    i(2)
  ),
  sfmt(
    'md',
    [[
import $2@ from '$1@'
    ]],
    i(1, 'module'),
    l(l._1, 1)
  ),

  -- exception, x
  sfmt(
    'xcl',
    [[
try {
  $1@
} catch (err) {
  console.log(err)
}
]],
    i(1)
  ),

  -- node require, r
  sfmt('rr', [[const { $2@ } = require('$1@')]], i(1, 'module'), i(2)),
  sfmt('rd', [[const $2@ = require('$1@')]], i(1, 'module'), l(compose(trim_path)(l._1), 1)),
  sfmt(
    'ru',
    [[const $2@ = require('$1@')]],
    i(1, 'module'),
    l(compose(trim_path, upper_first)(l._1), 1)
  ),

  -- testing, t
  sfmt(
    'tt',
    [[
test('$1@', async () => {
  $2@
})
  ]],
    i(1, 'title'),
    i(2)
  ),
  sfmt(
    'td',
    [[
describe('$1@', () => {
  $2@
})
  ]],
    i(1, 'title'),
    i(2)
  ),
  ---- after, before
  sfmt(
    'tba',
    [[
beforeAll(async () => {
  $1@
})
  ]],
    i(1)
  ),
  sfmt(
    'taa',
    [[
afterAll(async () => {
  $1@
})
  ]],
    i(1)
  ),
  sfmt(
    'tbe',
    [[
beforeEach(async () => {
  $1@
})
  ]],
    i(1)
  ),
  sfmt(
    'tae',
    [[
afterEach(async () => {
  $1@
})
  ]],
    i(1)
  ),
}
