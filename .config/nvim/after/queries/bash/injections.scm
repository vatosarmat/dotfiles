; extends
(
  (redirected_statement redirect: 
                       (heredoc_redirect 
                         (heredoc_start) @_here (#eq? @_here "'PERL'"))) 
  (heredoc_body) @perl (#offset! @perl 0 0 0 -4))

(
  (list (redirected_statement redirect: 
                       (heredoc_redirect 
                         (heredoc_start) @_here (#eq? @_here "'PERL'"))))
  (heredoc_body) @perl (#offset! @perl 0 0 0 -4))

(
  (redirected_statement redirect: 
                        (heredoc_redirect 
                          (heredoc_start) @_here (#eq? @_here "'AWK'"))) 
  (heredoc_body) @awk (#offset! @awk 0 0 0 -3))

(
  (list (redirected_statement redirect: 
                        (heredoc_redirect 
                          (heredoc_start) @_here (#eq? @_here "'AWK'")))) 
  (heredoc_body) @awk (#offset! @awk 0 0 0 -3))
