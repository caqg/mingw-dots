;;;; -*- Emacs-Lisp -*- GNU Emacs Start-Up options

(load-file "~/.emacs-shared")
(load-library "cl")
(setq load-path (cons "~/.emacs.d" load-path))
(setq load-path (cons "~/.emacs.d/lisp" load-path))
;; (setq load-path (cons "~/.emacs.d/solarized-emacs" load-path))

(cond ((and (string-match "^GNU Emacs" (emacs-version))
            (>= emacs-major-version 21)
            window-system)
       (if (>= emacs-major-version 22)
           (setq font-lock-support-mode 'jit-lock-mode)
         (setq font-lock-support-mode 'lazy-lock-mode))
       (when (>= emacs-major-version 21)
         (defun zap-up-to-char (arg char)
           "Kill up to, but not including, ARG'th occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found."
           (interactive "p\ncZap to char: ")
           (kill-region (point) (progn
                                  (search-forward (char-to-string char) nil nil arg)
                                  (goto-char (if (> arg 0) (1- (point)) (1+ (point))))
                                  ))))

       ;; (add-to-list 'auto-mode-alist (cons "\\.gitconfig$" 'conf-unix-mode))
       (add-to-list 'auto-mode-alist (cons "bash\\.bashrc$" 'sh-mode))
       (add-to-list 'auto-mode-alist (cons "bash_completion$" 'sh-mode))

       (require 'ert)
       (package-initialize)
       (message "Initialized ELPA packages.")

       ;; These are known to work in v24, but may have existed since before.
       (which-function-mode 1)
       (filesets-init)

       (when t                          ;working around a problem in emacs24
         (require 'slime)
         (slime-setup))

       (require 'delsel)
       (pending-delete-mode t)

       ;; Known to work at least since v23, again don't know if before.
       (require 'gamegrid)
       (defun gamegrid-add-score-with-update-game-score-1( file target score ))

       (require 'uniquify)

       (add-hook 'dired-load-hook
                 #'(lambda ()
                     ;; Bind dired-x-find-file.
                     (setq dired-x-hands-off-my-keys nil)
                     (load "dired-x")
                     ))
       (require 'dired-x)

       (require 'xcscope)

       (require 'org-install)
       (add-to-list 'auto-mode-alist (cons "\\.org$" 'org-mode))
       (global-set-key "\C-cl" 'org-store-link)
       (global-set-key "\C-ca" 'org-agenda)
       (global-set-key "\C-cb" 'org-iswitchb)
       (setq org-todo-keywords
             '((sequence "TODO" "DOING" "PENDING" "|" "DONE" "DROPPED")))
       (setq org-log-done t)            ; or '(done) instead of t
       (setq org-agenda-include-diary t)
       (add-hook 'org-mode-hook #'(lambda () (require 'vc)))
       (add-hook 'org-mode-hook 'turn-on-font-lock)

       (require 'remember)
       (require 'org-remember)
       (org-remember-insinuate)
       (setq org-directory "~/Notes")
       (setq org-default-notes-file (concat org-directory "/notes.org"))
       (define-key global-map "\C-cr" 'org-remember)

       ;;(require 'markdown-mode)
       (add-to-list 'auto-mode-alist (cons "\\.md$" 'markdown-mode))
       (add-to-list 'auto-mode-alist (cons "\\.markdown$" 'markdown-mode))

       (require 'ede)
       (global-ede-mode t)
       (require 'semantic)
       (setq stack-trace-on-error nil) ;obsolete variable in Emacs 24.1, needed by
                                        ;ecb 2.40
       (setq ecb-version-check nil)
       (require 'ecb)
       (require 'cq-x-utils)
       (require 'font-lock)
       (require 'parenface)
       (require 'linum)

       (cond ((>= emacs-major-version 23)
              (require 'emacs23-theme-init)
              (set-color-theme-solarized-light)
              ;;(require 'solarized-theme)
              ;;(require 'emacs24-theme-init)
              )
             (nil                    ;work in progress
              (add-to-list 'custom-theme-load-path "~/.emacs.d/solarized-emacs")
              (require 'solarized)
              (load-theme 'solarized-dark)
              ))
       ))

(global-set-key [(meta z)] 'zap-up-to-char)
(global-set-key [(meta Z)] 'zap-to-char)

(wrap-up-start)
(when (memq window-system (list 'x 'w32))
  (set-default-xtitle)
  ;; (color-theme-solarized-dark)
  ;; (set-color-theme-solarized-light)
  )
(message "About to do custom-set-variables.")

;;;end ~/.emacs.d/init.el -- don't edit beyond

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(adaptive-fill-mode t)
 '(align-indent-before-aligning t)
 '(ansi-color-names-vector ["black" "light gray" "dark gray" "light slate gray"])
 '(background-color "#202020")
 '(background-mode dark)
 '(backup-by-copying-when-linked t)
 '(calendar-date-style (quote iso))
 '(calendar-mark-diary-entries-flag t)
 '(calendar-mark-holidays-flag t)
 '(calendar-week-start-day 1)
 '(case-fold-search t)
 '(column-number-mode t)
 '(compilation-scroll-output t)
 '(compile-command "time -p make LANG=C -j")
 '(completion-auto-help (quote lazy))
 '(cscope-close-window-after-select t)
 '(cscope-option-do-not-update-database t)
 '(cscope-option-use-inverted-index t)
 '(current-language-environment "UTF-8")
 '(cursor-color "#cccccc")
 '(custom-safe-themes (quote ("a53714de04cd4fdb92ed711ae479f6a1d7d5f093880bfd161467c3f589725453" "39dd7106e6387e0c45dfce8ed44351078f6acd29a345d8b22e7b8e54ac25bac4" "cab317d0125d7aab145bc7ee03a1e16804d5abdfa2aa8738198ac30dc5f7b569" "0c311fb22e6197daba9123f43da98f273d2bfaeeaeb653007ad1ee77f0003037" "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(default-frame-alist (quote ((width . 96) (height . 43) (menu-bar-lines . 1))))
 '(default-input-method "latin-postfix")
 '(delete-old-versions t)
 '(delete-selection-mode t)
 '(describe-char-unidata-list (quote (name old-name general-category decomposition mirrored iso-10646-comment)))
 '(develock-auto-enable nil)
 '(diary-file "~/.diary")
 '(diff-switches "-du")
 '(dired-auto-revert-buffer t)
 '(dired-dwim-target t)
 '(dired-isearch-filenames (quote dwim))
 '(dired-kept-versions 3)
 '(dired-listing-switches "-ADlh --time-style=long-iso")
 '(dired-use-ls-dired t)
 '(dired-x-hands-off-my-keys nil)
 '(display-time-mode t)
 '(ecb-auto-expand-tag-tree (quote all))
 '(ecb-compile-window-height 8)
 '(ecb-compile-window-width (quote edit-window))
 '(ecb-layout-name "left1")
 '(ecb-options-version "2.40")
 '(ecb-show-sources-in-directories-buffer (quote ("left7" "left9" "left13" "left14")))
 '(ecb-source-path (quote (("~" "Home") ("~/Work" "Work") ("~/Verifysys" "VerifySys"))))
 '(ecb-tip-of-the-day nil)
 '(ecb-toggle-layout-sequence (quote ("left9" "left14" "left7" "left1")))
 '(ecb-windows-width 0.25)
 '(ediff-custom-diff-options "-U10")
 '(ediff-prefer-iconified-control-frame t)
 '(ediff-show-clashes-only t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(ediff-use-toolbar-p nil)
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(enable-recursive-minibuffers t)
 '(explicit-shell-file-name "c:\\mingw\\msys\\1.0\\bin\\bash.exe")
 '(fill-column 78)
 '(filladapt-turn-on-mode-hooks (quote (text-mode-hook awk-mode-hook lisp-mode-hook emacs-lisp-mode-hook perl-mode-hook)))
 '(find-ls-option (quote ("-exec ls -Dlb --time-style=long-iso --group-directories-first {} +" . "-Dlb --time-style=long-iso --group-directories-first")))
 '(font-lock-maximum-size nil)
 '(foreground-color "#cccccc")
 '(gdb-enable-debug nil)
 '(gdb-many-windows t)
 '(gdb-max-frames 64)
 '(gdb-show-main t)
 '(gdb-speedbar-auto-raise t)
 '(gdb-stack-buffer-addresses t)
 '(gdb-use-separate-io-buffer t)
 '(global-ede-mode t)
 '(global-font-lock-mode t nil (font-lock))
 '(global-semantic-decoration-mode nil)
 '(global-semantic-highlight-func-mode t)
 '(global-semantic-idle-completions-mode t nil (semantic/idle))
 '(global-semantic-idle-scheduler-mode t)
 '(global-semantic-idle-summary-mode t)
 '(global-semantic-mru-bookmark-mode t)
 '(grep-command "grep -inHR -e ")
 '(grep-find-template "find . <X> -type f <F> -exec grep <C> -n -e <R> /dev/null {} +")
 '(grep-template "grep <X> <C> -n -e <R> <F>")
 '(home-end-enable t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote left))
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(line-move-visual nil)
 '(list-directory-brief-switches "-ACF")
 '(list-directory-verbose-switches "-lgaF --time-style=long-iso")
 '(ls-lisp-dirs-first t)
 '(ls-lisp-format-time-list (quote ("%Y-%m-%d %H:%M" "%Y-%m-%d     ")))
 '(mail-archive-file-name "~/mail/babyl/OUT")
 '(mail-use-rfc822 t)
 '(mouse-autoselect-window -0.25)
 '(mouse-wheel-mode t nil (mwheel))
 '(mouse-yank-at-point t)
 '(normal-erase-is-backspace (quote maybe))
 '(org-startup-indented t)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/") ("marmalade" . "http://marmalade-repo.org/packages/"))))
 '(recentf-mode t)
 '(require-final-newline nil)
 '(rmail-file-name "~/mail/babyl/RMAIL")
 '(scroll-bar-mode nil)
 '(scroll-conservatively 99)
 '(search-slow-window-lines 3)
 '(semantic-default-submodes (quote (global-semantic-highlight-func-mode global-semantic-stickyfunc-mode global-semantic-idle-completions-mode global-semantic-idle-scheduler-mode global-semanticdb-minor-mode global-semantic-idle-summary-mode global-semantic-mru-bookmark-mode)))
 '(semantic-mode t)
 '(set-mark-command-repeat-pop t)
 '(shell-popd-regexp "popd\\|-")
 '(shell-pushd-regexp "pushd\\|+")
 '(show-paren-mode t)
 '(show-paren-style (quote parenthesis))
 '(show-trailing-whitespace nil)
 '(spice-output-local "Gnucap")
 '(spice-simulator "Gnucap")
 '(spice-waveform-viewer "Gwave")
 '(tab-always-indent (quote complete))
 '(tabbar-mode t nil (tabbar))
 '(tabbar-mwheel-mode t nil (tabbar))
 '(text-mode-hook (quote (turn-on-auto-fill cq-text-mode text-mode-hook-identify)))
 '(tool-bar-mode nil nil (tool-bar))
 '(truncate-lines t)
 '(uniquify-buffer-name-style (quote post-forward-angle-brackets) nil (uniquify))
 '(use-file-dialog nil)
 '(user-mail-address "cesar.quiroz@gmail.com")
 '(visible-bell t)
 '(wdired-allow-to-change-permissions t)
 '(wdired-use-dired-vertical-movement (quote sometimes)))

(message "About to do custom-set-faces.")
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#fdf6e3" :foreground "#657b83" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "outline" :family "Consolas"))))
 '(org-hide ((((background light)) (:foreground "gray85")))))

(message "Now all done in init.el.")
