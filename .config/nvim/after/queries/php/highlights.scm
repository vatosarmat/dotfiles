; extends

[
  (php_tag)
  "?>"
] @tag.php

(scoped_property_access_expression
  scope: [(name) @type
          (qualified_name (name) @type)]
)

(scoped_property_access_expression
  name: ((variable_name) @property)
)

(relative_scope) @variable.special
