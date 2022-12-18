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
