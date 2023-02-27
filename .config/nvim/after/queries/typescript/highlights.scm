; extends

[
  "abstract"
  "private"
  "protected"
  "public"
  "readonly"
] @keyword

[
 "export"
] @include

(type_identifier) @spell

[
 (undefined)
 (null)
] @null

(literal_type
  [
   (undefined)
   (null)
  ] @type
)

(object_type ["{" "}"] @ecma.object.brace)

(import_statement "type" @keyword)

