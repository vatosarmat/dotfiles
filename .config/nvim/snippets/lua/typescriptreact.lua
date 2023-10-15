return {
  sfmt(
    'comp',
    [[
type $1@Props = {
}

const $1@:React.FC<$1@Props> = ({}) => {
  $2@
  return null
}

export default $1@
]],
    i(1, 'name'),
    i(0)
  ),
}
