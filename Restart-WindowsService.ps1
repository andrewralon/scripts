# Restart-WindowsService.ps1
# Purpose:  Restart a windows service and send a notification post to Slack.
#           Originally intended to be run by a scheduled task.
# Usage:    .\Restart-WindowsService.ps1 -ServiceName $serviceName
# Example:  .\Restart-WindowsService.ps1 -ServiceName W3SVC
# Notes:    Works with either the service name OR the display name.

param(
	[string] $ServiceName
)

Import-Module -Name PSSlack

# Force use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Setup variables
$scriptPath = "$($PSScriptRoot)\$($MyInvocation.MyCommand)"
$textWarning = "Warning"
$textError = "ERROR"
$messages = @()
$service = $null
$slackText = $null

# Custom variables
$secondsToWait = 10
$ip = $(Get-NetIPAddress -InterfaceIndex 12).IPAddress # Set IP address automatically
#$ip = "FI.LL.ME.IN" # Set IP address manually
$slackToken = "CHANGEME"
$slackChannel = "#your-slack-channel"

# Add lines of text in the slack message
$messages += "*Service Restart - $($ServiceName)*"
$messages += "*Server*: $($env:ComputerName) - $($ip)"
$messages += "*Script*: $($scriptPath)"

# Get the service's info
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($service) {
	if ($service.Status -ne "Running") {
		$messages += "*$($textWarning)*: Service was not running. Starting and waiting $secondsToWait seconds."
		Start-Service -Name $ServiceName
		Start-Sleep -Seconds $secondsToWait
	}

	Restart-Service -Name $ServiceName
	Start-Sleep -Seconds $secondsToWait

	$service = Get-Service -Name $ServiceName
	
	if ($service.Status -eq "Running") {
		$messages += "Service restarted successfully."
	}
	else {
		$messages += "*$($textError): Unable to restart the service. Please restart it manually.*"
	}
}
else {
	$messages += "*$($textError): Service not found*"
}

# Combine messages and send slack notification to channel
$slackText = $messages -join "`n"
Send-SlackMessage -Token $slackToken -Channel $slackChannel -Text $slackText -AsUser

Write-Output $slackText
