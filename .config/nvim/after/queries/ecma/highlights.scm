; extends

; - keywords
; - adjustments
; - spell
; - braces

; - keywords
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

; - adjustments
(shorthand_property_identifier) @variable
(shorthand_property_identifier_pattern) @variable

; - spell
(identifier) @spell
(property_identifier) @spell

; - braces
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
