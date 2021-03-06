;;; ada-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (ada-mode ada-add-extensions ada-parse-prj-file)
;;;;;;  "ada-mode" "ada-mode.el" (21545 57786 0 0))
;;; Generated autoloads from ada-mode.el

(autoload 'ada-parse-prj-file "ada-mode" "\
Read Emacs Ada or compiler-specific project file PRJ-FILE, set project properties in `ada-prj-alist'.

\(fn PRJ-FILE)" nil nil)

(autoload 'ada-add-extensions "ada-mode" "\
Define SPEC and BODY as being valid extensions for Ada files.
SPEC and BODY are two regular expressions that must match against
the file name.

\(fn SPEC BODY)" nil nil)

(autoload 'ada-mode "ada-mode" "\
The major mode for editing Ada code.

\(fn)" t nil)

;;;***

;;;### (autoloads (ada-indent-opentoken-mode) "ada-wisi-opentoken"
;;;;;;  "ada-wisi-opentoken.el" (21545 57786 0 0))
;;; Generated autoloads from ada-wisi-opentoken.el

(autoload 'ada-indent-opentoken-mode "ada-wisi-opentoken" "\
Minor mode for indenting grammar definitions for the OpenToken package.
Enable mode if ARG is positive

\(fn &optional ARG)" t nil)

;;;***

;;;### (autoloads (gpr-mode) "gpr-mode" "gpr-mode.el" (21545 57788
;;;;;;  0 0))
;;; Generated autoloads from gpr-mode.el

(autoload 'gpr-mode "gpr-mode" "\
The major mode for editing GNAT project files.

\(fn)" t nil)

(add-to-list 'auto-mode-alist '("\\.gpr\\'" . gpr-mode))

;;;***

;;;### (autoloads nil nil ("ada-build.el" "ada-fix-error.el" "ada-gnat-compile.el"
;;;;;;  "ada-gnat-xref.el" "ada-grammar-wy.el" "ada-imenu.el" "ada-indent-user-options.el"
;;;;;;  "ada-mode-compat-23.4.el" "ada-mode-compat-24.2.el" "ada-mode-pkg.el"
;;;;;;  "ada-ref-man.el" "ada-skel.el" "ada-wisi.el" "gnat-core.el"
;;;;;;  "gnat-inspect.el" "gpr-grammar-wy.el" "gpr-query.el" "gpr-skel.el"
;;;;;;  "gpr-wisi.el") (21545 57788 450000 0))

;;;***

(provide 'ada-mode-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; ada-mode-autoloads.el ends here
