Send commands to Emacs from programs running in the term.el
terminal emulator.

In vanilla Emacs, programs running in the terminal emulator can
send commands back to Emacs by printing a 'magic escape sequence'
which the terminal emulator parses -- this is how directory
tracking works.  But the list of commands is hard-coded, and you
can't add new ones.

This package lets you add new commands.  It uses a different magic
escape sequence to avoid interfering with the built-in commands,
but the principle is the same.  When a program prints a command, it
won't show up on the screen, but will be interpreted by Emacs
instead.

Note: this is a library, and doesn't make any user-visible changes.
For an example of something that actually uses it, see the
'term-alert' package (https://github.com/CallumCameron/term-alert).


Usage:

To register a command:

    (add-to-list 'term-cmd-commands-alist
                 '("command" . some-callback-function))

where "command" is the name of the command, and
some-callback-function is the function you want to be called when
the command is run.  The function should take two arguments -- the
first is the command name itself, and the second is the command's
argument.

To send a command, just print the magic escape sequence in some
program in the terminal:

    # Using GNU printf
    /usr/bin/printf '\eTeRmCmD %s %s\n' "${CMD}" "${ARG}"

    # With a shell built-in, the syntax might be different; here for ZSH:
    print "\033TeRmCmD ${CMD} ${ARG}"

The '\e' and '\033' are the ESC character.  You can leave off the
argument if you don't need it.

Alternatively, use the 'emacs-term-cmd' script:

    emacs-term-cmd command arg

Because the commands are based on terminal output, they work just
as well through nested shells, or multiple SSH sessions.


Installation:

1. Make sure this file is on your load path
2. (require 'term-cmd)

There is also a shell script, 'emacs-term-cmd', in this package's
git repository, which makes sending commands easier.
