@ECHO OFF
REM RDP.bat
REM Purpose:  Opens an RDP file of the same name in the same directory
REM Usage:    yourfile
REM Example:  yourfile
REM Notes:
REM   1. Copy this file to the directory with your RDP files
REM   2. Rename it as yourfilename.bat

SET FILENAME=%~n0
CALL rd %FILENAME%

:END
EXIT
