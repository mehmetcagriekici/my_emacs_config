;;; lsp.el --- Language Server Protocol via eglot -*- lexical-binding: t; -*-

(message "Loading LSP (eglot)...")

;; ──────────────────────────────────────────────────────────────────────────────
;; Eglot — built-in LSP client (Emacs 29+)
;; ──────────────────────────────────────────────────────────────────────────────
(use-package eglot
  :demand t                             ; load immediately so server-programs are set
  :hook
  ((c-ts-mode c-mode)                   . eglot-ensure)
  ((go-ts-mode go-mode)                 . eglot-ensure)
  ((python-ts-mode python-mode)         . eglot-ensure)
  ((typescript-ts-mode
    tsx-ts-mode
    js-ts-mode)                         . eglot-ensure)
  ((rust-ts-mode rust-mode)             . eglot-ensure)
  ((yaml-ts-mode yaml-mode)             . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-send-changes-idle-time 0.5)
  (eglot-events-buffer-size 2000000)
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :foldingRangeProvider
     :inlayHintProvider))
  :bind
  (:map eglot-mode-map
        ("C-c l r" . eglot-rename)
        ("C-c l a" . eglot-code-actions)
        ("C-c l f" . eglot-format-buffer)
        ("C-c l d" . eldoc-doc-buffer)
        ("C-c l D" . eglot-find-declaration)
        ("C-c l i" . eglot-find-implementation)
        ("C-c l t" . eglot-find-type-definition)
        ("M-."     . xref-find-definitions)
        ("M-,"     . xref-go-back)
        ("M-?"     . xref-find-references))
  :config
  ;; Go: gopls with staticcheck and placeholder args
  (add-to-list 'eglot-server-programs
               '((go-ts-mode go-mode) . ("gopls"
                                         :initializationOptions
                                         (:staticcheck t
                                          :usePlaceholders t))))

  ;; Python: prefer basedpyright, fall back to pyright
  (add-to-list 'eglot-server-programs
               `((python-ts-mode python-mode) .
                 ,(if (executable-find "basedpyright-langserver")
                      '("basedpyright-langserver" "--stdio")
                    '("pyright-langserver" "--stdio"))))

  ;; TypeScript / JS
  (add-to-list 'eglot-server-programs
               '((typescript-ts-mode tsx-ts-mode js-ts-mode) .
                 ("typescript-language-server" "--stdio")))

  ;; Rust: rust-analyzer with clippy
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer"
                  :initializationOptions
                  (:checkOnSave (:command "clippy")))))

  ;; flymake-indicator-type is Emacs 30+ only
  (when (boundp 'flymake-indicator-type)
    (setq flymake-indicator-type 'margins))

  (setq flymake-no-changes-timeout 1.0))

;; ──────────────────────────────────────────────────────────────────────────────
;; Eldoc — inline signatures & hover docs
;; ──────────────────────────────────────────────────────────────────────────────
(use-package eldoc
  :demand t
  :custom
  (eldoc-echo-area-display-truncation-message nil)
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-echo-area-use-multiline-p t)
  :config
  ;; eglot enables eldoc-mode automatically per buffer;
  ;; global-eldoc-mode ensures it's on everywhere else too.
  (global-eldoc-mode 1))

;; ──────────────────────────────────────────────────────────────────────────────
;; consult-eglot — browse LSP workspace symbols via consult
;; ──────────────────────────────────────────────────────────────────────────────
(use-package consult-eglot
  :ensure t
  :after (consult eglot)
  :bind (:map eglot-mode-map
              ("C-c l s" . consult-eglot-symbols)))

(provide 'lsp)
;;; lsp.el ends here
