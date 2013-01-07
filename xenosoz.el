;;; xenosoz.el --- Personal configuration.
;;

(setq user-full-name "Xenosoz Hwang")
(setq user-mail-address "xenosoz.hwang@gmail.com")

;; Try to follow Google Python Style Guide.
(defun set-python-coding-style ()
  (setq indent-tabs-mode nil
        require-final-newline 't
        tab-width 4
        python-indent-offset 4
        python-indent 4
        py-indent-offset 4))

(add-hook 'python-mode-hook 'set-python-coding-style)


;; Auto enable markdown mode
;;(require 'markdown-mode)
(setq auto-mode-alist
      (append '(
                ("\\.md$" . markdown-mode))
              auto-mode-alist))

;; Amend gyp-mode.el
;;   from http://dxr.mozilla.org/mozilla-central/media/webrtc/trunk/tools/gyp/tools/emacs/gyp.el.html
(defadvice python-calculate-indentation (after ami-outdent-closing-parens
                                               activate)
  "De-indent closing parens, braces, and brackets in gyp-mode."
  (if (and (eq major-mode 'gyp-mode)
           (string-match "^ *[])}][],)}]* *$"
                         (buffer-substring-no-properties
                          (line-beginning-position) (line-end-position))))
      (setq ad-return-value (- ad-return-value python-indent))))

(defun set-gyp-coding-style ()
  (setq indent-tabs-mode nil
        require-final-newline 't
        tab-width 2
        python-indent-offset 2
        python-indent 2
        py-indent-offset 2))

(add-hook 'gyp-mode-hook 'set-gyp-coding-style)

;;; xenosoz.el ends here.
