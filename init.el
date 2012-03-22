;;; init.el --- Emacs initialization module
;;
;; Copyright 2012 Google, Inc.
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;    http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;
;; Author: yesudeep@google.com (Yesudeep Mangalapilly)
;; Keywords: emacs, initialization
;;
;; This file is NOT part of GNU Emacs.
;;
;;; Commentary:
;;
;; Just clone the repo into ~/.emacs.d/
;;
;;; Code:
;;


;; ***************************************************************************
;; Automatically install default packages.
;; ---------------------------------------------------------------------------
;; This solves the problem of installing
;; these packages if you move between systems frequently and want them
;; to remain in a consistent state. You may have to close and restart
;; Emacs several times for the procedure to complete before it is
;; usable. I've had to do about 3 such restarts when doing a fresh clone.

(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; Automatically install these packages if they aren't present.
(when (not package-archive-contents)
  (package-refresh-contents))

;; Add in your own as you wish:
(defvar default-packages '(anything
                           anything-config
                           anything-complete
                           anything-match-plugin
                           anything-extension
                           anything-obsolete

                           autopair
                           gist
                           highlight-indentation
                           move-text
                           pymacs
                           pysmell
                           starter-kit
                           starter-kit-bindings
                           starter-kit-eshell
                           starter-kit-js
                           starter-kit-lisp
                           yasnippet
                           yasnippet-bundle

                           clojure-mode
                           clojurescript-mode
                           coffee-mode
                           go-mode
                           haskell-mode
                           less-css-mode
                           markdown-mode
                           ))

(dolist (p default-packages)
  (when (not (package-installed-p p))
    (package-install p)))


;; ***************************************************************************
;; Configuration root and other system paths.
;; ---------------------------------------------------------------------------

;; Configuration root.
(setq config-dir (file-name-directory (or (buffer-file-name) load-file-name)))
(setq vendor-library-dir (concat config-dir "vendor"))
(setq auto-complete-dict-dir (concat vendor-library-dir "auto-complete/dict"))
(setq snippets-dir (concat config-dir "snippets"))


(add-to-list 'load-path config-dir)
(add-to-list 'load-path vendor-library-dir)
(let ((default-directory vendor-library-dir))
  (normal-top-level-add-subdirs-to-load-path))
;; (let ((default-directory vendor-library-dir))
;;   (normal-top-level-add-to-load-path '("your" "subdirectories" "here")))


;; Functions to determine the platform on which we're running.
(defun system-type-is-darwin-p ()
  (interactive)
  "Return true if system is darwin-based (Mac OS X)"
  (string-equal system-type "darwin"))
(defun system-type-is-linux-p ()
  (interactive)
  "Return true if system is GNU/Linux-based."
  (string-equal system-type "gnu/linux"))


;;; A quick & ugly PATH solution to Emacs on Mac OSX
(if (system-type-is-darwin-p)
    (setenv "PATH" (concat "/usr/local/bin:/usr/bin" (getenv "PATH"))))
(setenv "PATH" (concat (concat config-dir "bin") (getenv "PATH")))

;;; Load up environment configuration for Mac OS X
(if (system-type-is-darwin-p)
    (require 'config-osx-environment))


;; ***************************************************************************
;; Automatically recompile the emacs init file on buffer-save or exit
;; ---------------------------------------------------------------------------
;; TODO: Write a module that automatically generates .elc files.
;; - on emacs load
;; - on buffer saves
;; - when .elc files are stale

(defun reload-user-init-file ()
  "thisandthat."
  (interactive)
  (byte-compile-user-init-file)
  (load-file (concat config-dir "init.el")))

(defun byte-compile-dotfiles ()
  "Byte compile all Emacs dotfiles."
  (interactive)
  ;; Automatically recompile the entire .emacs.d directory.
  (byte-recompile-directory (expand-file-name config-dir) 0))

(defun byte-compile-user-init-file ()
  (let ((byte-compile-warnings '(unresolved)))
    ;; in case compilation fails, don't leave the old .elc around:
    (when (file-exists-p (concat user-init-file ".elc"))
      (delete-file (concat user-init-file ".elc")))
    (byte-compile-file user-init-file)
    (byte-compile-dotfiles)
    ;; (message "%s compiled" user-init-file)
    ))

(defun onuserinitsave-auto-recompile ()
  (when (equal buffer-file-name user-init-file)
    (add-hook 'after-save-hook 'byte-compile-user-init-file t t)))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'onuserinitsave-auto-recompile)
(add-hook 'kill-emacs-hook 'byte-compile-user-init-file t t)

(setq abbrev-file-name (concat config-dir "abbrev_defs"))
(setq save-abbrevs t)
;;(quietly-read-abbrev-file)

(let ((byte-compile-warnings '(unresolved)))
  (when (not (file-exists-p (concat user-init-file ".elc")))
    (byte-compile-file user-init-file)
    (byte-compile-dotfiles)))


;; Automatically compile all modules on startup.
;; Don't enable this because it takes too much time
;; on Mac OS X.
;; (byte-compile-dotfiles)

;; Enable the menu bar.
(menu-bar-mode t)

;; Automatically remove trailing whitespace.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(require 'iedit)
(put 'narrow-to-region 'disabled nil)

;; Key bindings and editing.
(require 'move-text)
;;(move-text-default-bindings)
(require 'config-defuns)
(require 'config-bindings)

;; Auto-completion.
(require 'autopair)
(autopair-global-mode)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories auto-complete-dict-dir)
(ac-config-default)

(global-auto-complete-mode t)
;; (setq ac-auto-start 1)
;; (setq ac-dwim 1)
(setq ac-ignore-case 1)

;; Snippet completion.
(require 'yasnippet)
(setq yas/snippet-dirs '(snippets-dir))
(yas/initialize)
(yas/load-directory snippets-dir)
(yas/global-mode 1)


;; Programming language modes.
(require 'clojure-mode)
(require 'clojurescript-mode)
(require 'coffee-mode)
(require 'cljdoc)
(require 'markdown-mode)

;; Python-specific
;(require 'python)  ;; Disabled because it breaks a lot of shit.
(require 'cython-mode)
(require 'rst)

;; Defines the python coding style.
(defun set-python-coding-style ()
  (setq indent-tabs-mode nil)
  (setq require-final-newline 't)
  (setq tab-width 2)
  (setq py-indent-offset 2)
  (setq python-indent 2)
  )
(setq auto-mode-alist
      (append '(
                ("\\wscript$" . python-mode)
                ("\\.txt$" . rst-mode)
                ("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode))
              auto-mode-alist))
(add-hook 'rst-adjust-hook 'rst-toc-update)
(add-hook 'python-mode-hook 'set-python-coding-style)

;; Enable mouse scrolling in emacs terminal.
(unless window-system
  (xterm-mouse-mode 1)
  (global-set-key [mouse-4] '(lambda ()
                               (interactive)
                               (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                               (interactive)
                               (scroll-up 1))))


;; (require 'pymacs)
;; (require 'pysmell)
;; (add-hook 'python-mode-hook (lambda () (pysmell-mode 1)))

;; Don't use tabs when indenting in HTML mode.
(add-hook
 'html-mode-hook
 '(lambda ()
    (setq indent-tabs-mode nil)))

(require 'sr-speedbar)
(sr-speedbar-open)

;; Pastebin (gist.github.com)
(require 'gist)

;; Highlights indentation levels.
(require 'highlight-indentation)
(add-hook 'python-mode-hook 'highlight-indentation)
(add-hook 'coffee-mode-hook 'highlight-indentation)
(add-hook 'html-mode-hook 'highlight-indentation)

;;; init.el ends here
