 Standard `apropos' commands `apropos-variable' and
 `apropos-command' do not distinguish, by command name, between the
 different types of target object (but you can do that via `C-u').
 This library provides individual `apropos' commands for user
 options, variables in general (not just options), and functions in
 general (not just commands).  These commands are defined here:

   `apropos-option'   - Apropos a user option
   `apropos-variable' - Apropos any variable, not just user option
   `apropos-function' - Apropos any function, not just command


 ***** NOTE: The following functions defined in `apropos.el' have
             been REDEFINED HERE:

 `apropos-variable' - See above (the standard command does what
                      `apropos-option' does here).
 `apropos-print'    - Identifies user options with label `Option'.


 Slightly different versions of `apropos-function' and
 `apropos-variable' were posted by Kevin Rodgers to bug-gnu-emacs,
 Tue, 06 Sep 2005 14:34:54 -0600.  Kevin didn't actually redefine
 `apropos-variable' (he would never do that ;-)), but he provided
 the new definition.  I redefined `apropos-print' and added button
 type `apropos-option'.
