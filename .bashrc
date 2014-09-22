# -*- Shell-Script -*-

# workaround for mingw/msys
# set - $(/bin/basename $(eval echo $0) .exe)

#- shopt -s igncr #
if [ "${ALREADY_IN:-0}" = 0 ]; then
    . $HOME/.bash_env
    export ALREADY_IN=1;
fi

if [ "${EMACS:-nil}" = t ]; then
    . $HOME/.bash_under_emacs
fi

[ "$PS1" ] && {
    . ~/.bash_interactive
}

##end .bashrc
# vim: set filetype=sh :
