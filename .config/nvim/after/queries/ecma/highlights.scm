[
 "return"
 "await"
 "export"
] @include


((identifier) @function
              (#match? @function "^[A-Z]"))

((identifier) @variable.builtin (#any-of? @variable.builtin "Object" "Array" "Math" "Date" "Function" "Number"))

((identifier) @function.builtin (#any-of? @function.builtin "parseInt" "parseFloat" "isNaN" "eval"))

(this) @constant.builtin
(super) @constant.builtin

(shorthand_property_identifier_pattern) @variable

(required_parameter
  pattern: (identifier) @variable)

(object ["{" "}"] @ecma.object.brace)
(object_type ["{" "}"] @ecma.object.brace)
(object_pattern ["{" "}"] @ecma.object_pattern.brace)
(array_pattern ["[" "]"] @ecma.array_pattern.brace)
(subscript_expression ["[" "]"] @ecma.subscript.brace)
(formal_parameters ["(" ")"] @ecma.formal_parameters.brace)
(arguments ["(" ")"] @ecma.arguments.brace)

(string ["'" "'"] @punctuation.quote)
(string ["\"" "\""] @punctuation.quote)
(template_string ["`" "`"] @punctuation.quote)
