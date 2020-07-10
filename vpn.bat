@ECHO OFF
REM vpn.bat
REM Purpose:  Run the vpn.ps1 PowerShell script, which toggles the windows
REM           service for GlobalProtect VPN (PanGPS) based on the given input.
REM Requires: PowerShell, NirCMD, Administrator privileges
REM Usage:    vpn ([state])
REM Examples: 
REM   vpn
REM   vpn on
REM   vpn off
REM   vpn restart

SET FILENAME=%~n0
nircmdc.exe elevate powershell.exe -Command "& '%FILENAME%.ps1' %*"
REM EXIT
