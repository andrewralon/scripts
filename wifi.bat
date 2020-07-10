@ECHO OFF
REM wifi.bat
REM Purpose:  Run the Set-NetworkAdapterState.ps1 PowerShell script, which restarts (default),
REM           disables, or enables the hard-coded network adapter. This is specifically
REM           meant for the default wireless / wifi interface.
REM Requires: PowerShell, NirCMDc.exe, Administrator privileges
REM Usage:    wifi ([state])
REM           wifi (restart|off|stop|on|start)
REM Examples: 
REM   wifi
REM   wifi on
REM   wifi off
REM   wifi restart
REM Notes: 
REM * If no state is given, "restart" is assumed. This is not a toggle.

nircmdc.exe elevate powershell.exe -Command "& 'Set-NetworkAdapterState.ps1' %*"
REM EXIT
