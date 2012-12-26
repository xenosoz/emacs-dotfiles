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

(set-python-coding-style)

;;; xenosoz.el ends here.
