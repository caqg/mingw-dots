" gvim Initialization -- 2006-10-11 01:33:19UT (cesar@cesar-xp)

set background=light
set guicursor=a:block
"set guifont=Terminal\ 14
set guioptions+=a
set guioptions+=b
set guioptions+=g
set guioptions+=t
set guioptions-=T

if &diff
  set columns=180
  set lines=999
else
  set columns=96
  set lines=40
endif

color solarized
set background=dark
call togglebg#map("<F12>")
"end .gvimrc
