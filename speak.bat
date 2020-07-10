@ECHO OFF
REM speak.bat
REM Purpose:  Say silly things using the computer's voice.

SET FILENAME=%~n0
SET PHRASE=%*
SET LOOP=

IF NOT '%1'=='' GOTO :SPEAK
GOTO :GETPHRASE

:GETPHRASE
SET /p PHRASE=: 
SET LOOP=true
GOTO :SPEAK

:SPEAK
REM & cmd.exe /C 
powershell.exe -Command "& '%SHORTCUTS%\speak.ps1' -phrase ""%PHRASE%"""
IF '%LOOP%'=='true' GOTO :GETPHRASE
GOTO :EXIT

:EXIT
REM PAUSE
REM EXIT
