; extends

(
 (command (command_name) @_here (raw_string) @jq (#offset! @jq 0 1 0 -1))
 (#eq? @_here "jq")
)

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

(
  (redirected_statement redirect: 
                        (heredoc_redirect 
                          (heredoc_start) @_here (#eq? @_here "'PHP'"))) 
  (heredoc_body) @php (#offset! @php 0 0 0 -3))

(
  (list (redirected_statement redirect: 
                        (heredoc_redirect 
                          (heredoc_start) @_here (#eq? @_here "'PHP'")))) 
  (heredoc_body) @php (#offset! @php 0 0 0 -3))
