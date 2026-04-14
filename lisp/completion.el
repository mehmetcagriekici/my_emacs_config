;;; completion.el --- Modern completion: Vertico + Corfu + friends -*- lexical-binding: t; -*-

(message "Loading modern completion system...")

;; ─────────────────────────────────────────────────────────────
;; Vertico — vertical minibuffer UI
;; ─────────────────────────────────────────────────────────────
(use-package vertico
  :ensure t
  :demand t
  :config
  (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 15)
  (vertico-preselect 'directory)
  (vertico-resize t))

;; ─────────────────────────────────────────────────────────────
;; Orderless — flexible out-of-order matching
;; ─────────────────────────────────────────────────────────────
(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file       (styles orderless partial-completion basic))
     (eglot      (styles orderless basic))
     (eglot-capf (styles orderless basic)))))

;; ─────────────────────────────────────────────────────────────
;; Marginalia — rich annotations next to candidates
;; ─────────────────────────────────────────────────────────────
(use-package marginalia
  :ensure t
  :demand t
  :config
  (marginalia-mode))

;; ─────────────────────────────────────────────────────────────
;; Consult — enhanced search & navigation commands
;; ─────────────────────────────────────────────────────────────
(use-package consult
  :ensure t
  :demand t
  :bind (("C-x b"   . consult-buffer)
         ("C-c f"   . consult-find)
         ("C-c F"   . my/consult-find-nohidden)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-s r"   . consult-ripgrep)
         ("M-s l"   . consult-line)
         ("M-s i"   . consult-imenu)
         ("C-c o"   . consult-outline)
         ("C-x p b" . consult-project-buffer))
  :custom
  (consult-ripgrep-args
   "rg --null --line-buffered --color=never --line-number --smart-case --no-heading --with-filename --search-zip --hidden")
  :config
  (with-eval-after-load 'consult
    (setq completion-in-region-function #'consult-completion-in-region))
  (defun my/consult-find-nohidden ()
    "Run `consult-find' without hidden files/dirs."
    (interactive)
    (let ((consult-find-args
           "fdfind --type f --type d --strip-cwd-prefix --color=never"))
      (consult-find))))

;; ─────────────────────────────────────────────────────────────
;; Embark — contextual actions on any candidate
;; ─────────────────────────────────────────────────────────────
(use-package embark
  :ensure t
  :demand t
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :demand t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ─────────────────────────────────────────────────────────────
;; Corfu — in-buffer completion popup
;; ─────────────────────────────────────────────────────────────
(use-package corfu
  :ensure t
  :demand t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-preselect 'valid)
  (corfu-on-exact-match 'insert)
  (corfu-quit-at-boundary 'separator)
  (corfu-quit-no-match t)
  (corfu-scroll-margin 5)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :bind (:map corfu-map
              ("TAB" . corfu-insert)
              ([tab] . corfu-insert)
              ("RET" . nil))
  :config
  (global-corfu-mode)
  (require 'corfu-popupinfo)
  (corfu-popupinfo-mode)
  (unless (display-graphic-p)
    (setq corfu-auto nil)))

;; corfu-terminal: makes Corfu work properly in -nw / terminal Emacs
(use-package corfu-terminal
  :ensure t
  :demand t
  :unless (display-graphic-p)
  :after corfu
  :config
  (corfu-terminal-mode 1))

;; Icons in the popup (requires a Nerd Font in your terminal)
(use-package nerd-icons-corfu
  :ensure t
  :demand t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; ─────────────────────────────────────────────────────────────
;; Cape — extra completion-at-point backends
;; ─────────────────────────────────────────────────────────────
(use-package cape
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
  ;;(advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)
  )

;; ─────────────────────────────────────────────────────────────
;; Eshell: fish-like inline autosuggestions + corfu popup
;; ─────────────────────────────────────────────────────────────
(use-package capf-autosuggest
  :ensure t
  :demand t
  :hook (eshell-mode . capf-autosuggest-mode))

(add-hook 'eshell-mode-hook #'corfu-mode)

(provide 'completion)
;;; completion.el ends here
