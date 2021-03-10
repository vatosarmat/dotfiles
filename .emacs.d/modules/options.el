;;;Options
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq indent-tabs-mode nil)
(setq eval-expression-print-length 512)
(setq scroll-conservatively most-positive-fixnum)
(setq make-backup-files nil)

;;Line numbers
(setq column-number-mode t)
(global-display-line-numbers-mode t)
(dolist (mode `(org-mode-hook term-mode-hook eshell-mode-hook dired-mode-hook)) (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;;Ui
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)
(fringe-mode -1)

;;;Font face
(defvar dotfiles/font-face "JetBrainsMono NerdFont" "font face")
(defun dotfiles/set-height (size) "" (interactive "p")
  (set-face-attribute 'default nil :font dotfiles/font-face :height size)
)
(ignore-errors (dotfiles/set-height 100))
