# Unblock-WindowsUpdate.ps1
# Purpose:  Disable Windows Update from using a WU server set by group policy,
#           which allows Windows Update to use the public WU server.
# Requires: PowerShell, Administrator privileges, Unblock-WindowsUpdate.reg
# Usage:    .\Unblock-WindowsUpdate.ps1

# Goal:     Convert this CMD script to PowerShell
# SET FILENAME=%~n0
# SET DIRECTORY=%~dp0
# ECHO * 1. Setting the working directory to:
# ECHO %DIRECTORY%
# PUSHD %DIRECTORY%
# ECHO * 2. Stopping Windows Update service....
# net stop wuauserv
# ECHO * 3. Running registry import file....
# reg import %FILENAME%.reg
# POPD

$secondsToWait = 5
$filename = (Get-Item $PSCommandPath).Basename

Write-Output "`n 1. Set the working directory"
Write-Output $PSScriptRoot
Push-Location $PSScriptRoot

Write-Output "`n 2. Stop the Windows Update service"
Stop-Service wuauserv

Write-Output "`n 3. Update registry to disable the custom WU server"
Write-Output "file:  '$($filename).reg'"
& reg import .\$($filename).reg
#REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /V UseWUServer /t DWORD /d 00000000 /f

Pop-Location

Write-Output "`nDone. Exiting in $secondsToWait seconds...."
Start-Sleep -Seconds $secondsToWait
