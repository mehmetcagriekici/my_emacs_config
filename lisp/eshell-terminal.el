;;; eshell-terminal.el --- Modern Eshell + terminal enhancements -*- lexical-binding: t; -*-

(message "Loading modern Eshell & terminal tweaks...")

;; ─────────────────────────────────────────────────────────────
;; Core Eshell configuration
;; ─────────────────────────────────────────────────────────────
(use-package eshell
  :commands eshell
  :hook
  (eshell-mode       . my/eshell-mode-setup)
  (eshell-first-time-mode . my/eshell-first-time-setup)
  :custom
  (eshell-highlight-prompt nil)               ; we control the prompt ourselves
  (eshell-hist-ignoredups t)                  ; no duplicate history entries
  (eshell-input-filter #'eshell-input-filter-initial-space) ; skip space-prefixed commands
  (eshell-buffer-maximum-lines 50000)
  (eshell-history-size 15000)
  (eshell-scroll-to-bottom-on-input 'all)
  (eshell-scroll-show-maximum-output t)
  (eshell-prefer-lisp-functions t)            ; prefer Emacs Lisp over external where equivalent
  (eshell-prompt-regexp "^.* [#$>] ")         ; permissive — survives colors, git info, etc.
  :config
  ;; TTY-friendly adjustments
  (unless (display-graphic-p)
    (setq term-default-bg-color nil
          term-default-fg-color nil
          tty-top-bottom-recenter nil))

  ;; Syntax highlighting for commands typed at the prompt
  (use-package eshell-syntax-highlighting
    :ensure t
    :config
    (eshell-syntax-highlighting-global-mode +1)))

;; ─────────────────────────────────────────────────────────────
;; Per-buffer Eshell mode tweaks
;; ─────────────────────────────────────────────────────────────
(defun my/eshell-mode-setup ()
  "Setup that runs in every Eshell buffer."

  ;; Fish-style partial-match history navigation
  (keymap-set eshell-mode-map "M-p" #'eshell-previous-matching-input-from-input)
  (keymap-set eshell-mode-map "M-n" #'eshell-next-matching-input-from-input)

  ;; C-l clears the visible buffer (like a real terminal)
  (keymap-set eshell-mode-map "C-l" #'eshell/clear)

  ;; Wrap long lines naturally
  (visual-line-mode 1)

  ;; Case-insensitive completion
  (setq-local pcomplete-ignore-case t)

  ;; Corfu popup in eshell (was commented out in your original — it works fine)
  (corfu-mode 1))

;; ─────────────────────────────────────────────────────────────
;; First-time setup: prompt, aliases, custom commands
;; ─────────────────────────────────────────────────────────────
(defun my/eshell-first-time-setup ()
  "One-time setup: prompt, aliases, helpers."

  ;; ── Prompt: user@host:~/path $ (root gets # in red)
  (setq eshell-prompt-function
        (lambda ()
          (concat
           (propertize (concat (user-login-name) "@" (system-name))
                       'face 'font-lock-constant-face)
           (propertize ":" 'face 'font-lock-builtin-face)
           (propertize (abbreviate-file-name (eshell/pwd))
                       'face 'font-lock-string-face)
           (if (= (user-uid) 0)
               (propertize " # " 'face 'font-lock-warning-face)
             (propertize " $ " 'face 'font-lock-function-name-face)))))

  ;; ── File listing
  (eshell/alias "ll"    "ls -lh")
  (eshell/alias "la"    "ls -lah")
  (eshell/alias "l"     "ls -CF")
  (eshell/alias "clear" "clear 1")           ; actually clears the buffer

  ;; ── Git shortcuts
  (eshell/alias "g"     "git")
  (eshell/alias "gs"    "git status --short --branch")
  (eshell/alias "gd"    "git diff")
  (eshell/alias "gl"    "git log --oneline --graph --decorate")
  (eshell/alias "gp"    "git push")
  (eshell/alias "gpl"   "git pull --rebase")

  ;; ── Docker / Compose
  (eshell/alias "dc"    "docker compose")
  (eshell/alias "dce"   "docker compose exec")
  (eshell/alias "dcl"   "docker compose logs -f --tail=200")
  (eshell/alias "dcu"   "docker compose up -d")
  (eshell/alias "dcd"   "docker compose down")

  ;; ── Quick editing
  (eshell/alias "e"     "find-file $1")
  (eshell/alias "E"     "find-file-other-window $1")

  ;; ── fd-based fuzzy find with fd/fdfind fallback
  (defun my/fd-cmd (extra-args pattern)
    "Build an fd/fdfind command string with EXTRA-ARGS and PATTERN."
    (let ((bin (or (executable-find "fd") (executable-find "fdfind"))))
      (unless bin (user-error "Neither `fd' nor `fdfind' found in PATH"))
      (format "%s --color=always %s %s" bin extra-args pattern)))

  (defun eshell/f (pattern)
    "Find files matching PATTERN using fd/fdfind."
    (shell-command-to-string (my/fd-cmd "" pattern)))

  (defun eshell/d (pattern)
    "Find directories matching PATTERN using fd/fdfind."
    (shell-command-to-string (my/fd-cmd "-t d" pattern))))

;; ─────────────────────────────────────────────────────────────
;; vterm — real terminal emulator (for programs that need a PTY)
;; ─────────────────────────────────────────────────────────────
(use-package vterm
  :ensure t
  :commands (vterm vterm-other-window)
  :bind (("C-c t"   . vterm)
         ("C-c T"   . vterm-other-window))
  :custom
  (vterm-max-scrollback 50000)
  (vterm-timer-delay 0.01)
  ;; Kill the buffer when the shell process exits — no stale buffers
  (vterm-kill-buffer-on-exit t)
  :config
  ;; Disable kill-process confirmation inside vterm buffers
  (add-hook 'vterm-mode-hook
            (lambda ()
              (setq-local confirm-kill-processes nil))))

(provide 'eshell-terminal)
;;; eshell-terminal.el ends here
