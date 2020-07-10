@ECHO OFF
REM vpn.bat
REM Purpose:  Run the Set-VpnState.ps1 PowerShell script, which toggles the windows
REM           service for GlobalProtect VPN (PanGPS) based on the given input.
REM Requires: PowerShell, NirCMD, Administrator privileges
REM Usage:    vpn ([state])
REM           vpn (restart|off|stop|on|start)
REM Examples: 
REM   vpn
REM   vpn on
REM   vpn off
REM   vpn restart

nircmdc.exe elevate powershell.exe -Command "& 'Set-VpnState.ps1' %*"
REM EXIT
