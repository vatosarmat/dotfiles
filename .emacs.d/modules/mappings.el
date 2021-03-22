;;Low-level translations
;Better arrows
(define-key key-translation-map (kbd "M-h") (kbd "<left>"))
(define-key key-translation-map (kbd "M-j") (kbd "<down>"))
(define-key key-translation-map (kbd "M-k") (kbd "<up>"))
(define-key key-translation-map (kbd "M-l") (kbd "<right>"))

;;Tab as escape in evil mode
(evil-global-set-key 'insert (kbd "<tab>") 'evil-normal-state)
(evil-global-set-key 'replace (kbd "<tab>") 'evil-normal-state)
; (evil-global-set-key 'normal (kbd "<tab>") 'evil-force-normal-state)
(evil-global-set-key 'visual (kbd "<tab>") 'evil-exit-visual-state)

;;Global
;My
; (global-set-key (kbd "C-y") 'kill-line)
(global-unset-key (kbd "C-x C-c"))
(global-set-key (kbd "C-v") 'yank)
(global-set-key (kbd "C-s") 'save-buffer)
; (global-set-key (kbd "C-u") '(lambda () (interactive) (kill-line 0)) )
(if window-system (global-set-key [escape] 'keyboard-escape-quit))
;Replacehg
; (global-set-key (kbd "M-u") 'universal-argument)
