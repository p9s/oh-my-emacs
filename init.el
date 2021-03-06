;;; init.el --- Where all the magic begins
;;
;; Part of the oh-my-emacs
;;
;; This is the first thing to get loaded.
;;

;; Toggle frame to maximized

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
  '(initial-frame-alist (quote ((fullscreen . maximized))))
  )
;; Global setup it use socket proxy
(setq url-gateway-method 'socks)
(setq socks-server '("Default server" "127.0.0.1" 1080 5))

(setq url-gateway-local-host-regexp
      (concat "\\`" (regexp-opt '("localhost" "127.0.0.1")) "\\'"))

;; Enter debugger if an error is signaled during Emacs startup.
;;
;; This works the same as you boot emacs with "--debug-init" every time, except
;; for errors in "init.el" itself, which means, if there's an error in
;; "init.el", "emacs --debug-init" will entering the debugger, while "emacs"
;; will not; however, if there's an error in other files loaded by init.el,
;; both "emacs" and "emacs --debug-init" will entering the debugger. I don't
;; know why.
(setq debug-on-error t)


(defvar ome-dir (file-name-directory (or load-file-name (buffer-file-name)))
  "oh-my-emacs home directory.")

;; believe me, you don't need menubar(execpt OSX), toolbar nor scrollbar
(and (fboundp 'menu-bar-mode)
     (not (eq system-type 'darwin))
     (menu-bar-mode -1))
(dolist (mode '(tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;; Now install el-get at the very first
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(add-to-list 'load-path "~/.emacs.d/el-get/helm-projectile")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch
          ;; do not build recipes from emacswiki due to poor quality and
          ;; documentation
          el-get-install-skip-emacswiki-recipes)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  ;; build melpa packages for el-get
  (el-get-install 'package)
  (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                           ("melpa" . "http://melpa.org/packages/")))
  (el-get-elpa-build-local-recipes))

;; enable git shallow clone to save time and bandwidth
(setq el-get-git-shallow-clone t)

;; Sometimes, we need to experiment with our own recipe, or override the
;; default el-get recipe to get around bugs.
(add-to-list 'el-get-recipe-path (expand-file-name "ome-el-get-recipes" ome-dir))

;; tell el-get to look into local customizations for every package into
;; `~/.emacs.d/init-<package>.el'
(setq el-get-user-package-directory "~/.emacs.d")

;; Some workaround for emacs version < 24.0, thanks Silthanis@github.
(if (< emacs-major-version 24)
    (defun file-name-base (&optional filename)
      "Return the base name of the FILENAME: no directory, no extension.
FILENAME defaults to `buffer-file-name'."
      (file-name-sans-extension
       (file-name-nondirectory (or filename (buffer-file-name))))))

;; Oh-my-emacs adopt org-mode 8.x from v0.3, so org-mode should be the first
;; package to be installed via el-get
(defun ome-org-mode-setup ()
  ;; markdown export support
  (require 'ox-md))

(add-to-list 'el-get-sources
             '(:name org-mode
                     :after (progn
                              (ome-org-mode-setup))))

(el-get 'sync (mapcar 'el-get-source-name el-get-sources))

;; load up the ome
(org-babel-load-file (expand-file-name "ome.org" ome-dir))

;;; init.el ends here

;; Setup my color schema themes
(load-theme 'railscasts t nil)


;; Setup for Starter Kit Perl

(eval-after-load 'cperl-model
  '(progn
     (define-key cperl-mode-map (kbd "RET" ) 'reindent-then-newline-and-indent)
     (define-key cperl-mode-map (kbd "C-M-h") 'backward-kill-word ) ))

(global-set-key (kbd "C-h P") 'perldoc )

(add-to-list 'auto-mode-alist '("\\.p[lm]$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pod$" . pod-mode ) )
(add-to-list 'auto-mode-alist '("\\.tt$" . tt-mode ))

;; setup plenv
(require 'plenv)


;; Setup pomodoro
(require 'pomodoro)
;;(pomodoro-add-to-mode-line)
(setq org-pomodoro-length 25)
(setq org-pomodoro-short-break-length 3)
(setq org-pomodoro-long-break-length 10)
(setq org-pomodoro-play-sounds 1)

(defun notify-osx (title message)
  (call-process "terminal-notifier"
                nil 0 nil
                "-group" "Emacs"
                "-title" title
                "-sender" "org.gnu.Emacs"
                "-message" message
                "-activate" "org.gnu.Emacs"
                ))

(add-hook 'org-pomodoro-finished-hood
          (lambda ()
            (notify-osx "Pomodoro completed!" "Time for a break.")))
(add-hook 'org-pomodoro-break-finished-hood
          (lambda ()
            (notify-osx "Pomodoro Sort Break Finished" "Ready for Another?")))
(add-hook 'org-pomodoro-long-break-finished-hood
          (lambda ()
            (notify-osx "Pomodoro Long Break Finished" "Ready for Another?")))
(add-hook 'org-pomodoro-killed-hook
          (lambda()
            (notify-osx "Pomodo Killed" "One does not simply kill a pomodoro!")))


;; Mutiple windows switch
(require 'window-numbering )
(window-numbering-mode 1 )
(setq window-numbering-assign-func
      (lambda () (when (equal (buffer-name) "*Calculator*") 9)))
