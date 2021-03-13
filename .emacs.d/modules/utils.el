(defun dotfiles/toggle-var (var)
  "..."
  (interactive
   (let* ((def  (variable-at-point))
          (def  (and def
                     (not (numberp def))
                     (memq (symbol-value def) '(nil t))
                     (symbol-name def))))
     (list
      (completing-read
       "Toggle value of variable: "
       obarray (lambda (c)
                 (unless (symbolp c) (setq c  (intern c)))
                 (and (boundp c)  (memq (symbol-value c) '(nil t))))
       'must-confirm nil 'variable-name-history def))))
  ;Body
  (set var (not (symbol-value var)))
  (message "%s is now %s"
    (symbol-name var)
    (symbol-value var)
  )
)
