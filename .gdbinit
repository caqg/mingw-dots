## Copyright (C) 2014-2014 by Cesar A Quiroz, Ph.D.
## 3500 Granada Ave Apt 348 / Santa Clara, CA 95051 / USA
## All Rights Reserved Worldwide
## mailto:cesar.quiroz@gmail.com

define ps
    set $i = 0
    while ($i < $argc)
        eval "print $arg%d.c_str()", $i
        $i = $i + 1
    end
end

document ps
Prints C++ strings as C strings.
end

# : set filetype=gdb :
