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

(defun next-code-buffer ()
  (interactive)
  (let (( bread-crumb (buffer-name) ))
    (next-buffer)
    (while
        (and
         (string-match-p "^\*" (buffer-name))
         (not ( equal bread-crumb (buffer-name) )) )
      (next-buffer))))

(defun previous-code-buffer ()
  (interactive)
  (let (( bread-crumb (buffer-name) ))
    (previous-buffer)
    (while
        (and
         (string-match-p "^\*" (buffer-name))
         (not ( equal bread-crumb (buffer-name) )) )
      (previous-buffer))))
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
(global-set-key (kbd "M-[") 'org-backward-element)
(global-set-key (kbd "M-]") 'org-forward-element)
(global-set-key (kbd "C-M-[") 'org-up-element)
(global-set-key (kbd "C-M-]") 'org-down-element)
(global-set-key (kbd "M-n") 'next-code-buffer)
(global-set-key (kbd "M-p") 'previous-code-buffer)
