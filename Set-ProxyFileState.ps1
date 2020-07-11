# Set-ProxyFileState.ps1
# Purpose: Switch the internet proxy automation configuration on and off for the current user, 
#          toggling back and forth.
# Usage:   Set-ProxyFileState
# Example: Set-ProxyFileState

param(
	[switch] $NoDelay
)

# $proxyURL = "https://proxy.company.com/proxyfile.pac"
$proxyURL = $env:PROXYURL
$keyName = "AutoConfigURL"
$secondsToWait = 5

# Get base registry key for accessing internet settings
$registryKey = Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\" | Where-Object { $_.Name -like "*CurrentVersion" }

# Open the internet settings registry key and make it writable
$internetSettingKey = $registryKey.OpenSubKey("Internet Settings", $true)

# Check if key exists - if it does then delete it, else add it to the registry
if ($null -ne $internetSettingKey.GetValue($keyName)) {
	# Delete the value
	$internetSettingKey.DeleteValue($keyName)
	Write-Output "Proxy Automatic Configuration script has been DISABLED"
}
else {
	# Set the internet proxy url to the original value
	$internetSettingKey.SetValue($keyName, $proxyURL, [Microsoft.Win32.RegistryValueKind]::String)
	Write-Output "Proxy Automatic Configuration script has been ENABLED"
	Write-Output "    $proxyURL"
}

# Close registry keys
$internetSettingKey.Close()
$registryKey.Close()

if (!$NoDelay) {
	Write-Output ""
	Write-Output "Done"
	Write-Output ""
	Write-Output "Exiting in $secondsToWait seconds...."
	Start-Sleep -Seconds $secondsToWait
}
