; extends

[(class_name) (id_name)] @type

[
 "@media"
 "@import"
 "@charset"
 "@namespace"
 "@supports"
 "@keyframes"
 (at_keyword)
 (to)
 (from)
 (important)
] @include

[
 (feature_name)
] @type

[
 (tag_name)
] @tag

((property_name) @variable
                 (#match? @variable "^--"))
((plain_value) @variable
               (#match? @variable "^--"))



