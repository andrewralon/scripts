# toggleproxy.ps1
# Purpose: Switch the internet proxy on and off for the current user, toggling back and forth
# Usage:   toggleproxy

$proxyURL = $env:PROXYURL
$keyName = "AutoConfigURL"

# Get base registry key for accessing internet settings
$registryKey = Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\" | Where-Object { $_.Name -like "*CurrentVersion" }

# Open the internet settings registry key and make it writable
$internetSettingKey = $registryKey.OpenSubKey("Internet Settings", $true)

Write-Output ""

# Check if key exists - if it does then delete it, else add it to the registry
if ($null -ne $internetSettingKey.GetValue($keyName)) {
	# Delete the value
	$internetSettingKey.DeleteValue($keyName)
    Write-Output "Proxy Automatic Configuration script has been DISABLED"
}
else {
	# Set the internet setting config url to the original value
	$internetSettingKey.SetValue($keyName, $proxyURL, [Microsoft.Win32.RegistryValueKind]::String)
    Write-Output "Proxy Automatic Configuration script has been ENABLED"
    Write-Output ""
    Write-Output "    " + $proxyURL
}

Write-Output ""

# Close registry keys
$internetSettingKey.Close()
$registryKey.Close()
