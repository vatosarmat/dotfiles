; extends

(variable_name) @variable @spell
(name) @spell

(relative_scope) @variable.special
((variable_name) @variable.special
 (#eq? @variable.special "$this"))

[
 "abstract"
 "const"
 "final"
 "private"
 "protected"
 "public"
 "readonly"
 "static"
] @keyword

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

