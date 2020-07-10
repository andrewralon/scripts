@ECHO OFF
REM rd.bat
REM Purpose:  Opens a remote desktop connection by filename.rdp, IP address, or computer name; Opens remote desktop window if no argument given
REM Usage:    rd ([filename]|[IP]|[computername])
REM Examples: 
REM   rd
REM   rd filename
REM   rd 127.0.0.1
REM   rd LOCALHOST
REM Notes:
REM * Assumes filename, IP, or computer name is the first argument
REM * Assumes directory is the script's directory

SET FILENAME=%1
SET DIRECTORY=%~dp0
SET TARGET=%1.rdp

REM If "filename.rdp" exists, open it
IF EXIST %DIRECTORY%%TARGET% GOTO :OPENFILE
REM If argument was given, open remote desktop with it (assumes IP or computer name)
IF NOT '%1'=='' GOTO :OPENARGUMENT
REM If no argument, open remote desktop window (mstsc.exe)
IF '%1'=='' GOTO :OPENWINDOW

:OPENFILE
START "" /D %DIRECTORY% %TARGET%
GOTO :END

:OPENARGUMENT
%WINDIR%\system32\mstsc.exe /v:%1
GOTO :END

:OPENWINDOW
%WINDIR%\system32\mstsc.exe
GOTO :END

:END
EXIT
