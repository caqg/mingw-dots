" vim Initialization

source $HOME/.exrc

set directory=
set directory+=$TMPDIR
set directory+=.
set directory+=$TMP
set directory+=$TEMP

set path=.,,
" set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++
" set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++/mingw32
" set path+=/mingw/lib/gcc/mingw32/4.8.1/include/c++/backward
" set path+=/mingw/lib/gcc/mingw32/4.8.1/include
" set path+=/mingw/include
" set path+=/mingw/lib/gcc/mingw32/4.8.1/include-fixed
" set path+=/mingw/mingw32/include
" set path+=/mingw/msys/1.0/include

set tags=
set tags+=./TAGS
set tags+=TAGS
" set tags+=/MinGW/TAGS

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
set textwidth=76
if v:version >= 700
  set numberwidth=5
endif

" C/C++/Java, closer to the Emacs settings
autocmd FileType c,cpp,java :set cinoptions=:0,j1,J1,l0,g0,t0,(0,)30,N-s
autocmd FileType c,cpp,java :set expandtab
autocmd FileType c,cpp,java :set foldmethod=syntax
autocmd FileType c,cpp,java :set foldcolumn=0
autocmd FileType c,cpp,java :set nofoldenable
autocmd FileType c,cpp,java :set formatoptions+=cj
autocmd FileType c,cpp,java :set shiftwidth=8
autocmd FileType c,cpp,java :set smarttab

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

" Treat *.md as markdown, not modula2
autocmd BufNewFile,BufRead *.md setfiletype markdown

" Man pages
runtime! ftplugin/man.vim

"end .vimrc
