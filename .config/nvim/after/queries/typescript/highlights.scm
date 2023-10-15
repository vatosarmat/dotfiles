; extends

; - keywords
; - adjustments
; - spell
; - braces
; - identifiers

; - keywords
[
 "export"
] @include

(import_statement "type" @keyword)

; - adjustments
(class_declaration name:(type_identifier) @constructor)

; - spell
(type_identifier) @spell

; - braces
(object_type ["{" "}"] @typescript.type.brace)
(array_type ["[" "]"] @typescript.type.brace)

; - identifiers
(literal_type
  [
   (undefined)
   (null)
  ] @type
)
