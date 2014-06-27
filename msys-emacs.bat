REM Starting Win Emacs under Msys32 -*- Fundamental -*-
REM Was "C:\Program Files (x86)\Emacs\emacs-24.3\bin\runemacs.exe" -f set-color-theme-solarized-dark
REM
REM Set in the icon properties (borrowed from runemacs.exe) to start Emacs
REM inside an Msys context (from a bash login shell).
REM
REM Keep it at %HOME%, run runemacs first to capture a task bar icon,
REM then edit these icon's properties:
REM
REM Target      %HOME%\msys-emacs.bat
REM Start in    %HOME%
REM Run         Minimized
C:/MinGW/msys/1.0/bin/bash -l -c 'exec /c/Program\ Files\ \(x86\)/Emacs/emacs-24.3/bin/runemacs.exe -f set-color-theme-solarized-dark'
