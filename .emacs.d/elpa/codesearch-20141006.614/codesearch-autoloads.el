;;; codesearch-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (codesearch-clear-index codesearch-update-index
;;;;;;  codesearch-build-index codesearch-search) "codesearch" "codesearch.el"
;;;;;;  (21554 52920 0 0))
;;; Generated autoloads from codesearch.el

(autoload 'codesearch-search "codesearch" "\


\(fn PATTERN FILE-PATTERN)" t nil)

(autoload 'codesearch-build-index "codesearch" "\
Scan DIR to rebuild an index.

\(fn DIR)" t nil)

(autoload 'codesearch-update-index "codesearch" "\
Update an existing index.

\(fn)" t nil)

(autoload 'codesearch-clear-index "codesearch" "\
Clear/delete the codesearch index.

\(fn)" t nil)

;;;***

;;;### (autoloads nil nil ("codesearch-pkg.el") (21554 52920 892000
;;;;;;  0))

;;;***

(provide 'codesearch-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; codesearch-autoloads.el ends here
