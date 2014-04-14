;;; mouseme.el --- mouse menu with commands that operate on strings

;; Copyright (C) 1997 by Free Software Foundation, Inc.

;; Author: Howard Melman <howard@silverstream.com>
;; Keywords: mouse, menu

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; A copy of the GNU General Public License is available at
;; http://www.r-project.org/Licenses/

;;; Commentary:

;; This package provides a command `mouse-me' to be bound to a mouse
;; button.  It pops up a menu of commands that operate on strings or a
;; region.  The string passed to the selected command is the word or
;; symbol clicked on (with surrounding quotes or other punctuation
;; removed), or the region (if either it was just selected with the
;; mouse or if it was active with `transient-mark-mode' on).  If the
;; command accepts a region, the selected region (or the region of the
;; word or symbol clicked on) will be passed to the command.

;; The idea is that for any given string in a buffer you may want to
;; do different things regardless of the mode of the buffer.  URLs
;; now appear in email, news articles, comments in code, and in plain
;; text.  You may want to visit that URL in a browser or you may just
;; want to copy it to the kill-ring.  For an email address you might
;; want to compose mail to it, finger it, look it up in bbdb, copy it to
;; the kill ring.  For a word you may want to spell check it, copy it,
;; change its case, grep for it, etc.  Mouse-me provides a menu to
;; make this easy.

;; The menu popped up is generated by calling the function in the
;; variable `mouse-me-build-menu-function' which defaults to calling
;; `mouse-me-build-menu' which builds the menu from the variable
;; `mouse-me-menu-commands'.  See the documentation for these
;; functions and variables for details.

;; To install, add something like the following to your ~/.emacs:
;;   (require 'mouseme)
;;   (global-set-key [S-mouse-2] 'mouse-me)

;;; Code:

(require 'browse-url)
(require 'thingatpt)

(eval-when-compile (require 'compile))

;;;; Variables

(defgroup mouseme nil
  "Popup menu of commands that work on strings."
  :prefix "mouse-me-"
  :group 'hypermedia)

(defcustom mouse-me-get-string-function 'mouse-me-get-string
  "*Function used by `mouse-me' to get string when no region selected.
The default is `mouse-me-get-string' but this variable may commonly
be made buffer local and set to something more appropriate for
a specific mode (e.g., `word-at-point').  The function will be called
with no arguments and with point at where the mouse was clicked.
It can return either the string or to be most efficient, a list of
three elements: the string and the beginning and ending points of the
string in the buffer."
  :type 'function
  :options '(mouse-me-get-string)
  :group 'mouseme)

