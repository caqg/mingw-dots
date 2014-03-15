" vim Initialization

set directory=.,$TMPDIR,$TMP,$TEMP
set tags=./tags,tags,/mingw/tags

set path=.,,
set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++
set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++/mingw32
set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++/backward
set path+=/mingw/lib/gcc/mingw32/4.8.1/include
set path+=/mingw/include
set path+=/mingw/lib/gcc/mingw32/4.8.1/include-fixed
set path+=/mingw/mingw32/include
set path+=/mingw/msys/1.0/include

set lines=36
set columns=80

source $HOME/.exrc
set smarttab
set expandtab
set textwidth=76
syntax on
filetype indent on
filetype plugin on

let TE_Ctags_Path="$HOME/bin/ctags.exe"
let TE_Use_Right_Window=1

" Not in plain vi
set backup
set laststatus=1
set writebackup
set nohlsearch
set incsearch
if v:version >= 700
  set numberwidth=5
endif

" C/C++, closer to the Emacs settings
autocmd FileType c,cpp,java :set cinoptions=:0,j1,J1,l0,g0,t0,(0,)30,N-s
autocmd FileType c,cpp,java :set foldmethod=syntax
autocmd FileType c,cpp,java :set foldcolumn=4
autocmd FileType c,cpp,java :set nofoldenable

set ruler
set diffopt=filler,iwhite

" Adjust Verilog's indentation
function! VerilogSettings ()
  if exists('b:current_syntax')
    if b:current_syntax == 'verilog'
      let b:verilog_indent_modules = 1
    endif
  endif
endfunction
autocmd BufReadPost *.v call VerilogSettings()

" Man pages
runtime! ftplugin/man.vim

"end .vimrc
