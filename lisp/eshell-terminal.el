;;; eshell-terminal.el --- Modern Eshell + terminal enhancements -*- lexical-binding: t; -*-

(message "Loading modern Eshell & terminal tweaks...")

;; ─────────────────────────────────────────────────────────────
;; Core Eshell configuration
;; ─────────────────────────────────────────────────────────────
(use-package eshell
  :commands eshell
  :hook
  (eshell-mode . my/eshell-mode-setup)
  (eshell-mode . my/eshell-set-prompt)
  :custom
  (eshell-highlight-prompt nil)
  (eshell-hist-ignoredups t)
  (eshell-input-filter #'eshell-input-filter-initial-space)
  (eshell-buffer-maximum-lines 50000)
  (eshell-history-size 15000)
  (eshell-scroll-to-bottom-on-input 'all)
  (eshell-scroll-show-maximum-output t)
  (eshell-prefer-lisp-functions nil)
  (eshell-prompt-regexp "^.* [#$] ")
  :config
  (unless (display-graphic-p)
    (setq term-default-bg-color nil
          term-default-fg-color nil
          tty-top-bottom-recenter nil))

  (use-package eshell-syntax-highlighting
    :ensure t
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; Aliases registered once here — reliable across all eshell buffers
  (add-hook 'eshell-mode-hook #'my/eshell-setup-aliases))

;; ─────────────────────────────────────────────────────────────
;; Prompt — set per-buffer
;; ─────────────────────────────────────────────────────────────
(defun my/eshell-set-prompt ()
  "Set a clean, colorful eshell prompt."
  (setq-local eshell-prompt-function
              (lambda ()
                (concat
                 (propertize (concat (user-login-name) "@" (system-name))
                             'face 'font-lock-constant-face)
                 (propertize ":" 'face 'font-lock-builtin-face)
                 (propertize (abbreviate-file-name (eshell/pwd))
                             'face 'font-lock-string-face)
                 (if (= (user-uid) 0)
                     (propertize " # " 'face 'font-lock-warning-face)
                   (propertize " $ " 'face 'font-lock-function-name-face))))))

;; ─────────────────────────────────────────────────────────────
;; Per-buffer mode setup
;; ─────────────────────────────────────────────────────��───────
(defun my/eshell-mode-setup ()
  "Setup that runs in every Eshell buffer."
  ;; Fish-style partial-match history search
  (keymap-set eshell-mode-map "M-p" #'eshell-previous-matching-input-from-input)
  (keymap-set eshell-mode-map "M-n" #'eshell-next-matching-input-from-input)

  ;; C-l clears the scrollback buffer
  (keymap-set eshell-mode-map "C-l"
              (lambda () (interactive)
                (eshell/clear-scrollback)
                (eshell-send-input)))

  ;; Wrap long lines
  (visual-line-mode 1)

  ;; Case-insensitive tab completion
  (setq-local pcomplete-ignore-case t)

  ;; Corfu popup — use with-eval-after-load to ensure corfu is loaded first
  (with-eval-after-load 'corfu
    (corfu-mode 1)))

;; ─────────────────────────────────────────────────────────────
;; Aliases
;; ─────────────────────────────────────────────────────────────
(defun my/eshell-setup-aliases ()
  "Register eshell aliases."
  (eshell/alias "ll"    "ls -lh")
  (eshell/alias "la"    "ls -lah")
  (eshell/alias "l"     "ls -CF")
  (eshell/alias ".."    "cd ..")
  (eshell/alias "..."   "cd ../..")

  (eshell/alias "g"     "git")
  (eshell/alias "gs"    "git status --short --branch")
  (eshell/alias "gd"    "git diff")
  (eshell/alias "gl"    "git log --oneline --graph --decorate")
  (eshell/alias "gp"    "git push")
  (eshell/alias "gpl"   "git pull --rebase")

  (eshell/alias "dc"    "docker compose")
  (eshell/alias "dce"   "docker compose exec")
  (eshell/alias "dcl"   "docker compose logs -f --tail=200")
  (eshell/alias "dcu"   "docker compose up -d")
  (eshell/alias "dcd"   "docker compose down")

  (eshell/alias "e"     "find-file $1")
  (eshell/alias "E"     "find-file-other-window $1"))

;; ─────────────────────────────────────────────────────────────
;; Custom eshell commands
;; ─────────────────────────────────────────────────────────────
(defun eshell/f (&optional pattern)
  "Find files matching PATTERN using fd/fdfind."
  (let* ((bin (or (executable-find "fd") (executable-find "fdfind")))
         (cmd (if bin
                  (format "%s --color=always %s" bin (or pattern ""))
                "find . -name '*'")))
    (shell-command-to-string cmd)))

(defun eshell/d (&optional pattern)
  "Find directories matching PATTERN using fd/fdfind."
  (let* ((bin (or (executable-find "fd") (executable-find "fdfind")))
         (cmd (if bin
                  (format "%s -t d --color=always %s" bin (or pattern ""))
                "find . -type d")))
    (shell-command-to-string cmd)))

(defun eshell/up (n)
  "Go up N directories."
  (let ((path (apply #'concat (make-list (prefix-numeric-value n) "../"))))
    (eshell/cd path)))

;; ─────────────────────────────────────────────────────────────
;; vterm — real terminal emulator
;; ─────────────────────────────────────────────────────────────
(use-package vterm
  :ensure t
  :commands (vterm vterm-other-window)
  :bind (("C-c t" . vterm)
         ("C-c T" . vterm-other-window))
  :custom
  (vterm-max-scrollback 50000)
  (vterm-timer-delay 0.01)
  (vterm-kill-buffer-on-exit t)
  :config
  (add-to-list 'recentf-exclude "\\*vterm\\*")
  (add-hook 'vterm-mode-hook
            (lambda ()
              (setq-local confirm-kill-processes nil)
              (display-line-numbers-mode -1)
              (setq-local global-hl-line-mode nil))))

(provide 'eshell-terminal)
;;; eshell-terminal.el ends here
