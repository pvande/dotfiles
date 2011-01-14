;; Add .emacs.d to the load path.
(setq dotfiles-dir (file-name-directory (or (buffer-file-name) load-file-name)))
(add-to-list 'load-path dotfiles-dir)

;; Load a few libraries.
(require 'package)  ;; ELPA
(require 'kpm-list) ;; Buffer grouping