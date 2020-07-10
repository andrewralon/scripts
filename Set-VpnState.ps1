# Set-VpnState.ps1
# Purpose:  Toggle, start or stop the windows service "PanGPS" (GlobalProtect VPN)
#           based on the given input.
# Requires: PowerShell, Administrator privileges
# Usage:    Set-VpnState ([state])
#           Set-VpnState (restart|off|stop|on|start)
# Examples: 
#   Set-VpnState
#   Set-VpnState on
#   Set-VpnState off
#   Set-VpnState restart

param(
	[string] $State = $null
)

function Get-ServiceScript {
	param( [string] $ServiceName )
	Get-Service $ServiceName -ErrorAction SilentlyContinue
}

$serviceName = "PanGPS"
$service = Get-ServiceScript $serviceName
$secondsToWait = 5

if ($service) {

	Write-Output "$serviceName status was '$($service.Status)'"
	Write-Output ""

	if ($State) {
		Write-Output "Desired state: '$State'"
		Write-Output ""

		if ($State -like "off" -or $State -like "stop") {
			Write-Output "Stopping now...."
			Stop-Service $serviceName #-Force
		}
		elseif ($State -like "on" -or $State -like "start") {
			Write-Output "Starting now...."
			Start-Service $serviceName #-Force
		}
		elseif ($State -like "re*") {
			Write-Output "Restarting now...."
			Restart-Service $serviceName #-Force
		}
		else {
			Write-Output "Invalid state: '$State'"
		}
	}
	else {
		if ($service.Status -like "Running") {
			Write-Output "Stopping now...."
			Stop-Service $serviceName #-Force
		}
		elseif ($service.Status -notlike "Running") {
			Write-Output "Starting now...."
			Start-Service $serviceName #-Force
		}
	}
}
else {
	Write-Output "Service not found: '$serviceName'"
}

Write-Output ""
Write-Output "Done"
Write-Output ""
Write-Output "Exiting in $secondsToWait seconds...."
Start-Sleep -Seconds $secondsToWait
