;;; ui.el --- Theme, modeline, fonts & visual appearance -*- lexical-binding: t; -*-

(message "Loading modern UI tweaks...")

;; ─────────────────────────────────────────────────────────────
;; Strip UI chrome early — before any frame is fully rendered.
;; In -nw mode only menu-bar is present; the rest are no-ops.
;; ─────────────────────────────────────────────────────────────
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(menu-bar-mode   -1)                    ; also cleaner in terminal
(when (display-graphic-p)
  (set-fringe-mode '(8 . 8)))           ; subtle fringes in GUI only

;; ─────────────────────────────────────────────────────────────
;; Nerd Icons — required by doom-modeline and nerd-icons-corfu
;; Run M-x nerd-icons-install-fonts once after first install.
;; ─────────────────────────────────────────────────────────────
(use-package nerd-icons
  :ensure t
  :defer t)

;; ─────────────────────────────────────────────────────────────
;; doom-themes
;; ─────────────────────────────────────────────────────────────
(use-package doom-themes
  :ensure t
  :demand t                             ; load immediately — theme must apply early
  :config
  ;; bold/italic must be set BEFORE load-theme
  (setq doom-themes-enable-bold   t
        doom-themes-enable-italic t)

  ;; Choose theme: doom-vibrant works better than doom-one in most terminals
  ;; because it has stronger contrast ratios without relying on true-color faces.
  (if (display-graphic-p)
      (load-theme 'doom-one t)          ; GUI: dark
    (load-theme 'doom-vibrant t))       ; terminal: better contrast

  ;; Org-mode heading and block face improvements
  (doom-themes-org-config)

  ;; Flash the modeline instead of ringing a bell
  (doom-themes-visual-bell-config))

;; Optional time-based theme switching — uncomment to enable
;; (defun my/load-theme-by-time ()
;;   "Load dark theme at night (19:00–07:00), light theme during the day."
;;   (let ((hour (string-to-number (format-time-string "%H"))))
;;     (if (and (>= hour 7) (< hour 19))
;;         (load-theme 'doom-one-light t)
;;       (load-theme 'doom-one t))))
;; (add-hook 'emacs-startup-hook #'my/load-theme-by-time)

;; ─────────────────────────────────────────────────────────────
;; solaire-mode — visually dim non-file buffers (sidebars, popups)
;; Only useful in GUI; skip entirely in terminal to avoid color glitches.
;; ─────────────────────────────────────────────────────────────
(when (display-graphic-p)
  (use-package solaire-mode
    :ensure t
    :demand t
    :after doom-themes               ; must load after theme is active
    :config
    ;; solaire-global-mode is the correct entry point (not the hooks approach).
    ;; The hooks approach (change-major-mode + solaire-mode-swap-bg) was the
    ;; old API and causes face flickering on Emacs 29+.
    (solaire-global-mode +1)))

;; ─────────────────────────────────────────────────────────────
;; doom-modeline
;; ─────────────────────────────────────────────────────────────
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height                25)
  (doom-modeline-bar-width              3)
  (doom-modeline-window-width-limit     fill-column)
  ;; Content
  (doom-modeline-buffer-encoding        nil)   ; rarely useful
  (doom-modeline-minor-modes            nil)   ; too noisy
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-major-mode-icon        t)
  (doom-modeline-major-mode-color-icon  t)
  (doom-modeline-checker-simple-format  nil)   ; full flymake/flycheck counts
  (doom-modeline-env-version            t)     ; show py/go/ruby version
  (doom-modeline-lsp                    t)     ; eglot/lsp-mode status
  (doom-modeline-vcs-max-length         16)    ; slightly longer branch names
  (doom-modeline-github                 nil)   ; needs a token; off by default
  ;; Icons: only render in GUI — in terminal they show as garbage characters
  (doom-modeline-icon (display-graphic-p))
  :config
  ;; Terminal-specific overrides
  (unless (display-graphic-p)
    (setq doom-modeline-height                  1
          doom-modeline-icon                    nil
          doom-modeline-major-mode-icon         nil
          doom-modeline-buffer-file-name-style  'truncate-with-project)))

;; ─────────────────────────────────────────────────────────────
;; highlight-line — subtle current-line highlight
;; ─────────────────────────────────────────────────────────────
(global-hl-line-mode 1)

;; ─────────────────────────────────────────────────────────────
;; Pixel-smooth scrolling (Emacs 29+)
;; Gracefully no-ops in terminal and older Emacs.
;; ─────────────────────────────────────────────────────────────
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; ─────────────────────────────────────────────────────────────
;; macOS titlebar (no-op on Linux/Ubuntu — harmless to leave in)
;; ─────────────────────────────────────────────────────────────
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))

(provide 'ui)
;;; ui.el ends here
