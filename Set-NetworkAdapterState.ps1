# Set-NetworkAdapterState.ps1
# Purpose:  Disable and re-enable a network adapter, specifically for wireless / wifi.
# Requires: PowerShell, Administrator privileges
# Usage:    Set-NetworkAdapterState ([state])
#           Set-NetworkAdapterState (restart|off|stop|on|start)
# Examples: 
#   Set-NetworkAdapterState
#   Set-NetworkAdapterState on
#   Set-NetworkAdapterState off
#   Set-NetworkAdapterState restart

param(
	[string] $State = "restart"
	, [switch] $NoDelay
	, [switch] $Quiet
)

$name = "Wi-Fi"
$backupTerm = "wireless"
$adapter = Get-NetAdapter -Name $name -ErrorAction SilentlyContinue
$secondsToWait = 5

if (!$adapter) {
	if (!$Quiet) { Write-Host "Adapter not found: '$($name)'" }
	if (!$Quiet) { Write-Host "Searching for 'wireless' in the interface descriptions...." }

	$adapters = Get-NetAdapter -ErrorAction SilentlyContinue
	$adapter = $adapters.Where( { $_.InterfaceDescription -like "*$backupTerm*" } ) | Select-Object -first 1

	if ($adapter) {
		if (!$Quiet) { Write-Host "Found adapter: '$($adapter.Name)'.... w00t!" }
	}
}

if ($adapter) {	
	if (!$Quiet) { Write-Host "$($adapter.Name) status was '$($adapter.Status)'" }
	if (!$Quiet) { Write-Host "Desired state: '$State'" }

	if ((($State -like "on" -or $State -like "start") -and ($adapter.Status -like "Up" -or $adapter.Status -like "Disconnected")) -or 
		(($State -like "off" -or $State -like "stop") -and $adapter.Status -like "Disabled")) {
		if (!$Quiet) { Write-Host "Adapter is already '$($adapter.Status)'...." }
	}
	else {
		if ($State -like "off" -or $State -like "stop" -or $State -like "restart") {
			if (!$Quiet) { Write-Host "Disabling now...." }
			Disable-NetAdapter -Name $adapter.Name -Confirm:$false
		} 
		
		if ($State -like "on" -or $State -like "start" -or $State -like "restart") {
			if (!$Quiet) { Write-Host "Enabling now...." }
			Enable-NetAdapter -Name $adapter.Name -Confirm:$false
		}
		
		Start-Sleep -Seconds $secondsToWait
		
		$adapter = Get-NetAdapter -Name $adapter.Name -ErrorAction SilentlyContinue		
		if (!$Quiet) { Write-Host "$($adapter.Name) status is now '$($adapter.Status)'" }
	}
}
else {
	Write-Warning "Adapter not found: '$name''"
}

if (!$NoDelay) {
	if (!$Quiet) { 
		Write-Host ""
		Write-Host "Done"
		Write-Host ""
		Write-Host "Exiting in $secondsToWait seconds...."
	}
	Start-Sleep -Seconds $secondsToWait
}
