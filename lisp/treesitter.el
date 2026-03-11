;;; treesitter.el --- Tree-sitter syntax parsing and major modes -*- lexical-binding: t; -*-

(message "Loading tree-sitter...")

;; ──────────────────────────────────────────────────────────────────────────────
;; treesit-auto — automatic grammar installation and mode remapping
;; ──────────────────────────────────────────────────────────────────────────────
(use-package treesit-auto
  :ensure t
  :custom
  ;; Prompt before downloading a grammar the first time
  (treesit-auto-install t)
  :config
  ;; Pass 'all to remap every supported language automatically.
  ;; This is cleaner than maintaining a manual list that drifts out of sync
  ;; with treesit-auto's own recipe list.
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; ──────────────────────────────────────────────────────────────────────────────
;; Indentation tweaks per language
;; Use with-eval-after-load so these only fire when the mode is actually loaded.
;; ──────────────────────────────────────────────────────────────────────────────

;; Go: tabs at width 8 is the official gofmt standard
(with-eval-after-load 'go-ts-mode
  (setq go-ts-mode-indent-offset 8))

;; Python: PEP 8 mandates 4 spaces
(with-eval-after-load 'python-ts-mode
  (setq python-indent-offset 4))        ; python-ts-mode-indent-offset doesn't exist;
                                        ; it inherits python-indent-offset from python.el

;; TypeScript / TSX: 2-space indent is the community standard
(with-eval-after-load 'typescript-ts-mode
  (setq typescript-ts-mode-indent-offset 2))

;; JavaScript
(with-eval-after-load 'js-ts-mode
  (setq js-indent-level 2))

;; JSON: 2-space indent
(with-eval-after-load 'json-ts-mode
  (setq json-ts-mode-indent-offset 2))

;; Note: yaml-ts-mode-indent-offset does NOT exist as a custom variable.
;; YAML indentation is controlled internally by treesit indent rules.
;; Set tab-width in a hook instead (done in languages.el).

;; ──────────────────────────────────────────────────────────────────────────────
;; major-mode-remap-alist — fallback for modes treesit-auto doesn't cover
;;
;; treesit-auto-add-to-auto-mode-alist 'all already handles most of these.
;; We only add entries here that treesit-auto misses or gets wrong.
;; ──────────────────────────────────────────────────────────────────────────────
(with-eval-after-load 'treesit-auto
  ;; sh-mode → bash-ts-mode (treesit-auto maps sh files to bash grammar)
  (add-to-list 'major-mode-remap-alist '(sh-mode      . bash-ts-mode))
  ;; js-jsx-mode is obsolete; remap to tsx-ts-mode which handles JSX
  (add-to-list 'major-mode-remap-alist '(js-jsx-mode  . tsx-ts-mode))
  ;; c/c++ remaps — only safe if grammars are installed
  (when (treesit-language-available-p 'c)
    (add-to-list 'major-mode-remap-alist '(c-mode    . c-ts-mode)))
  (when (treesit-language-available-p 'cpp)
    (add-to-list 'major-mode-remap-alist '(c++-mode  . c++-ts-mode))))

;; Do NOT remap fundamental-mode → text-ts-mode.
;; fundamental-mode is intentionally a bare-minimum mode used as a safe
;; fallback. Remapping it causes subtle breakage in temp buffers, minibuffers,
;; and packages that open scratch buffers in fundamental-mode.

;; ──────────────────────────────────────────────────────────────────────────────
;; treesit-load-name-override-list
;; Only needed if a grammar shared library has a non-standard internal name.
;; The go.mod grammar is a common case on some Linux distros.
;; ──────────────────────────────────────────────────────────────────────────────
(setq treesit-load-name-override-list
      '((gomod "libtree-sitter-gomod" "tree_sitter_go_mod"))) ; correct lib/symbol names

;; ──────────────────────────────────────────────────────────────────────────────
;; Eager-load go-ts-mode so its hooks (defined in languages.el) are in place
;; before the first Go file is visited.
;; ──────────────────────────────────────────────────────────────────────────────
(with-eval-after-load 'go-ts-mode
  ;; Nothing extra needed here — languages.el owns the hooks.
  ;; This block exists as a marker for future go-ts-mode config.
  )

(provide 'treesitter)
;;; treesitter.el ends here
