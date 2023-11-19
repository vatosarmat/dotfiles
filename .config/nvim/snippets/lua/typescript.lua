return {
  -- m, import
  sfmt(
    'mt',
    [[
import type {$2@} from '$1@'
    ]],
    i(1, 'module'),
    i(2)
  ),
}
