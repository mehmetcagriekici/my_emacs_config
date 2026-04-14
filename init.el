;;; init.el --- Mehmet Çağrı's personal Emacs configuration -*- lexical-binding: t; -*-

;; ─────────────────────────────────────────────────────────────
;; Performance: disable GC during startup
;; ─────────────────────────────────────────────────────────────
(setq gc-cons-threshold  most-positive-fixnum
      gc-cons-percentage 0.6)

;; ─────────────────────────────────────────────────────────────
;; Package system bootstrap — must happen before anything else
;; ─────────────────────────────────────────────────────────────
(setq package-enable-at-startup nil)

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(setq package-archive-priorities
      '(("nongnu" . 30)
        ("gnu"    . 20)
        ("melpa"  . 10)))
(package-initialize)

;; ─────────────────────────────────────────────────────────────
;; Custom file — load BEFORE package installation so that
;; package-selected-packages is populated when we need it
;; ─────────────────────────────────────────────────────────────
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

;; ─────────────────────────────────────────────────────────────
;; Refresh package contents
;; ─────────────────────────────────────────────────────────────
(unless package-archive-contents
  (package-refresh-contents))

;; Bootstrap use-package (built-in on Emacs 29, guard for safety)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer  t
      use-package-expand-minimally t
      use-package-compute-statistics t
      use-package-verbose nil)

;; ─────────────────────────────────────────────────────────────
;; Install all selected packages on first launch (self-healing)
;; Now that use-package is loaded, install remaining packages
;; ─────────────────────────────────────────────────────────────
(package-install-selected-packages :noconfirm)

;; ─────────────────────────────────────────────────────────────
;; Load-path for personal modules
;; ─────────────────────────────────────────────────────────────
(let ((lisp-dir (expand-file-name "lisp" user-emacs-directory)))
  (when (file-directory-p lisp-dir)
    (add-to-list 'load-path lisp-dir)))

;; ─────────────────────────────────────────────────────────────
;; Modular configuration
;; Note: packages module is removed — bootstrap is handled above
;; ─────────────────────────────────────────────────────────────
(defvar my/modules
  '(basics          ; general settings, keys, env
    helpers         ; utility functions / macros
    ui              ; theme, modeline, fonts, fringes
    completion      ; vertico, corfu, consult, orderless...
    treesitter      ; treesit setup & grammars
    languages       ; major-mode defaults, indentation etc.
    lsp             ; eglot / lsp-mode
    git-projects    ; magit, projectile, consult-projectile...
    eshell-terminal ; eshell + vterm
    )
  "List of personal configuration modules to load.")

(dolist (module my/modules)
  (condition-case-unless-debug err
      (require module nil 'noerror)
    (error
     (warn "Failed to load module %s: %s" module (error-message-string err)))))

;; ─────────────────────────────────────────────────────────────
;; Mark all themes as safe
;; ─────────────────────────────────────────────────────────────
(setq custom-safe-themes t)

;; ─────────────────────────────────────────────────────────────
;; Final startup tweaks
;; ─────────────────────────────────────────────────────────────
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold  (* 64 1024 1024)
                  gc-cons-percentage 0.1)
            (message "Emacs ready in %.2f seconds with %d garbage collections."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

(provide 'init)
;;; init.el ends here
