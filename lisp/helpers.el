;;; helpers.el --- Utility packages and helper functions -*- lexical-binding: t; -*-

(message "Loading helpers...")

;; ──────────────────────────────────────────────────────────────────────────────
;; which-key — show available keybindings in a popup
;; ──────────────────────────────────────────────────────────────────────────────
(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-idle-secondary-delay 0.01)
  (which-key-sort-order 'which-key-local-then-key-order)
  ;; side-window in GUI, minibuffer in terminal — cleaner & safer in -nw
  (which-key-popup-type
   (if (display-graphic-p) 'side-window 'minibuffer))
  (which-key-side-window-location 'bottom)
  (which-key-side-window-max-width 0.33)
  (which-key-max-description-length 32))
  ;; Note: which-key-allow-regexp removed — it doesn't exist as a variable;
  ;; which-key never had a regexp filter toggle. Harmless but noisy on startup.

;; ──────────────────────────────────────────────────────────────────────────────
;; rainbow-delimiters — colorful matching parens/brackets
;; ──────────────────────────────────────────────────────────────────────────────
(use-package rainbow-delimiters
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode)
  (text-mode . rainbow-delimiters-mode)   ; useful in markdown/org too
  :custom
  (rainbow-delimiters-max-face-count 9))

;; ──────────────────────────────────────────────────────────────────────────────
;; helpful — much richer *Help* buffers
;; ──────────────────────────────────────────────────────────────────────────────
(use-package helpful
  :ensure t
  :bind (("C-h f"   . helpful-callable)   ; replaces describe-function
         ("C-h v"   . helpful-variable)   ; replaces describe-variable
         ("C-h k"   . helpful-key)        ; replaces describe-key
         ("C-h x"   . helpful-command)
         ("C-h o"   . helpful-symbol)
         ("C-c C-d" . helpful-at-point))) ; describe symbol at point

;; ──────────────────────────────────────────────────────────────────────────────
;; Personal utility functions
;; ──────────────────────────────────────────────────────────────────────────────

(defun my/rename-file-and-buffer ()
  "Rename the current file and its buffer simultaneously."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer is not visiting a file")
      (let ((new-name (read-file-name "New name: " filename)))
        (rename-file filename new-name t)
        (set-visited-file-name new-name t t)
        (message "Renamed to %s" new-name)))))

(defun my/delete-file-and-buffer ()
  "Delete the current file and kill its buffer."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not filename)
        (kill-buffer)
      (when (yes-or-no-p (format "Delete %s? " filename))
        (delete-file filename t)          ; t = move to trash
        (kill-buffer)
        (message "Deleted %s" filename)))))

(defun my/copy-file-path ()
  "Copy the current buffer's full file path to the kill ring."
  (interactive)
  (if-let ((path (buffer-file-name)))
      (progn (kill-new path)
             (message "Copied: %s" path))
    (message "Buffer has no file path")))

(defun my/open-line-below ()
  "Insert a blank line below the current line and move point there."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun my/open-line-above ()
  "Insert a blank line above the current line and move point there."
  (interactive)
  (beginning-of-line)
  (newline)
  (forward-line -1)
  (indent-according-to-mode))

;; Handy keybindings for the above
(global-set-key (kbd "C-c r")   #'my/rename-file-and-buffer)
(global-set-key (kbd "C-c D")   #'my/delete-file-and-buffer)
(global-set-key (kbd "C-c y")   #'my/copy-file-path)
(global-set-key (kbd "<C-return>")   #'my/open-line-below)
(global-set-key (kbd "<C-S-return>") #'my/open-line-above)

(provide 'helpers)
;;; helpers.el ends here
