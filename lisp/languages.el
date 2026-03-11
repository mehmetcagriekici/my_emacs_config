;;; languages.el --- Modern language-specific major modes & settings -*- lexical-binding: t; -*-

(message "Loading modern language support (Tree-sitter preferred)...")

;; ─────────────────────────────────────────────────────────────
;; Tree-sitter: auto-install & remap classic modes → -ts- modes
;; ─────────────────────────────────────────────────────────────
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)        ; prompt before downloading grammars
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; Fallback manual remap — only kicks in for modes treesit-auto doesn't cover
;; or if treesit-auto is somehow unavailable
(setq major-mode-remap-alist
      '((python-mode     . python-ts-mode)
        (yaml-mode       . yaml-ts-mode)
        (js-mode         . js-ts-mode)
        (js2-mode        . js-ts-mode)
        ;; Note: go-mode, typescript-mode, tsx-mode, dockerfile-mode are all
        ;; handled by treesit-auto above; no need to duplicate them here
        ))

;; ─────────────────────────────────────────────────────────────
;; Helper: DRY hook for common prog-mode setup per language
;; ─────────────────────────────────────────────────────────────
(defun my/prog-mode-defaults ()
  "Sensible defaults for any programming buffer."
  (electric-pair-local-mode 1)          ; already global, but explicit per-mode is fine
  (setq-local show-trailing-whitespace t))

;; ─────────────────────────────────────────────────────────────
;; Go (built-in go-ts-mode, Emacs 29+)
;; ─────────────────────────────────────────────────────────────
(defun my/go-mode-setup ()
  "Go language buffer setup."
  (setq-local tab-width        8
              indent-tabs-mode t)       ; gofmt mandates tabs
  ;; Prefer goimports (runs gofmt + adds/removes imports)
  (setq-local gofmt-command
              (if (executable-find "goimports") "goimports" "gofmt"))
  (add-hook 'before-save-hook #'gofmt-before-save nil t))

(use-package go-ts-mode
  :hook (go-ts-mode . my/go-mode-setup))

;; ─────────────────────────────────────────────────────────────
;; Python (built-in python-ts-mode via treesit-auto)
;; ─────────────────────────────────────────────────────────────
(use-package python
  :custom
  (python-shell-interpreter "python3")
  (python-indent-offset 4)
  :hook (python-ts-mode . my/prog-mode-defaults))

;; ─────────────────────────────────────────────────────────────
;; TypeScript / TSX / JavaScript
;; ─────────────────────────────────────────────────────────────
(use-package typescript-ts-mode
  :custom
  (typescript-ts-mode-indent-offset 2)
  :hook ((typescript-ts-mode
          tsx-ts-mode
          js-ts-mode) . my/prog-mode-defaults))

;; ─────────────────────────────────────────────────────────────
;; YAML (built-in yaml-ts-mode, Emacs 29+)
;; ─────────────────────────────────────────────────────────────
(use-package yaml-ts-mode
  :hook (yaml-ts-mode . (lambda ()
                          ;; yaml-ts-mode-indent-offset doesn't exist as a custom var;
                          ;; indent-offset is controlled via treesit indent rules.
                          ;; Set tab-width instead, which most YAML tooling respects.
                          (setq-local tab-width 2
                                      indent-tabs-mode nil))))

;; ─────────────────────────────────────────────────────────────
;; Dockerfile & Docker Compose
;; ─────────────────────────────────────────────────────────────
(use-package dockerfile-ts-mode
  :mode "\\(?:Dockerfile\\(?:\\.[^/]*\\)?\\)\\'")  ; matches Dockerfile, Dockerfile.dev, etc.

(use-package docker-compose-mode
  :ensure t
  :mode "docker-compose\\.ya?ml\\'")

;; ─────────────────────────────────────────────────────────────
;; Environment files (.env, .env.local, .env.example, etc.)
;; ─────────────────────────────────────────────────────────────
(use-package dotenv-mode
  :ensure t
  :mode "\\.env\\(?:\\.\\(?:local\\|example\\|production\\|staging\\|test\\)\\)?\\'")

;; ─────────────────────────────────────────────────────────────
;; Markdown — GitHub Flavored via gfm-mode
;; ─────────────────────────────────────────────────────────────
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'"  . gfm-mode)
  :custom
  ;; Fall back gracefully if pandoc isn't installed
  (markdown-command
   (or (executable-find "pandoc") "markdown"))
  (markdown-fontify-code-blocks-natively t)
  (markdown-indent-on-enter 'indent-and-new-item)
  ;; Hide markup characters for a cleaner reading experience
  (markdown-hide-markup nil)            ; set t if you prefer a rendered look
  :hook (gfm-mode . (lambda ()
                      (electric-pair-local-mode 1)
                      (visual-line-mode 1)
                      ;; No trailing-whitespace enforcement in markdown:
                      ;; two trailing spaces = intentional line break
                      (setq-local delete-trailing-whitespace-on-save nil))))

;; ─────────────────────────────────────────────────────────────
;; LaTeX / AUCTeX
;; ─────────────────────────────────────────────────────────────
(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :custom
  (TeX-auto-save   t)
  (TeX-parse-self  t)
  (TeX-master      nil)                 ; ask per-file (multi-file projects)
  (TeX-PDF-mode    t)
  (TeX-source-correlate-mode t)         ; forward/inverse search support
  (TeX-source-correlate-start-server t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-view-program-list      '(("PDF Tools" TeX-pdf-tools-sync-view)))
  :hook (LaTeX-mode . (lambda ()
                        (turn-on-reftex)
                        (reftex-isearch-minor-mode)
                        (visual-line-mode 1)
                        (electric-pair-local-mode 1)
                        ;; Auto-fill at 80 cols for LaTeX source
                        (auto-fill-mode 1)
                        (setq-local fill-column 80))))

;; ─────────────────────────────────────────────────────────────
;; PDF Tools — superior in-Emacs PDF viewer
;; ─────────────────────────────────────────────────────────────
(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)       ; detect by file content, not just extension
  :config
  (pdf-tools-install :no-query)         ; install silently, don't prompt
  :custom
  (pdf-view-display-size 'fit-page)     ; fit page width by default
  (pdf-view-resize-factor 1.1)
  ;; Disable line numbers and hl-line in PDF buffers
  :hook (pdf-view-mode . (lambda ()
                           (display-line-numbers-mode -1)
                           (setq-local global-hl-line-mode nil))))

(provide 'languages)
;;; languages.el ends here
