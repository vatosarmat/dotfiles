return {
  sfmt(
    'zcs',
    [[
type $1@Props = {
}

export const $1@: React.FC<$1@Props> = ({}) => {
  return $2@
}
]],
    i(1, 'name'),
    i(2)
  ),

  sfmt(
    'zcc',
    [[
import type { ComponentPropsWithRef } from 'react';
import cl from 'classnames'

import styles from './$1@.module.css'

type $1@Props = ComponentPropsWithRef<'$2@'> & {
  $3@
}

export const $1@: React.FC<$1@Props> = ({ className, children, ...rest }) => {
  return <$2@ className={cl(styles.root, className)} {...rest}>{children}</$2@>
}
]],
    i(1, 'name'),
    i(2, 'div'),
    i(3)
  ),
}
