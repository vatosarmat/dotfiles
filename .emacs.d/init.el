;;;Get rid of autogenerated garbage
(setq custom-file (concat user-emacs-directory "/custom.el"))

;;;Packages infrastructure
;;Package.el
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
;;use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;Modules
(dolist (file '("utils" "options" "packages" "mappings"))
  (load (expand-file-name (concat "modules/" file ".el") user-emacs-directory)))

;;Below is stuff not suitable for separate file
(defun playground () "" (interactive)
  (load (expand-file-name "modules/playground.el" user-emacs-directory)))

(defun my-gdb-io-stop ()
  "Stop the program being debugged."
  (interactive)
  (process-send-string (get-buffer-process
                         (gdb-get-buffer-create 'gdb-inferior-io))
                       (kbd "C-z")))
