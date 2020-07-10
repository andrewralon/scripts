@ECHO OFF
REM proxy.bat
REM Purpose:  Run the Set-ProxyState.ps1 PowerShell script, which toggles the internet proxy
REM           automation configuration (PAC) setting for the current user.
REM Requires: PowerShell, NirCMDc.exe, Administrator privileges
REM Usage:    proxy
REM Example:  proxy

powershell.exe -Command "& 'Set-ProxyFileState.ps1' %*"
REM EXIT
