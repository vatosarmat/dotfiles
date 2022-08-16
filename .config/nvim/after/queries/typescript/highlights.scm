[
 "return"
 "await"
 "export"
] @include


((identifier) @function
              (#match? @function "^[A-Z]"))

((identifier) @type.builtin (#any-of? @type.builtin "Object" "Array" "Math" "Date" "Function" "Number"))

(undefined) @constant.builtin
(this) @constant.builtin
(super) @constant.builtin

(shorthand_property_identifier_pattern) @variable

(required_parameter
  pattern: (identifier) @variable)

(object ["{" "}"] @ecma.object.brace)
(object_type ["{" "}"] @ecma.object.brace)
(object_pattern ["{" "}"] @ecma.object_pattern.brace)

(formal_parameters ["(" ")"] @ecma.formal_parameters.brace)
(arguments ["(" ")"] @ecma.arguments.brace)
