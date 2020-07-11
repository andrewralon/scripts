@ECHO OFF
REM timeto.bat
REM Purpose:  Run the timeto.ps1 PowerShell script, which closes non-related 
REM           apps and services, then opens related apps and services based on
REM           the given input.
REM Requires: PowerShell, NirCMDc.exe, Administrator privileges
REM Usage:    timeto [action]
REM Examples: timeto work
REM           timeto play
REM           timeto chill
REM           timeto battery
REM Notes:
REM * The powershell script must be run twice, once as user and once as admin.

SET FILENAME=%~n0

REM Run as user
START powershell.exe -Command "& '%FILENAME%.ps1' %*"

REM Run as admin
START nircmdc.exe elevate powershell.exe -Command "& '%FILENAME%.ps1' -Admin %*"

REM PAUSE
REM EXIT
