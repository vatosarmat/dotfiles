; extends

[
 "export"
 "default"
] @include

[
 "await"
] @keyword.return

[
 "as"
] @keyword

((identifier) @variable.builtin (#any-of? @variable.builtin "Object" "Array" "Math" "Date" "Function" "Number" "JSON"))

((identifier) @function.builtin (#any-of? @function.builtin "parseInt" "parseFloat" "isNaN" "eval"))
((property_identifier) @function.builtin (#eq? @function.builtin "constructor"))

[
  (this)
  (super)
] @variable.special

[
 (undefined)
 (null)
] @null

(shorthand_property_identifier) @variable
(shorthand_property_identifier_pattern) @variable

; (format_parameter
;   pattern: (identifier) @variable)

(object ["{" "}"] @ecma.object.brace)
(object_pattern ["{" "}"] @ecma.object_pattern.brace)

(array_pattern ["[" "]"] @ecma.array_pattern.brace)
(array ["[" "]"] @ecma.array.brace)
(subscript_expression ["[" "]"] @ecma.subscript.brace)

(formal_parameters ["(" ")"] @ecma.formal_parameters.brace)
(arguments ["(" ")"] @ecma.arguments.brace)

(string ["'" "'"] @punctuation.quote)
(string ["\"" "\""] @punctuation.quote)
(template_string ["`" "`"] @punctuation.quote)
