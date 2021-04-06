
((identifier) @function
 (#match? @function "^[A-Z]"))

(jsx_opening_element ((identifier) @type
 (#match? @type "^[A-Z]")))

; Handle the dot operator effectively - <My.Component>
(jsx_opening_element ((nested_identifier (identifier) @tag (identifier) @type)))

(jsx_closing_element ((identifier) @type
 (#match? @type "^[A-Z]")))

; Handle the dot operator effectively - </My.Component>
(jsx_closing_element ((nested_identifier (identifier) @tag (identifier) @type)))

(jsx_self_closing_element ((identifier) @type
 (#match? @type "^[A-Z]")))

; Handle the dot operator effectively - <My.Component />
(jsx_self_closing_element ((nested_identifier (identifier) @tag (identifier) @type)))
