@ECHO OFF
REM Unblock-WindowsUpdate.bat
REM Purpose:  Runs PowerShell script to disable Windows Update from using a WU server
REM           set by group policy, which allows Windows Update to use the public WU server.
REM Requires: PowerShell, NirCMDc.exe, Administrator privileges, Unblock-WindowsUpdate.reg
REM Usage:    Unblock-WindowsUpdate

SET FILENAME=%~n0

REM Run as user - uncomment this if you are already running this .bat as admin
REM START powershell.exe -Command "& '%FILENAME%.ps1' %*"

REM Run as admin - required when not running this .bat as admin
START nircmdc.exe elevate powershell.exe -Command "& '%FILENAME%.ps1' -Admin %*"

REM PAUSE
REM EXIT
