A remote web access to emacs.

Starts a web server allowing access to emacs through a webpage.
There is no security in this module at all! If you plan to use this
on a non local, secure network you must secure the access yourself.
To secure you can use an SSH tunnel, an SSH SOCKS proxy or a reverse
HTTPS proxy.

If the error 'Caught Error: (void-function symbol-macrolet)' occurs
you need to execute '(require 'cl)' before using take-off. This issue
is fixed in emacs 24.4.

The following starts the web-server:

(take-off-start <port>)

To stop the server:

(take-off-stop)

emacs will be available at : http://<address>:<port>/emacs.html
