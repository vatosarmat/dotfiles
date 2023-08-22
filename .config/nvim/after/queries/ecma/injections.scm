; extends

(object
  (pair
    key:   (property_identifier) @_key (#eq? @_key "template")
    value: (string (string_fragment) @vue)
  )
)
 
(object
  (pair
    key:   (property_identifier) @_key (#eq? @_key "template")
    value: (template_string) @vue (#offset! @vue 0 1 0 -1)
  )
)
