This is a major-mode to implement the SCAD constructs and
font-locking for openscad

If installing manually, insert the following into your emacs startup:

(autoload 'scad-mode "scad-mode" "Major mode for editing SCAD code." t)
(add-to-list 'auto-mode-alist '("\\.scad$" . scad-mode))

or

install from marmalade: http://marmalade-repo.org/
M-x install-package <ENTER> scad-mode <ENTER>