(defcustom mouse-me-build-menu-function 'mouse-me-build-menu
  "*Function used by `mouse-me' to build the popup menu.
The default is `mouse-me-build-menu' but this variable may commonly
be made buffer local and set to something more appropriate for
a specific mode.  The function will be called with one argument,
the string selected, as returned by `mouse-me-get-string-function'."
  :type 'function
  :options '(mouse-me-build-menu)
  :group 'mouseme)

(defvar mouse-me-grep-use-extension 't
  "*If non-nil `mouse-me-grep' grep's in files with current file's extension.")

(defcustom mouse-me-menu-commands
  '(("Copy" . kill-new)
    ("Kill" . kill-region)
    ("Capitalize" . capitalize-region)
    ("Lowercase" . downcase-region)
    ("Uppercase" . upcase-region)
    ("ISpell" . ispell-region)
    "----"
    ("Browse URL" . browse-url)
    ("Dired" . dired)
    ("Execute File" . mouse-me-execute)
    ("Mail to" . compose-mail)
    ("Finger" . mouse-me-finger)
    ("BBDB Lookup" . mouse-me-bbdb)
    "----"
    ("Imenu" . imenu)
    ("Find Tag" . find-tag)
    ("Grep" . mouse-me-grep)
    ("Find-Grep" . mouse-me-find-grep)
    "----"
    ("Apropos" . apropos)
    ("Describe Function" . mouse-me-describe-function)
    ("Describe Variable" . mouse-me-describe-variable)
    ("Command Info" . mouse-me-emacs-command-info)
    ("Man Page" . (if (fboundp 'woman) 'woman 'man))
    ("Profile Function" . mouse-me-elp-instrument-function))
  "*Command menu used by `mouse-me-build-menu'.
A list of elements where each element is either a cons cell or a string.
If a cons cell the car is a string to be displayed in the menu and the
cdr is either a function to call passing a string to, or a list which evals
to a function to call passing a string to.  If the element is a string
it makes a non-selectable element in the menu.  To make a separator line
use a string consisting solely of hyphens.

The function returned from this menu will be called with one string
argument.  Or if the function has the symbol property `mouse-me-type'
and if its value is the symbol `region' it will be called with the
beginning and ending points of the selected string.  If the value is
the symbol `string' it will be called with one string argument."
  :type '(repeat sexp)
  :group 'mouseme)

(put 'kill-region 'mouse-me-type 'region)
(put 'ispell-region 'mouse-me-type 'region)
(put 'capitalize-region 'mouse-me-type 'region)
(put 'downcase-region 'mouse-me-type 'region)
(put 'upcase-region 'mouse-me-type 'region)

;;;; Commands

;;;###autoload
(defun mouse-me (event)
  "Popup a menu of functions to run on selected string or region."
  (interactive "e")
  (mouse-me-helper event (lambda ()
                           (or (x-popup-menu event (funcall mouse-me-build-menu-function name))
                               (error "No command to run")))))

;;;; Exposed Functions

;; Some tests:
;; <URL:http://foo.bar.com/sss/ss.html>
;; <http://foo.bar.com/sss/ss.html>
;; http://foo.bar.com/sss/ss.html
;; http://www.ditherdog.com/howard/
;; mailto:howard@silverstream.com
;; howard@silverstream.com
;; <howard@silverstream.com>
;; import com.sssw.srv.agents.AgentsRsrc;
;; public AgoHttpRequestEvent(Object o, String db, Request r)
;; <DIV><A href=3D"http://www.amazon.com/exec/obidos/ASIN/156592391X"><IMG =
;; <A HREF="http://www.suntimes.com/ebert/ebert.html">
;; d:\howard\elisp\spoon
;; \howard\elisp\spoon
;; \\absolut\howard\elisp\spoon
;; //absolut/d/Howard/Specs/servlet-2.1.pdf
;; \\absolut\d\Howard\Specs\servlet-2.1.pdf
;; gnuserv-frame.

(defun mouse-me-get-string ()
  "Return a string from the buffer of text surrounding point.
Returns a list of three elements, the string and the beginning and
ending positions of the string in the buffer in that order."
  (save-match-data
    (save-excursion
      (let ((start (point)) beg end str p)
        (skip-syntax-forward "^ >()\"")
        (setq end (point))
        (goto-char start)
        (skip-syntax-backward "^ >()\"")
        (setq beg (point))
        (setq str (buffer-substring-no-properties beg end))
        ;; remove junk from the beginning
        (if (string-match "^\\([][\"'`.,?:;!@#$%^&*()_+={}|<>-]+\\)" str)
            (setq str (substring str (match-end 1))
                  beg (+ beg (match-end 1))))
        ;; remove URL: from the front, it's common in email
        (if (string-match "^\\(URL:\\)" str)
            (setq str (substring str (match-end 1))
                  beg (+ beg (match-end 1))))
        ;; remove junk from the end
        (if (string-match "\\([][\"'.,?:;!@#$%^&*()_+={}|<>-]+\\)$" str)
            (setq end (- end (length (match-string 1 str))) ; must set end first
                  str (substring str 0 (match-beginning 1))))
        (list str beg end)))))

