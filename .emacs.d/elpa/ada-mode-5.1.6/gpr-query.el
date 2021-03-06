;;; gpr-query.el --- minor-mode for navigating sources using the
;;; custom gpr_query tool, based on AdaCore cross reference tool
;;; gnatinspect.
;;;
;;; gpr-query supports Ada and any gcc language that supports the
;;; AdaCore -fdump-xref switch (which includes C, C++).
;;
;;; Copyright (C) 2013, 2014  Free Software Foundation, Inc.

;; Author: Stephen Leake <stephen_leake@member.fsf.org>
;; Maintainer: Stephen Leake <stephen_leake@member.fsf.org>
;; Version: 1.0

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Usage:
;;
;; M-x gpr-query

(require 'ada-mode) ;; for ada-prj-*, some other things
(require 'gnat-core)
(require 'cl-lib)
(require 'compile)

;;;;; sessions

;; gpr_query reads the project files and the database at startup,
;; which is noticeably slow for a reasonably sized project. But
;; running queries after startup is fast. So we leave gpr_query
;; running, and send it new queries via stdin, getting responses via
;; stdout.
;;
;; We maintain a cache of active sessions, one per gnat project.

(cl-defstruct (gpr-query--session)
  (process nil) ;; running gpr_query
  (buffer nil)) ;; receives output of gpr_query

(defconst gpr-query-buffer-name-prefix " *gpr_query-")

(defun gpr-query--start-process (session)
  "Start the session process running gpr_query."
  (unless (buffer-live-p (gpr-query--session-buffer session))
    ;; user may have killed buffer
    (setf (gpr-query--session-buffer session) (gnat-run-buffer gpr-query-buffer-name-prefix)))

  (with-current-buffer (gpr-query--session-buffer session)
    (let ((process-environment (ada-prj-get 'proc_env)) ;; for GPR_PROJECT_PATH

	  (project-file (file-name-nondirectory (ada-prj-get 'gpr_file))))
      (erase-buffer); delete any previous messages, prompt
      (setf (gpr-query--session-process session)
	    ;; gnatcoll-1.6 can't handle aggregate projects; M910-032
	    ;; gpr_query can handle some aggregate projects, but not all
	    ;; FIXME: need good error message on bad project file:
	    ;; 		"can't handle aggregate projects?")
	    (start-process (concat "gpr_query " (buffer-name))
			   (gpr-query--session-buffer session)
			   "gpr_query"
			   (concat "--project=" project-file)))
      (set-process-query-on-exit-flag (gpr-query--session-process session) nil)
      (gpr-query-session-wait session)

      ;; check for warnings about invalid directories etc
      (goto-char (point-min))
      (when (search-forward "warning:" nil t)
	(error "gpr_query warnings"))
      )))

(defun gpr-query--make-session ()
  "Create and return a session for the current project file."
  (let ((session
	 (make-gpr-query--session
	  :buffer (gnat-run-buffer gpr-query-buffer-name-prefix))))
    (gpr-query--start-process session)
    session))

(defvar gpr-query--sessions '()
  "Assoc list of sessions, indexed by absolute GNAT project file name.")

(defun gpr-query-cached-session ()
  "Return a session for the current project file, creating it if necessary."
  (let* ((session (cdr (assoc ada-prj-current-file gpr-query--sessions))))
    (if session
	(progn
	  (unless (process-live-p (gpr-query--session-process session))
	    (gpr-query--start-process session))
	  session)
      ;; else
      (prog1
          (setq session (gpr-query--make-session))
	(setq gpr-query--sessions
	      (cl-acons ada-prj-current-file session gpr-query--sessions))))
    ))

(defconst gpr-query-prompt "^>>> $"
  ;; gpr_query output ends with this
  "Regexp matching gpr_query prompt; indicates previous command is complete.")

(defun gpr-query-session-wait (session)
  "Wait for the current command to complete."
  (unless (process-live-p (gpr-query--session-process session))
    (gpr-query-show-buffer session)
    (error "gpr-query process died"))

  (with-current-buffer (gpr-query--session-buffer session)
    (let ((process (gpr-query--session-process session))
	  (search-start (point-min))
	  (wait-count 0))
      (while (and (process-live-p process)
		  (progn
		    ;; process output is inserted before point, so move back over it to search it
		    (goto-char search-start)
		    (not (re-search-forward gpr-query-prompt (point-max) 1))))
	(setq search-start (point));; don't search same text again
	(message (concat "running gpr_query ..." (make-string wait-count ?.)))
	;; FIXME: use --display-progress
	(accept-process-output process 1.0)
	(setq wait-count (1+ wait-count)))
      (if (process-live-p process)
	  (message (concat "running gpr_query ... done"))
	(gpr-query-show-buffer session)
	(error "gpr_query process died"))
      )))

(defun gpr-require-prj ()
  "Throw error if no project file defined."
  (unless (or (ada-prj-get 'gpr_file)
	      (ada-prj-get 'gpr_query_file))
    (error "no gpr project file defined.")))

(defun gpr-query-session-send (cmd wait)
  "Send CMD to gpr_query session for current project.
If WAIT is non-nil, wait for command to complete.
Return buffer that holds output."
  (gpr-require-prj)
  (let ((session (gpr-query-cached-session)))
    ;; always wait for previous command to complete; also checks for
    ;; dead process.
    (gpr-query-session-wait session)
    (with-current-buffer (gpr-query--session-buffer session)
      (erase-buffer)
      (process-send-string (gpr-query--session-process session)
			   (concat cmd "\n"))
      (when wait
	(gpr-query-session-wait session))
      (current-buffer)
      )))

(defun gpr-query-kill-session (session)
  (let ((process (gpr-query--session-process session)))
    (when (process-live-p process)
      (process-send-string (gpr-query--session-process session) "exit\n")
      (while (process-live-p process)
    	(accept-process-output process 1.0)))
    ))

(defun gpr-query-kill-all-sessions ()
  (interactive)
  (let ((count 0))
    (mapc (lambda (assoc)
	    (let ((session (cdr assoc)))
	      (when (process-live-p (gpr-query--session-process session))
		(setq count (1+ count))
		(process-send-string (gpr-query--session-process session) "exit\n")
		)))
	    gpr-query--sessions)
    (message "Killed %d sessions" count)
    ))

(defun gpr-query-show-buffer (&optional session)
  "For `ada-show-xref-tool-buffer'; show gpr-query buffer for current project."
  (interactive)
  (pop-to-buffer (gpr-query--session-buffer (or session (gpr-query-cached-session)))))

;;;;; utils

(defun gpr-query-get-src-dirs (src-dirs)
  "Append list of source dirs in current gpr project to SRC-DIRS.
Uses 'gpr_query'. Returns new list."

  (with-current-buffer (gpr-query--session-buffer (gpr-query-cached-session))
    (gpr-query-session-send "source_dirs" t)
    (goto-char (point-min))
    (while (not (looking-at gpr-query-prompt))
      (add-to-list 'src-dirs
		   (directory-file-name
		    (buffer-substring-no-properties (point) (point-at-eol))))
      (forward-line 1))
    )
  src-dirs)

(defun gpr-query-get-prj-dirs (prj-dirs)
  "Append list of source dirs in current gpr project to PRJ-DIRS.
Uses 'gpr_query'. Returns new list."

  (with-current-buffer (gpr-query--session-buffer (gpr-query-cached-session))
    (gpr-query-session-send "project_path" t)
    (goto-char (point-min))
    (while (not (looking-at gpr-query-prompt))
      (add-to-list 'prj-dirs
		   (directory-file-name
		    (buffer-substring-no-properties (point) (point-at-eol))))
      (forward-line 1))
    )
  prj-dirs)

(defconst gpr-query-ident-file-regexp
  ;; C:\Projects\GDS\work_dscovr_release\common\1553\gds-mil_std_1553-utf.ads:252:25
  ;; /Projects/GDS/work_dscovr_release/common/1553/gds-mil_std_1553-utf.ads:252:25
  "\\(\\(?:.:\\\|/\\)[^:]*\\):\\([0123456789]+\\):\\([0123456789]+\\)"
  ;; 1                          2                   3
  "Regexp matching <file>:<line>:<column>")

(defconst gpr-query-ident-file-regexp-alist
  (list (concat "^" gpr-query-ident-file-regexp) 1 2 3)
  "For compilation-error-regexp-alist, matching gpr_query output")

(defconst gpr-query-ident-file-type-regexp
  (concat gpr-query-ident-file-regexp " (\\(.*\\))")
  "Regexp matching <file>:<line>:<column> (<type>)")

;; debugging:
;; in *compilation-gpr_query-refs*, run
;;  (progn (set-text-properties (point-min)(point-max) nil)(compilation-parse-errors (point-min)(point-max) gpr-query-ident-file-regexp-alist))

(defun gpr-query-compilation (identifier file line col cmd comp-err)
  "Run gpr_query IDENTIFIER:FILE:LINE:COL CMD,
set compilation-mode with compilation-error-regexp-alist set to COMP-ERR."
  ;; Useful when gpr_query will return a list of references; we use
  ;; `compilation-start' to run gpr_query, so the user can navigate
  ;; to each result in turn via `next-error'.
  (let ((cmd-1 (format "%s %s:%s:%d:%d" cmd identifier file line col))
	(result-count 0)
	file line column)
    (with-current-buffer (gpr-query--session-buffer (gpr-query-cached-session))
      (compilation-mode)
      (setq buffer-read-only nil)
      (set (make-local-variable 'compilation-error-regexp-alist) (list comp-err))
      (gpr-query-session-send cmd-1 t)
      ;; point is at EOB. gpr_query returns one line per result plus prompt
      (setq result-count (- (line-number-at-pos) 1))
      (font-lock-fontify-buffer)
      ;; font-lock-fontify-buffer applies compilation-message text properties
      ;; IMPROVEME: for some reason, next-error works, but the font
      ;; colors are not right (no koolaid!)
      (goto-char (point-min))

      (cl-case result-count
	(0
	 (error "gpr_query returned no results"))
	(1
	 (when (looking-at "^Error: entity not found")
	   (error (buffer-substring-no-properties (line-beginning-position) (line-end-position))))

	 ;; just go there, don't display session-buffer. We have to
	 ;; fetch the compilation-message while in the session-buffer.
	 (let* ((msg (compilation-next-error 0 nil (point-min)))
		(loc (compilation--message->loc msg)))
	   (setq file (caar (compilation--loc->file-struct loc))
		 line (caar (cddr (compilation--loc->file-struct loc)))
		 column (1- (compilation--loc->col loc)))
	   ))

	(t
	 ;; for next-error, below
	 (setq next-error-last-buffer (current-buffer)))

	));; case, with-currrent-buffer

    (if (> result-count 1)
	;; more than one result; display session buffer, goto first ref
	;;
	;; compilation-next-error-function assumes there is not an error
	;; at point-min; work around that by moving forward 0 errors for
	;; the first one. Unless the first line contains "warning: ".
	(if (looking-at "^warning: ")
	    (next-error)
	  (next-error 0 t))

      ;; just one result; go there
      (ada-goto-source file line column nil))
    ))

(defun gpr-query-dist (found-line line found-col col)
  "Return distance between FOUND-LINE FOUND-COL and LINE COL."
  (+ (abs (- found-col col))
     (* (abs (- found-line line)) 250)))

;;;;; user interface functions

(defun gpr-query-show-references ()
  "Show all references of identifier at point."
  (interactive)
  (gpr-query-all
   (thing-at-point 'symbol)
   (file-name-nondirectory (buffer-file-name))
   (line-number-at-pos)
   (1+ (current-column)))
  )

(defun gpr-query-overridden (other-window)
  "Move to the overridden declaration of the identifier around point.
If OTHER-WINDOW (set by interactive prefix) is non-nil, show the
buffer in another window."
  (interactive "P")

  (let ((target
	 (gpr-query-overridden-1
	  (thing-at-point 'symbol)
	  (buffer-file-name)
	  (line-number-at-pos)
	  (save-excursion
	    (goto-char (car (bounds-of-thing-at-point 'symbol)))
	    (1+ (current-column)))
	  )))

    (ada-goto-source (nth 0 target)
		     (nth 1 target)
		     (nth 2 target)
		     other-window)
    ))

(defun gpr-query-goto-declaration (other-window)
  "Move to the declaration or body of the identifier around point.
If at the declaration, go to the body, and vice versa. If at a
reference, goto the declaration.

If OTHER-WINDOW (set by interactive prefix) is non-nil, show the
buffer in another window."
  (interactive "P")

  (let ((target
	 (gpr-query-other
	  (thing-at-point 'symbol)
	  (buffer-file-name)
	  (line-number-at-pos)
	  (save-excursion
	    (goto-char (car (bounds-of-thing-at-point 'symbol)))
	    (1+ (current-column)))
	  )))

    (ada-goto-source (nth 0 target)
		     (nth 1 target)
		     (nth 2 target)
		     other-window)
    ))

(defvar gpr-query-map
  (let ((map (make-sparse-keymap)))
    ;; C-c C-i prefix for gpr-query minor mode

    (define-key map "\C-c\C-i\C-d" 'gpr-query-goto-declaration)
    (define-key map "\C-c\C-i\C-p" 'ada-build-prompt-select-prj-file)
    (define-key map "\C-c\C-i\C-q" 'gpr-query-refresh)
    (define-key map "\C-c\C-i\C-r" 'gpr-query-show-references)
    ;; FIXME: (define-key map "\C-c\M-d" 'gpr-query-parents)
    ;; FIXME: overriding
    map
  )  "Local keymap used for GNAT inspect minor mode.")

(defvar gpr-query-menu (make-sparse-keymap "gpr-query"))
(easy-menu-define gpr-query-menu gpr-query-map "Menu keymap for gpr-query minor mode"
  '("gpr-query"
    ["Find and select project ..."   ada-build-prompt-select-prj-file t]
    ["Select project ..."            ada-prj-select                   t]
    ["Show current project"          ada-prj-show                     t]
    ["Show gpr-query buffer"         gpr-query-show-buffer            t]
    ["Next compilation error"        next-error                       t]
    ["Show secondary error"          ada-show-secondary-error         t]
    ["Goto declaration/body"         gpr-query-goto-declaration       t]
    ["Show parent declarations"      ada-show-declaration-parents     t]
    ["Show references"               gpr-query-show-references        t]
    ;; ["Show overriding"               gpr-query-show-overriding        t]
    ;; ["Show overridden"               gpr-query-show-overridden        t]
    ["Refresh cross reference cache" gpr-query-refresh        t]
    ))

(define-minor-mode gpr-query
  "Minor mode for navigating sources using GNAT cross reference tool.
Enable mode if ARG is positive"
  :initial-value t
  :lighter       " gpr-query"   ;; mode line

  ;; just enable the menu and keymap
  )

;;;;; support for Ada mode

(defun gpr-query-refresh ()
  "For `ada-xref-refresh-function', using gpr_query."
  (interactive)
  ;; need to kill session to get changed env vars etc
  (let ((session (gpr-query-cached-session)))
    (gpr-query-kill-session session)
    (gpr-query--start-process session)))

(defun gpr-query-other (identifier file line col)
  "For `ada-xref-other-function', using gpr_query."
  (when (eq ?\" (aref identifier 0))
    ;; gpr_query wants the quotes stripped
    (setq col (+ 1 col))
    (setq identifier (substring identifier 1 (1- (length identifier))))
    )

  (when (eq system-type 'windows-nt)
    ;; Since Windows file system is case insensitive, GNAT and Emacs
    ;; can disagree on the case, so convert all to lowercase.
    (setq file (downcase file)))

  (let ((cmd (format "refs %s:%s:%d:%d" identifier (file-name-nondirectory file) line col))
	(decl-loc nil)
	(body-loc nil)
	(search-type nil)
	(min-distance (1- (expt 2 29)))
	(result nil))

    (with-current-buffer (gpr-query-session-send cmd t)
      ;; 'gpr_query refs' returns a list containing the declaration,
      ;; the body, and all the references, in no particular order.
      ;;
      ;; We search the list, looking for the input location,
      ;; declaration and body, then return the declaration or body as
      ;; appropriate.
      ;;
      ;; the format of each line is file:line:column (type)
      ;;                            1    2    3       4
      ;;
      ;; 'type' can be:
      ;;   body
      ;;   declaration
      ;;   full declaration  (for a private type)
      ;;   implicit reference
      ;;   reference
      ;;   static call
      ;;
      ;; Module_Type:/home/Projects/GDS/work_stephe_2/common/1553/gds-hardware-bus_1553-wrapper.ads:171:9 (full declaration)
      ;;
      ;; itc_assert:/home/Projects/GDS/work_stephe_2/common/itc/opsim/itc_dscovr_gdsi/Gds1553/src/Gds1553.cpp:830:9 (reference)

      (message "parsing result ...")

      (goto-char (point-min))

      (while (not (eobp))
	(cond
	 ((looking-at gpr-query-ident-file-type-regexp)
	  ;; process line
	  (let* ((found-file (match-string 1))
		 (found-line (string-to-number (match-string 2)))
		 (found-col  (string-to-number (match-string 3)))
		 (found-type (match-string 4))
		 (dist       (gpr-query-dist found-line line found-col col))
		 )

	    (when (eq system-type 'windows-nt)
	      ;; 'expand-file-name' converts Windows directory
	      ;; separators to normal Emacs.  Since Windows file
	      ;; system is case insensitive, GNAT and Emacs can
	      ;; disagree on the case, so convert all to lowercase.
	      (setq found-file (downcase (expand-file-name found-file))))

	    (when (string-equal found-type "declaration")
	      (setq decl-loc (list found-file found-line (1- found-col))))

	    (when (or
		   (string-equal found-type "body")
		   (string-equal found-type "full declaration"))
	      (setq body-loc (list found-file found-line (1- found-col))))

	    (when
		;; The source may have changed since the xref database
		;; was computed, so allow for fuzzy matches.
		(and (equal found-file file)
		     (< dist min-distance))
	      (setq min-distance dist)
	      (setq search-type found-type))
	    ))

	 (t ;; ignore line
	  ;;
	  ;; This skips GPR_PROJECT_PATH and echoed command at start of buffer.
	  ;;
	  ;; It also skips warning lines. For example,
	  ;; gnatcoll-1.6w-20130902 can't handle the Auto_Text_IO
	  ;; language, because it doesn't use the gprconfig
	  ;; configuration project. That gives lines like:
	  ;;
	  ;; common_text_io.gpr:15:07: language unknown for "gds-hardware-bus_1553-time_tone.ads"
	  ;;
	  ;; There are probably other warnings that might be reported as well.
	  )
	 )
	(forward-line 1)
	)

      (cond
       ((null search-type)
	nil)

       ((and
	 (string-equal search-type "declaration")
	 body-loc)
	(setq result body-loc))

       (decl-loc
	(setq result decl-loc))
       )

      (when (null result)
	(error "gpr_query did not return other item; refresh?"))

      (message "parsing result ... done")
      result)))

(defun gpr-query-all (identifier file line col)
  "For `ada-xref-all-function', using gpr_query."
  (gpr-query-compilation identifier file line col "refs" 'gpr-query-ident-file))

(defun gpr-query-parents (identifier file line col)
  "For `ada-xref-parent-function', using gpr_query."
  (gpr-query-compilation identifier file line col "parent_types" 'gpr-query-ident-file))

(defun gpr-query-overriding (identifier file line col)
  "For `ada-xref-overriding-function', using gpr_query."
  (gpr-query-compilation identifier file line col "overriding" 'gpr-query-ident-file))

(defun gpr-query-overridden-1 (identifier file line col)
  "For `ada-xref-overridden-function', using gpr_query."
  (when (eq ?\" (aref identifier 0))
    ;; gpr_query wants the quotes stripped
    (setq col (+ 1 col))
    (setq identifier (substring identifier 1 (1- (length identifier))))
    )

  (let ((cmd (format "overridden %s:%s:%d:%d" identifier (file-name-nondirectory file) line col))
	result)
    (with-current-buffer (gpr-query-session-send cmd t)

      (goto-char (point-min))
      (when (looking-at gpr-query-ident-file-regexp)
	(setq result
	      (list
	       (match-string 1)
	       (string-to-number (match-string 2))
	       (string-to-number (match-string 3)))))

      (when (null result)
	(error "gpr_query did not return a result; refresh?"))

      (message "parsing result ... done")
      result)))

(defun ada-gpr-query-select-prj ()
  (setq ada-file-name-from-ada-name 'ada-gnat-file-name-from-ada-name)
  (setq ada-ada-name-from-file-name 'ada-gnat-ada-name-from-file-name)
  (setq ada-make-package-body       'ada-gnat-make-package-body)

  (add-hook 'ada-syntax-propertize-hook 'gnatprep-syntax-propertize)

  ;; must be after indentation engine setup, because that resets the
  ;; indent function list.
  (add-hook 'ada-mode-hook 'ada-gpr-query-setup t)

  (setq ada-xref-refresh-function    'gpr-query-refresh)
  (setq ada-xref-all-function        'gpr-query-all)
  (setq ada-xref-other-function      'gpr-query-other)
  (setq ada-xref-parent-function     'gpr-query-parents)
  (setq ada-xref-all-function        'gpr-query-all)
  (setq ada-xref-overriding-function 'gpr-query-overriding)
  (setq ada-xref-overridden-function 'gpr-query-overridden-1)
  (setq ada-show-xref-tool-buffer    'gpr-query-show-buffer)

  (add-to-list 'completion-ignored-extensions ".ali") ;; gnat library files, used for cross reference
  )

(defun ada-gpr-query-deselect-prj ()
  (setq ada-file-name-from-ada-name nil)
  (setq ada-ada-name-from-file-name nil)
  (setq ada-make-package-body       nil)

  (setq ada-syntax-propertize-hook (delq 'gnatprep-syntax-propertize ada-syntax-propertize-hook))
  (setq ada-mode-hook (delq 'ada-gpr-query-setup ada-mode-hook))

  (setq ada-xref-other-function      nil)
  (setq ada-xref-parent-function     nil)
  (setq ada-xref-all-function        nil)
  (setq ada-xref-overriding-function nil)
  (setq ada-xref-overridden-function nil)
  (setq ada-show-xref-tool-buffer    nil)

  (setq completion-ignored-extensions (delete ".ali" completion-ignored-extensions))
  )

(defun ada-gpr-query-setup ()
  (when (boundp 'wisi-indent-calculate-functions)
    (add-to-list 'wisi-indent-calculate-functions 'gnatprep-indent))
  )

(defun ada-gpr-query ()
  "Set Ada mode global vars to use gpr_query."
  (add-to-list 'ada-prj-parser-alist       '("gpr" . gnat-parse-gpr))
  (add-to-list 'ada-select-prj-xref-tool   '(gpr_query . ada-gpr-query-select-prj))
  (add-to-list 'ada-deselect-prj-xref-tool '(gpr_query . ada-gpr-query-deselect-prj))

  ;; no parse-*-xref

  (font-lock-add-keywords 'ada-mode
   ;; gnatprep preprocessor line
   (list (list "^[ \t]*\\(#.*\n\\)"  '(1 font-lock-type-face t))))
  )

(provide 'gpr-query)
(provide 'ada-xref-tool)

(add-to-list 'compilation-error-regexp-alist-alist
	     (cons 'gpr-query-ident-file       gpr-query-ident-file-regexp-alist))

(unless (and (boundp 'ada-xref-tool)
	     (default-value 'ada-xref-tool))
  (setq ada-xref-tool 'gpr_query))

(ada-gpr-query)

;;; end of file
