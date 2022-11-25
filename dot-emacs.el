(when window-system (set-frame-size (selected-frame) 240 65))
(add-to-list 'default-frame-alist '(height . 65))
(add-to-list 'default-frame-alist '(width . 240))

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
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/") t)
  (package-initialize)
  )



;;(load "2048-game.el")

;; (load "flymake-settings.el")
;; (flymake-settings )
;; (load "flymake-cssparse.el")
;; (load "flymake-jslint.el")
;; (load "flymake-cursor.el")

(if (fboundp 'multi-web-mode )
    (progn
      (multi-web-global-mode 1)
      (setq mweb-default-major-mode 'html-mode)
      (setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
                        (js-mode "<script[^>]*>" "</script>")
                        (css-mode "<style[^>]*>" "</style>")))
      (setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
      ) nil )



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
                   (setq output-string (concat output-string (substring (thing-at-point 'line) 0 -1) "\t" "\n"))
                   (next-line) ))
               (let (( p (point)))
                 (insert output-string)
                 (comment-region p (point)))
               ))
      (global-set-key (kbd "\C-x g") 'insert-figlet) )
  )

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
(global-set-key (kbd "s-/") `comment-or-uncomment-region)
(global-set-key  (kbd "s-\\") `comment-or-uncomment-region)

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
  (eww (concat "https://www.google.com/search?q=" (url-encode-url url))))

(global-set-key   (kbd "C-M-g") 'web-search)



(global-set-key   (kbd "s-x")     'execute-extended-command) ;; s-x is execute
(global-set-key   [M-up]    'scroll-down-command)
(global-set-key   [M-down]  'scroll-up-command)

(global-set-key   (kbd "C-x x") 'previous-buffer)

(global-set-key   (kbd "C-?") 'help)

(global-set-key   [s-f1]    'describe-keymap)
(global-set-key   [C-f1]    'describe-key)
(global-set-key   [M-f1]    'describe-function)

(defun visit-tag-or-goto-line (tag-or-line) "either jump to  a line or visit a tag"
       (interactive (find-tag-interactive "Line Number or Tag"))
       (let* ((isnumber (string-match " *\\([0-9]+\\) *" tag-or-line))
              (line (if isnumber (string-to-number (match-string 1 tag-or-line)))))
         (if (and isnumber (equal 0 tag-or-line))  (goto-line line) (find-tag tag-or-line)   ))
       )

(global-set-key   [f2]    'visit-tag-or-goto-line)

(global-set-key   (kbd "C-s-\\") (lambda ()
                                   (interactive)
                                   (switch-to-buffer "*scratch*")))

(global-set-key [end] (lambda () (intereactive) ((goto-char (point-max)))))
(global-set-key [home] (lambda () (intereactive) ((goto-char (point-min)))))



(global-set-key [C-s-?] 'describe-key)
(defun indent-buffer ()
  "Indent Whole Buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (message "Indenting buffer...")
  (untabify (point-min) (point-max))
  )

(defun indent-region-or-buffer ()
  "if anything is highlighted indent it, or indent the buffer"
  (interactive)
  (if mark-active
      (indent-region) (indent-buffer)))


(defun set-comment-indent ()
  (local-set-key (kbd "#") 'comment-indent ))

(add-hook 'perl-mode-hook 'set-comment-indent)

(add-hook 'flymake-mode-hook (lambda () (interactive) (setq flymake-gui-warnings-enabled nil)))




(global-set-key   [f3]    'indent-region-or-buffer)
(global-set-key   [f4]    'shell)
(global-set-key   [M-f4]    'term)

(setq compile-command "make")
(defun compile-or-eval () "Eval lisp buffers on f5"
       (interactive)
       (let ((isdotemacs (string= ".emacs" (buffer-file-name)))
	     (isdotel  (string= ".el" (substring (buffer-file-name) -3))) ) 
	     
         (if (or isdotel isdotemacs)
             (progn
               (if (and (not isdotemacs) (string-match "\\\\(provide '\\(.*?\\)\\\\)" (buffer-string))) ;; if this is a library, unload it befor loading it...
                   (unload-feature (match-string 1 (buffer-string))) nil )
               (eval-buffer)
               (let* ((quote (char-to-string 39))
                      (fns (split-string (shell-command-to-string (concat "cat TAGS | awk -F, " quote "/^\\// {print $1}" quote)) "\n"))
                      (add "")
                      )
                 (add-to-list 'fns (buffer-file-name)) ;;redo tags for other files in tag file
                 (setq fns (remove "" fns))
                 (dolist (fn  (delete-dups  fns))
                   (if (string-match "\\/.emacs$" fn) (setq fn (concat "-l lisp " fn)))
                   (shell-command (concat "etags " add fn))
                   (setq add " -a ")
                   )
                 (load-tags-if-there)
                 (message "Buffer Eval'd! (tags loaded)"))
               )
           (compile compile-command)
           )
         ))
(global-set-key [f5] 'compile-or-eval)
(global-set-key [M-f5] 'edebug-defun)
(global-set-key [M-ret] 'complete-tag)
(global-set-key [M-tab] 'complete-tag)

(defun ispell-sam ()
  "spell either the buffer or region"
  (if mark-active
      (ispell-region)
    (ispell buffer)))

(global-set-key   [f6]    'ispell-sam)
(setq http-error-command "tail -f /var/log/apache2/error_log" )

(defun http-error-log ()
  (async-shell-command  http-error-command)
  (switch-to-buffer "*Async Shell Command*")
  (rename-buffer "error.log"))

(global-set-key   [f7]    'http-error-log)
(global-set-key   [f8]    'rename-buffer)
(global-set-key   [f9]    'query-replace)
(global-set-key   [f10] 'web-search)
(global-set-key   [f11]   'repeat-complex-command)
(global-set-key   [f12]   'list-buffers)

(global-unset-key (kbd "C-h"))
(global-set-key   (kbd "C-h") 'delete-backward-char)
(global-set-key   [end]    'end-of-line)
(global-set-key   [home]   'beginning-of-line)



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


(defun jslint-setup-sam () "Configurings for js-lint"
       (progn
         (add-hook 'js-mode-hook 'flymake-jslint-init)
         ))

(eval-after-load 'flymake-jslint 'jsline-setup-sam)

(if (fboundp 'flymake-mode)
    (progn
      (add-hook 'js-mode-hook
                (lambda () (flymake-mode t)  ))
      (add-hook 'css-mode-hook
                (lambda () (flymake-mode t)))
      (add-hook 'c++-mode-hook
                (lambda () (flymake-mode t)))
      (global-set-key (quote [67108910]) (quote flymake-goto-next-error))  ; cntl-. is next error
      ) nil )

(eval-after-load 'flymake-mode 'flymake-mode-sam)

(if (fboundp 'company-mode)
    (progn
      (add-hook 'js-mode-hook
                (lambda () (company-mode )))
      (add-hook 'css-mode-hook
                (lambda () (company-mode )))
      (add-hook 'c++-mode-hook
                (lambda () (company-mode )))
      (add-hook 'emacs-lisp-mode-hook
                (lambda () (company-mode )))
      ) nil )


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

;;(global-unset-key "b")
;;(global-set-key "C-M-b" 'switch-to-buffer-and-load-tags)
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


(setq special-display-buffer-names
      '("*compilation*"))

;; (setq special-display-function
;;       (lambda (buffer &optional args)
;;         (switch-to-buffer buffer)
;;         (get-buffer-window buffer 0)))


(setq latex-mode-hook
      (lambda ()
        (setq compile-command "make pdf")
        ))

(global-set-key "\C-c\C-r" 'center-region)
(global-set-key "\C-c\C-l" 'center-line)
(global-set-key "\C-c\C-p" 'center-paragraph)
(global-set-key [delete] 'delete-char)
(global-set-key [backspace] 'delete-backward-char)
(global-set-key (kbd "\C-x j") 'find-tag)
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

(if (find-in-path "aspell")
    (progn
      (setq-default ispell-program-name (find-in-path "aspell"))
      (setq-default ispell-extra-args '("--reverse"))
      )
  (setq ispell-program-name (find-in-path "ispell"))
  )





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
 '(package-selected-packages
   '(dap-mode realgud-lldb dismal twittering-mode chess swift-mode))
 '(use-dialog-box nil)
 '(use-file-dialog nil))

(setq chess-images-default-size 64)
(setq chess-images-separate-frame nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;  ____       _                __        ___           _
;; / ___|  ___| |_ _   _ _ __   \ \      / (_)_ __   __| | _____      __
;; \___ \ / _ \ __| | | | '_ \   \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / /
;;  ___) |  __/ |_| |_| | |_) |   \ V  V / | | | | | (_| | (_) \ V  V /
;; |____/ \___|\__|\__,_| .__/     \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/
;;                      |_|
;;      _          __  __
;;  ___| |_ _   _ / _|/ _|
;; / __| __| | | | |_| |_
;; \__ \ |_| |_| |  _|  _|
;; |___/\__|\__,_|_| |_|

(add-to-list 'load-path  "~/iCloud/src/qs-mode")
(load "qs-mode.el")



(setq switch-to-buffer-obey-display-actions t)

(add-hook 'window-setup-hook
          (lambda ()
            (window-divider-mode 1)
            (split-window-right (- (window-total-width) 60))
            (next-window-any-frame)
            (find-file "~/.tmp.csv")
            (split-window-below (- (window-total-height) 40))
            (next-window-any-frame)
            (describe-keymap global-map)
            (next-window-any-frame)
            ))

(defun describe-my-map-other-window () "Describe the keymap in another window" (interactive)
       (let (

             (buf-names (mapcar 'buffer-name (buffer-list)))
             (cb (current-buffer))
             )

         (if (not (string= "*" (substring (buffer-name cb) 0 1)))
             (progn
               (switch-to-buffer-other-window "*Help*")
               (describe-bindings)
               (switch-to-buffer-other-window cb)
               )
           (describe-bindings)
           )))

(global-set-key   [f1]    'describe-my-map-other-window)
