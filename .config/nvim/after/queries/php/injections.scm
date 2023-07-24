; extends
;; html

(
  (array_element_initializer 
    (string (string_value) @_key)
    [(string (string_value) @html) ((encapsed_string) @html)]
  )
  (#eq? @_key "template")
)

(
  (assignment_expression 
    (variable_name (name) @_name)
    [(string (string_value) @html) ((encapsed_string) @html)]
  )
  (#eq? @_name "html")
)

(
 (heredoc
   ((heredoc_start) @_name)
   ((heredoc_body) @html)
 )
 (#eq? @_name "HTML")
)
