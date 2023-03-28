; extends

[(class_name) (id_name)] @type @spell

(plain_value) @spell

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

((property_name) @variable @spell
                 (#match? @variable "^--"))
((plain_value) @variable
               (#match? @variable "^--"))



