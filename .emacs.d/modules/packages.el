;Required for evil
(use-package undo-fu)

(use-package evil
  :init
  ;Looks like this is essential for evil functionality. It is t by default
  ;(setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  ;
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-C-u-scroll t)
  (setq evil-disable-insert-state-bindings t)
  (setq evil-search-wrap nil)
  ;(setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  :config
  ;Required for undo-fu functionality
  (define-key evil-normal-state-map "u" 'undo-fu-only-undo)
  (define-key evil-normal-state-map "\C-r" 'undo-fu-only-redo)
  ;(define-key evil-insert-state-map (kbd "<tab>") 'evil-normal-state)
  ;(define-key evil-normal-state-map (kbd "M-h") 'evil-window-left)
  ;(define-key evil-normal-state-map (kbd "M-j") 'evil-window-down)
  ;(define-key evil-normal-state-map (kbd "M-k") 'evil-window-up)
  ;(define-key evil-normal-state-map (kbd "M-l") 'evil-window-right)
  ;(add-hook 'evil-mode-hook 'dw/evil-hook)
  (evil-mode 1)
  ;(define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  ;(evil-global-set-key 'motion "j" 'evil-next-visual-line)
  ;(evil-global-set-key 'motion "k" 'evil-previous-visual-line)
)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; `ivy` and `councel` - tools for better completion in various contexts
(use-package ivy
  :diminish
  :bind (
	 ;;("C-s" . swiper)
         :map ivy-minibuffer-map
         ;("TAB" . ivy-alt-done)
         ;;("C-l" . ivy-alt-done)
         ;;("C-j" . ivy-next-line)
         ;;("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ;("C-k" . ivy-previous-line)
         ;("C-l" . ivy-done)
         ;("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ;("C-k" . ivy-previous-line)
         ;("C-d" . ivy-reverse-i-search-kill)
         )
  :config
  (ivy-mode 1))

;;Add text description to autocomplete entries
(use-package ivy-rich
  :config
  ;(ivy-rich-modify-column 'ivy-switch-buffer
  ;                        'ivy-rich-switch-buffer-major-mode
  ;                        '(:width 10 :face error))
  (ivy-rich-mode 1)
)
;;(setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)

;;counsel provides replacements for builtin M-x, C-f, C-x b
;;we should explicitly bind them to use
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-switch-buffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)
)

;; doom and its icons - family of packages for better look
(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 0)
  :custom ((doom-modeline-height 15))
)

(use-package doom-themes
  :init (load-theme 'doom-tomorrow-night t)
  :config (setq doom-themes-enable-bold nil doom-themes-enable-italic nil)
  )

;;in order not to get lost in parentheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
)


;; press prefix key and wait for help
(use-package which-key
  :init
  (setq which-key-idle-delay 2)
  (which-key-mode)
)

;;helpful provides replacements for  bultin describe-commands
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))
(global-set-key (kbd "C-c C-d") #'helpful-at-point)


;for user own prefixes out of the normal C-c and C-x
(use-package general
  :config
  (general-create-definer dotfiles/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (dotfiles/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    ;;TODO: Maybe should be better way to do this, maybe without 2 different lambda-commands
    "tm" '((lambda () (interactive)
             (dotfiles/toggle-var 'org-hide-emphasis-markers)
             (org-mode)
           ) :which-key "enable")
  )
)

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(dotfiles/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (setq projectile-project-search-path '("~/Dropbox" "~"))
  ; (setq projectile-project-search-path (cddr (directory-files "~/Code" t)))
)

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  ; :custom
  ; (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
)

; (use-package pdf-tools)
; (pdf-tools-install)

(use-package markdown-mode)

;;Org mode
(defun dotfiles/org-mode-setup ()
  (org-indent-mode)
  ; (variable-pitch-mode 1)
  (visual-line-mode 1)
)

(defun dotfiles/org-font-setup ()
  ;; Replace list hyphen with dot
  ; (font-lock-add-keywords 'org-mode
  ;                         '(("^ *\\([-]\\) "
  ;                            (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.5)
                  (org-level-2 . 1.35)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.1)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font dotfiles/font-face :weight 'regular :height (cdr face))
  )

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  ; (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  ; (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  ; (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  ; (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  ; (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  ; (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  ; (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
)

(use-package org
  :hook (org-mode . dotfiles/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (dotfiles/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("⚫" "➊" "➋" "➌" "➍" "➎" "➏")))

(defun dotfiles/org-mode-visual-fill ()
  (setq visual-fill-column-width 160
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . dotfiles/org-mode-visual-fill))
