[
  "@mixin"
  "@media"
  "@include"
] @include

((plain_value) @variable
               (#match? @variable "^--"))

(variable_value) @variable
(each_statement (key) @variable)
(each_statement (value) @variable)