(defun mouse-me-build-menu (name)
  "Return a menu tailored for NAME for `mouse-me' from `mouse-me-menu-commands'."
  (list "Mouse Me" (cons "Mouse Me"
                         (append (list (cons
                                        (if (< (length name) 65)
                                            name
                                          "...Long String...")
                                        'kill-new)
                                       "---")
                                 mouse-me-menu-commands))))

;;;; Commands for the menu

(defun mouse-me-emacs-command-info (string)
  "Look in Emacs info for command named STRING."
  (interactive "sCommand: ")
  (let ((s (intern-soft string)))
    (if (and s (commandp s))
        (Info-goto-emacs-command-node s)
      (error "No command named `%s'" string))))

(defun mouse-me-describe-function (string)
  "Describe function named STRING."
  (interactive "sFunction: ")
  (let ((s (intern-soft string)))
    (if (and s (fboundp s))
        (describe-function s)
      (error "No function named `%s'" string))))

(defun mouse-me-describe-variable (string)
  "Desribe variable named STRING."
  (interactive "sVariable: ")
  (let ((s (intern-soft string)))
    (if (and s (boundp s))
        (describe-variable s)
      (error "No variable named `%s'" string))))

(defun mouse-me-elp-instrument-function (string)
  "Instrument Lisp function named STRING."
  (interactive "sFunction: ")
  (let ((s (intern-soft string)))
    (if (and s (fboundp s))
        (elp-instrument-function s)
      (error "Must be the name of an existing Lisp function"))))

(defun mouse-me-execute (string)
  "Execute STRING as a filename."
  (interactive "sFile: ")
  (if (fboundp 'w32-shell-execute)
      (w32-shell-execute "open" (convert-standard-filename string))
    (message "This function currently working only in W32.")))


(defun mouse-me-bbdb (string)
  "Lookup STRING in bbdb."
  (interactive "sBBDB Lookup: ")
  (if (fboundp 'bbdb)
      (bbdb string nil)
    (error "BBDB not loaded")))

(defun mouse-me-finger (string)
  "Finger a STRING mail address."
  (interactive "sFinger: ")
  (save-match-data
    (if (string-match "\\(.*\\)@\\([-.a-zA-Z0-9]+\\)$" string)
        (finger (match-string 1 string) (match-string 2 string))
      (error "Not in user@host form: %s" string))))

(defun mouse-me-grep (string)
  "Grep for a STRING."
  (interactive "sGrep: ")
  (require 'compile)
  (grep-compute-defaults)
  (let ((ext (mouse-me-buffer-file-extension)))
    (grep (concat grep-command string
                  (if mouse-me-grep-use-extension
                      (if ext
                          (concat " *" ext)
                        " *"))))))

(defun mouse-me-find-grep (string)
  "Grep for a STRING."
  (interactive "sGrep: ")
  (grep-compute-defaults)
  (let ((reg grep-find-command)
        (ext (mouse-me-buffer-file-extension))
        beg end)
    (if (string-match "\\(^.+-type f \\)\\(.+$\\)" reg)
        (setq reg (concat (match-string 1 reg)
                          (if mouse-me-grep-use-extension
                              (concat "-name \"*" ext "\" "))
                          (match-string 2 reg))))
    (grep-find (concat reg string))))

;;;; Internal Functions

(defun mouse-me-buffer-file-extension ()
  "Return the extension of the current buffer's filename or nil.
Returned extension is a string begining with a period."
  (let* ((bfn (buffer-file-name))
         (filename (and bfn (file-name-sans-versions bfn)))
         (index (and filename (string-match "\\.[^.]*$" filename))))
    (if index
        (substring filename index)
      "")))

(defun mouse-me-helper (event func)
  "Determine the string to use to process EVENT and call FUNC to get cmd."
  (let (name sp sm mouse beg end cmd mmtype)
    ;; temporarily goto where the event occurred, get the name clicked
    ;; on and enough info to figure out what to do with it
    (save-match-data
      (save-excursion
        (setq sp (point))               ; saved point
        (setq sm (mark t))              ; saved mark
        (set-buffer (window-buffer (posn-window (event-start event))))
        (setq mouse (goto-char (posn-point (event-start event))))
        ;; if there is a region and point is inside it
        ;; check for sm first incase (null (mark t))
        ;; set name to either the thing they clicked on or region
        (if (and sm
                 (or (and transient-mark-mode mark-active)
                     (eq last-command 'mouse-drag-region))
                 (>= mouse (setq beg (min sp sm)))
                 (<= mouse (setq end (max sp sm))))
            (setq name (buffer-substring beg end))
          (setq name (funcall mouse-me-get-string-function))
          (if (listp name)
              (setq beg (nth 1 name)
                    end (nth 2 name)
                    name (car name))
            (goto-char mouse)
            (while (not (looking-at (regexp-quote name)))
              (backward-char 1))
            (setq beg (point))
            (setq end (search-forward name))))))
    ;; check if name is null, meaning they clicked on no word
    (if (or (null name)
            (and (stringp name) (string= name "" )))
        (error "No string to pass to function"))
    ;; popup a menu to get a command to run
    (setq cmd (funcall func))
    ;; run the command, eval'ing if it was a list
    (if (listp cmd)
        (setq cmd (eval cmd)))
    (setq mmtype (get cmd 'mouse-me-type))
    (cond ((eq mmtype 'region)
           (funcall cmd beg end))
          ((eq mmtype 'string)
           (funcall cmd name))
          (t
           (funcall cmd name)))))

(provide 'mouseme)

;;; mouseme.el ends here
