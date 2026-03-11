;;; git-projects.el --- Git integration and project management -*- lexical-binding: t; -*-

(message "Loading git & projects...")

;; ──────────────────────────────────────────────────────────────────────────────
;; Magit — full-featured Git client
;; ──────────────────────────────────────────────────────────────────────────────
(use-package magit
  :ensure t
  :bind (("C-x g"   . magit-status)
         ("C-x M-g" . magit-dispatch)   ; access any magit command via transient
         ("C-c g l" . magit-log-current-branch)
         ("C-c g b" . magit-blame))
  :custom
  ;; In terminal: reuse the current window for status, open diff in a new one
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  ;; Word-level diff highlighting — very readable in -nw
  (magit-diff-refine-hunk 'all)          ; 'all refines all hunks, not just selected
  ;; Auto-save repo buffers without prompting
  (magit-save-repository-buffers 'dontask)
  (magit-branch-prefer-remote-upstream t)
  (magit-diff-paint-whitespace t)
  (magit-section-visibility-indicator nil) ; less noise in terminal
  ;; Don't show --graph in log by default (slow in large repos)
  (magit-log-arguments '("--graph" "--color" "--decorate" "-n256"))
  :config
  ;; magit-refresh-status-buffer should stay t (default); setting it to nil
  ;; means the status buffer won't update when you switch to it — usually
  ;; not what you want. Remove that override.
  (setq magit-refresh-status-buffer t)

  ;; Enforce good commit message hygiene
  (setq git-commit-summary-max-length 72
        git-commit-fill-column 72)
  (add-hook 'git-commit-mode-hook #'(lambda () (setq fill-column 72))))

;; ──────────────────────────────────────────────────────────────────────────────
;; git-timemachine — walk through a file's git history
;; ──────────────────────────────────────────────────────────────────────────────
(use-package git-timemachine
  :ensure t
  :bind ("C-c g t" . git-timemachine))

;; ──────────────────────────────────────────────────────────────────────────────
;; Projectile — project interaction library
;; ──────────────────────────────────────────────────────────────────────────────
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'default)        ; let vertico handle it
  (projectile-indexing-method 'hybrid)           ; fd/git fast index + fallback
  (projectile-sort-order 'recently-active)
  (projectile-known-projects-file
   (expand-file-name "projectile-bookmarks.eld" user-emacs-directory))
  (projectile-track-known-projects-automatically t)
  (projectile-mode-line-prefix " Proj")
  ;; Cache project file lists — essential for large repos in -nw mode
  (projectile-enable-caching t)
  :config
  ;; ── Custom project types ──────────────────────────────────────────────────

  (projectile-register-project-type 'go-mod '("go.mod")
                                    :project-file "go.mod"
                                    :compile "go build ./..."
                                    :test    "go test ./..."
                                    :run     "go run .")

  (projectile-register-project-type 'poetry '("pyproject.toml")
                                    :project-file "pyproject.toml"
                                    :compile "poetry build"
                                    :test    "poetry run pytest"
                                    :run     "poetry run python -m $(basename $(pwd))")

  (projectile-register-project-type 'npm '("package.json")
                                    :project-file "package.json"
                                    :compile "npm run build"
                                    :test    "npm test"
                                    :run     "npm start")

  ;; ── Consult integration ───────────────────────────────────────────────────

  ;; Use consult-project-buffer for buffer switching (C-c p b)
  (when (fboundp 'consult-project-buffer)
    (define-key projectile-command-map (kbd "b") #'consult-project-buffer))

  ;; consult-projectile is a separate package; only bind if actually installed
  ;; If you add it to your package list it gives richer project file search
  ;; (when (fboundp 'consult-projectile)
  ;;   (define-key projectile-command-map (kbd "f") #'consult-projectile))
  )

(provide 'git-projects)
;;; git-projects.el ends here
