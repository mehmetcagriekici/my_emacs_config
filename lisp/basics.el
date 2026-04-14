;;; basics.el --- Core Emacs defaults and sane behaviors -*- lexical-binding: t; -*-

(message "Loading basics...")

;; ────────────────────────────────────────────────────────────────
;; Encoding: set everything to UTF-8 first, before anything else
;; ────────────────────────────────────────────────────────────────
(set-language-environment   "UTF-8")
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq locale-coding-system  'utf-8)

;; ────────────────────────────────────────────────────────────────
;; WSL/Shell environment: inherit PATH and variables from shell
;; ────────────────────────────────────────────────────────────────
(use-package exec-path-from-shell
  :ensure t
  :if (or (eq system-type 'darwin)
          (eq system-type 'gnu/linux))
  :config
  (exec-path-from-shell-initialize))

;; ────────────────────────────────────────────────────────────────
;; General UI and editing behavior
;; ────────────────────────────────────────────────────────────────
(column-number-mode 1)
(size-indication-mode 1)

(setq inhibit-startup-screen     t
      initial-scratch-message    nil
      use-short-answers           t        ; y/n instead of yes/no
      ring-bell-function         'ignore
      mouse-yank-at-point         t        ; paste at point, not click (terminal-friendly)
      confirm-kill-emacs         'yes-or-no-p

      ;; Scrolling
      scroll-conservatively      101       ; never recenter on scroll
      scroll-margin              3         ; keep 3 lines visible above/below cursor
      scroll-preserve-screen-position t)   ; keep cursor stable when scrolling

;; Pixel-smooth scrolling (Emacs 29+, no-op in terminal but harmless)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; ────────────────────────────────────────────────────────────────
;; Line numbers: only in programming and text file modes (not term, dired, etc.)
;; ────────────────────────────────────────────────────────────────
(defun my/enable-line-numbers ()
  "Enable relative line numbers for navigation."
  (setq-local display-line-numbers-type 'relative)
  (display-line-numbers-mode 1))

(add-hook 'prog-mode-hook #'my/enable-line-numbers)
(add-hook 'text-mode-hook #'my/enable-line-numbers)
(add-hook 'conf-mode-hook #'my/enable-line-numbers)

;; ────────────────────────────────────────────────────────────────
;; Editing quality-of-life
;; ────────────────────────────────────────────────────────────────

;; Auto-close brackets, quotes, etc.
(electric-pair-mode 1)
;; Prevent pairing <  in text modes where it's rarely useful
(add-hook 'text-mode-hook
          (lambda ()
            (setq-local electric-pair-inhibit-predicate
                        (lambda (c) (char-equal c ?<)))))

;; Delete selected region when typing
(delete-selection-mode 1)

;; Highlight matching parens instantly
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Strip trailing whitespace on save
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Ensure files always end with a newline
(setq require-final-newline t)

;; ───────────────────────���────────────────────────────────────────
;; Persistent & useful minor modes
;; ────────────────────────────────────────────────────────────────
(recentf-mode 1)
(setq recentf-max-saved-items 200)

(save-place-mode 1)                          ; remember cursor position per file

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t) ; also revert dired, etc.

(savehist-mode 1)                            ; persist minibuffer history (vertico/consult love this)
(setq history-length 300)

;; ────────────────────────────────────────────────────────────────
;; Compilation & native compilation noise
;; ────────────────────────────────────────────────────────────────
(setq byte-compile-warnings              '(not free-vars unresolved)
      native-comp-async-report-warnings-errors nil)

;; ────────────────────────────────────────────────────────────────
;; Backup & autosave: versioned, tucked away, never pollute project dirs
;; ────────────────────────────────────────────────────────────────
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))

      ;; Versioned backups: keep the last 8 numbered copies
      version-control        t
      kept-new-versions      8
      kept-old-versions      2
      delete-old-versions    t   ; silently delete excess backups
      backup-by-copying      t)  ; safer: always copy, never rename/hardlink

;; Create the directories if they don't exist
(dolist (dir '("auto-save" "backups"))
  (let ((path (expand-file-name dir user-emacs-directory)))
    (unless (file-exists-p path)
      (make-directory path t))))

(provide 'basics)
;;; basics.el ends here
