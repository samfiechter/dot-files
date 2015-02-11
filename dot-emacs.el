
(defun find-in-path (cmd) "search the env-var $PATH for the file passed"
  (let ((path (split-string (getenv "PATH") ":"))
        (fullpath nil))
    (dolist (dir path)
      (if (file-exists-p (concat dir "/" cmd))
          (setq fullpath (concat dir "/" cmd))
        nil))
    fullpath))

(setenv "PATH" (concat (getenv "PATH") ":/Users/sam/bin:/usr/bin:/usr/local/bin"))
(add-to-list 'load-path  "~/.emacs.d/elpa/")


(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )


;;(load "2048-game.el")

;; (load "flymake-settings.el")
;; (flymake-settings )
;; (load "flymake-cssparse.el")
;; (load "flymake-jslint.el")
;; (load "flymake-cursor.el")


(require 'multi-web-mode)
(setq mweb-default-major-mode 'html-mode)
(setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
                  (js-mode "<script[^>]*>" "</script>")
                  (css-mode "<style[^>]*>" "</style>")))
(setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
(multi-web-global-mode 1)



(setq ispell-program-name (find-in-path "ispell"))


;;        __ _       _      _
;;       / _(_) __ _| | ___| |_
;;      | |_| |/ _` | |/ _ \ __|
;;      |  _| | (_| | |  __/ |_
;;add   |_| |_|\__, |_|\___|\__| text in a comment
;;             |___/

(defvar figlet-command (find-in-path "figlet"))
(if figlet-command
    (progn
      (defun insert-figlet (figlet-args) "Insert a figlet string (http://www.figlet.org/) into your buffer and comment it out"
        (interactive "sfiglet ")
        (let ((output-string "")
              (cs comment-start)
              (ce comment-end))
          (with-temp-buffer
            (shell-command (concat figlet-command " -w " (int-to-string fill-column) " " figlet-args) (current-buffer))
            (beginning-of-buffer)
            (while (not (eobp))
              (setq output-string (concat output-string  "\t" (substring (thing-at-point 'line) 0 -1) "\t" "\n"))
              (next-line) ))
          (let (( p (point)))
            (insert output-string)
            (comment-region p (point)))
          ))
      (global-set-key (kbd "\C-x g") 'insert-figlet) )
  nil)

(define-key help-map [left] 'help-go-back)
(define-key help-map [right] 'help-go-forward)

(defun delete-buffer () "call erase-buffer"
  (call-interactively  'erase-buffer))

(define-key lisp-interaction-mode-map (kbd "M-?") 'describe-function)
(define-key lisp-interaction-mode-map (kbd "C-x k") 'delete-buffer)
(define-key emacs-lisp-mode-map (kbd "M-?") 'describe-function)

;; central backup repo (if the dir is there
(let* ((savedir (concat (getenv "HOME") "/.emacs-backup"))
       (bdal (list (cons "." savedir))))
  (if (file-exists-p savedir)
      (progn
        (setq backup-directory-alist bdal)
        (setq delete-old-versions t
              kept-new-versions 6
              kept-old-versions 2
              version-control t )) ) )

(setq comment-column 80)



(defun kill-every-buffer-but-this-one ()
  "Kills all the buffers but this one" (interactive)
  (let ((bl (buffer-list)))
    (delete-other-windows)
    (dolist (b bl)
      (if (equal (current-buffer) b) (message (concat "Killing every buffer but " (buffer-name) "...")) (kill-buffer b)))))
(global-set-key (kbd "C-x K") 'kill-every-buffer-but-this-one)


(defun web-search (url)
  "search the google"
  (interactive "sQuery:")
  (eww (concat "https://duckduckgo.com/?q=" (url-encode-url url))))


(global-set-key   [8388728]     'execute-extended-command) ;; s-x is execute
(global-set-key   [M-up]    'scroll-down-command)
(global-set-key   [M-down]  'scroll-up-command)

(global-set-key   (kbd "C-x x") 'previous-buffer)
(global-set-key   (kbd "C-M-g") 'web-search)
(global-set-key   (kbd "C-?") 'help)
(global-set-key   [f1]    'help)
(global-set-key   [f2]    'goto-line)
(global-set-key   [C-s-268632092] (lambda () (interactive) (switch-to-buffer "*scratch*"))) ;; control-window-\ jump to scratch


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

(add-hook 'flymake-mode-hook (lambda () (interactive) (setq flymake-gui-warnings-enabled nil)))

(global-unset-key (kbd "M-|"))
(global-set-key   (kbd "M-|") (lambda () (interactive)
                                (if mark-active
                                    (indent-region) (indent-buffer))))

(global-set-key   [f3]    'indent-buffer)
(global-set-key   [f4]    'shell)

(defun compile-or-eval () "Eval lisp buffers on f5" (interactive)
  (if (or (string= ".el" (substring (buffer-name) -3)) (string= ".emacs" (buffer-name)))
      (progn (eval-buffer) (message "Buffer Eval'd!"))
    (compile compile-command) ) )

(global-set-key   [f5]    'compile-or-eval)
(defun ispell-sam ()
  "spell either the buffer or region"
  (interactive)
  (if (mark-active)
      (ispell-region)
    (ispell buffer)))

(global-set-key   [f6]    'ispell-sam)
(setq http-error-command "tail -f /var/log/apache2/error_log" )
(defun http-error-log ()
  (interactive)
  (async-shell-command  http-error-command)
  (switch-to-buffer "*Async Shell Command*")
  (rename-buffer "error.log"))
(global-set-key   [f7]    'http-error-log)
(global-set-key   [f8]    'rename-buffer)
(global-set-key   [f9]    'query-replace)
(global-set-key   [f10]   'calc)
(global-set-key   [f11]   'repeat-complex-command)
(global-set-key   [f12]   'list-buffers)

(global-unset-key (kbd "C-h"))
(global-set-key   (kbd "C-h")        'delete-backward-char)
(global-set-key   [end]    'end-of-line)
(global-set-key   [home]   'beginning-of-line)

(global-set-key "\215" (quote complete-tag))  ;; alt-return is complete tag

(global-set-key [M-right] (quote next-multiframe-window))
(global-set-key [M-left] (quote previous-multiframe-window))

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




;;(add-hook 'js-mode-hook 'flymake-jslint-init)

;; (add-hook 'js-mode-hook
;;           (lambda () (flymake-mode t)  ))
;; (add-hook 'css-mode-hook
;;           (lambda () (flymake-mode t)))
(add-hook 'c++-mode-hook
          (lambda () (flymake-mode t)))

(global-set-key (quote [67108910]) (quote flymake-goto-next-error))  ; cntl-. is next error

(setq tags-revert-without-query t) ;; autoload tags file
(setq tags-add-tables t) ;; when a new tabel is added then add;
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
                ("\\.cpp$" . c++-mode)
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

(if (find-in-path "pbpaste")
    (progn
      (defun mac-copy ()
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


(setq latex-mode-hook
      '(lambda ()
         (setq compile-command "make pdf")
         ))

(global-set-key "\C-c\C-r" 'center-region)
(global-set-key "\C-c\C-l" 'center-line)
(global-set-key "\C-c\C-p" 'center-paragraph)
(global-set-key [delete] 'delete-char)
(global-set-key [backspace] 'delete-backward-char)
(global-set-key (kbd "\C-x j") 'indent-region)
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

(let ((company-dir (concat (getenv "HOME") "/.emacs.d/elpa/company-0.7.3")))
  (if (file-exists-p company-dir)
      (progn
        (add-to-list 'load-path company-dir)
        (autoload 'company-mode "company" nil t)
        (add-hook 'perl-mode-hook 'company-mode)
        (add-hook 'emacs-lisp-mode-hook 'company-mode)
        (add-hook 'js-mode-hook 'company-mode)
        (add-hook 'css-mode-hook 'company-mode)
        (add-hook 'c++-mode-hook 'company-mode)
        )
    nil))


(setq default-directory "~/")
(setq debug-on-error t)

(defadvice yes-or-no-p (around prevent-dialog activate)
  "Prevent yes-or-no-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))
(defadvice y-or-n-p (around prevent-dialog-yorn activate)
  "Prevent y-or-n-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(use-dialog-box nil)
 '(use-file-dialog nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

