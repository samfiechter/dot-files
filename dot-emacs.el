;; central backup repo (if the dir is there
(if (file-exists-p (concat (getenv "HOME") "/.emacs-backup")) 
    (progn 
      (setq backup-directory-alist '(("." .  (concat (getenv "HOME") "/.emacs-backup"))))
      (setq delete-old-versions t
	    kept-new-versions 6
	    kept-old-versions 2
	    version-control t )
      )
  )

(setq comment-column 80)


(global-set-key   "\C-?" 'help)
(global-set-key   [f1]    'describe-binding)
(global-set-key   [f2]    'goto-line)

(defun indent-buffer ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key "" 'comment-or-uncomment-region) ; C-\\ is comment

(defun set-comment-indent ()
  (local-set-key (kbd "#") 'comment-indent ))
(add-hook 'perl-mode-hook 'set-comment-indent)

(global-set-key   [f3]    'calc)
(global-set-key   [f4]    'shell)

(defun compile-or-eval () "Eval lisp buffers on f5" (interactive)
  (if (or (string= ".el" (substring (buffer-name) -3)) (string= ".emacs" (buffer-name)))
      (progn (eval-buffer) (message "Buffer Eval'd!"))
    (compile compile-command) ) )

(global-set-key   [f5]    'compile-or-eval)

(global-set-key   [f6]    'ispell-buffer)

(setq http-error-command "tail -f /var/log/apache2/error_log" )

(defun http-error-log ()
  (interactive)
  (async-shell-command  http-error-command)
  (switch-to-buffer "*Async Shell Command*")
  (rename-buffer "error.log"))

(global-set-key   [f7]    'http-error-log)
(global-set-key   [f8]    'rename-buffer)
(global-set-key   [f9]    'query-replace)
(global-set-key   [f10]   'replace-string)
(global-set-key   [f11]   'repeat-complex-command)
(global-set-key   [f12]   'list-buffers)


(global-set-key   "\C-h"        'delete-backward-char)
(global-set-key   [end]    'end-of-line)
(global-set-key   [home]   'beginning-of-line)

(global-set-key "\215" (quote complete-tag))  ;; alt-return is complete tag

(global-set-key (quote [M-right]) (quote next-multiframe-window))
(global-set-key (quote [M-left]) (quote previous-multiframe-window))

(global-unset-key (kbd "M-SPC"))
(global-set-key (kbd "M-SPC") (quote set-mark-command))

(setq inhibit-startup-message t)

(add-to-list 'same-window-buffer-names "*Async Shell Command*")
(add-to-list 'same-window-buffer-names "*shell*")
(add-to-list 'same-window-buffer-names "*Shell*")
(add-to-list 'same-window-buffer-names "*Help*")
(add-to-list 'same-window-buffer-names "*compilation*")
(add-to-list 'same-window-buffer-names "*Buffer List*")
                                        ;(add-to-list 'same-window-buffer-names "*Completions*")


(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (c++-mode . "k&r")
                        (other . "k&r")))

(add-to-list 'load-path "~/.emacs.d/")

(load "2048-game.el")
(load "flymake-settings.el")
(flymake-settings )
(load "flymake-cssparse.el")
(load "flymake-jslint.el")
(load "flymake-cursor.el")

;;(add-hook 'js-mode-hook 'flymake-jslint-init)

(add-hook 'js-mode-hook
          (lambda () (flymake-mode t)  ))
(add-hook 'css-mode-hook
          (lambda () (flymake-mode t)))
(add-hook 'c++-mode-hook
          (lambda () (flymake-mode t)))

(global-set-key (quote [67108910]) (quote flymake-goto-next-error))  ; cntl-. is next error

(setq tags-revert-without-query t) ;; autoload tags file
(setq tags-add-tables t) ;; when a new tabe is added then add;
(defun load-tags-if-there ()
  (interactive)
  (if (file-exists-p "TAGS" )
      (visit-tags-table "TAGS" )
    nil))

(defun switch-to-buffer-and-load-tags ()
  (interactive)
  (ido-switch-buffer)
  (load-tags-if-there))
(global-unset-key "b")
(global-set-key "b" 'switch-to-buffer-and-load-tags)
(add-hook 'find-file-hook 'load-tags-if-there)

(setq-default c-basic-offset 4)

(setq column-number-mode t)

(fmakunbound 'c-mode)
(makunbound 'c-mode-map)
(fmakunbound 'c++-mode)
(makunbound 'c++-mode-map)
(makunbound 'c-style-alist)

(autoload 'c++-mode  "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode    "cc-mode" "C Editing Mode" t)
(autoload 'objc-mode "cc-mode" "Objective-C Editing Mode" t)
(setq auto-mode-alist
      (append '(("\\.C$"  . c++-mode)
                ("\\.cc$" . c++-mode)
                ("\\.hh$" . c++-mode)
                ("\\.pc$" . c++-mode)
                ("\\.c$"  . c-mode)
                ("\\.h$"  . c-mode)
                ("\\.m$"  . objc-mode)
                ("\\.latex$" . latex-mode)
                ("\\.js$" . js-mode)
                ) auto-mode-alist))

(if (eq window-system 'x)
    (setq transient-mark-mode t))

(setq c-tab-always-indent t)

(setq c-auto-newline t)
(setq c-continued-brace-offset 0)

(setq c-indent-level 3)
(setq c-continued-statement-offset 0)
(setq c-brace-offset 0)

(setq c-argdecl-indent 0)
(setq c-label-offset -5)
(define-key global-map "\M-OM" 'newline)

(if (file-exists-p "/usr/bin/pbpaste")
    (progn    (defun mac-copy ()
		(shell-command-to-string "pbpaste"))

	      (defun mac-paste (text &optional push)
		(let ((process-connection-type nil))
		  (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
		    (process-send-string proc text)
		    (process-send-eof proc))))

	      (setq interprogram-cut-function 'mac-paste)
	      (setq interprogram-paste-function 'mac-copy)
	      ) nil )

(setq c++-electric-colon nil)

(setq-default line-number-mode t)

(setq search-repeat-char 19)
(setq compile-command "make")

(setq special-display-buffer-names
      '("*compilation*"))

(setq special-display-function
      (lambda (buffer &optional args)
        (switch-to-buffer buffer)
        (get-buffer-window buffer 0)))
v

(setq latex-mode-hook
      '(lambda ()
         (setq compile-command "make pdf")
         ))

(global-set-key "\C-c\C-r" 'center-region)
(global-set-key "\C-c\C-l" 'center-line)
(global-set-key "\C-c\C-p" 'center-paragraph)
(global-set-key [delete] 'delete-char)
(global-set-key [backspace] 'delete-backward-char)
(global-set-key "\C-x j" 'indent-region)
(define-key global-map "\M-g" 'goto-line)
(define-key global-map "\C-O" 'isearch-forward-regexp)

;;; date stuff
(set-variable (quote display-time-day-and-date) t)
(set-variable (quote display-time-interval) 30)
(display-time )

(setq auto-mode-alist (cons '("Makefile" . makefile-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("makefile" . makefile-mode) auto-mode-alist))


;;;; pressing ESC-ESC is a pain, undefine it ...
(global-unset-key "\e\e")

(put 'upcase-region 'disabled nil)
(global-unset-key "\e[")
(global-set-key   [hpDeleteChar]       'delete-char)

         

(if (file-exists-p "/opt/local/bin/aspell")
    (setq-default ispell-program-name "/opt/local/bin/aspell") nil)
(setq-default ispell-extra-args '("--reverse"))

(desktop-save-mode 1)
(setq default-directory "~/")