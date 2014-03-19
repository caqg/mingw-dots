" gvim Initialization -- 2006-10-11 01:33:19UT (cesar@cesar-xp)

source .vimrc

set guicursor=a:block
"set guifont=Terminal\ 14
set guifont=Consolas:h10:cANSI
set guioptions+=a
set guioptions+=b
set guioptions+=g
set guioptions+=t
set guioptions-=T
set guioptions-=r
set guioptions-=b

if &diff
  set columns=180
  set lines=999
else
  set columns=96
  set lines=40
endif

color solarized
call togglebg#map("<F12>")
set background=dark
"end .gvimrc
