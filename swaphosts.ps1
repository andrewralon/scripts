# swaphosts.ps1
#Requires -RunAsAdministrator
# PURPOSE:  Swap / toggle / replace hosts files in C:\Windows\System32\drivers\etc

param(
	[string] $fileA = "G1-RC-2019",
	[string] $fileB = "BLANK",
	[switch] $fromCMD
)

#region FUNCTIONS

function Set-HostsFile {
	param(
		[string] $Source,
		[string] $Destination
	)

	$sourceContent = Get-Content $Source
	$destinationContent = Get-Content $Destination
	$skip = $false
	$retries = 5
	$index = 1

	while ($index -le $retries -and !$skip) {

		# Skip if both file contents are null, meaning they are the same
		if (!$sourceContent -and !$destinationContent) { $skip = $true }

		# Handle null file content by setting to empty string
		if (!$sourceContent) { $sourceContent = '' }
		if (!$destinationContent) { $destinationContent = '' }

		$diffs = Compare-Object $sourceContent $destinationContent

		# Skip if no differences between the files, meaning they are the same
		if ($diffs.Count -eq 0) { $skip = $true }

		if (!$skip) {

			if ($index -gt 1) { Write-Host "Attempt #$index...." }

			$sourceContent | Set-Content -Path $Destination

			$sourceContent = Get-Content $Source
			$destinationContent = Get-Content $Destination
		}

		$index++
	}

	if ($index -gt $retries) {
		throw "BAD THINGS!"
	}
}

function Start-PauseAndSleep {
	param(
		[int] $Seconds = 5,
		[int] $PollingFrequencyInMilliseconds = 100
	)
	
	Write-Host "Press any key to continue... Exiting in $seconds seconds."
	
	$counter = 0
	$loops = 50 # = (5 * 1000) / 100
	try {
		$loops = [Math]::Round(($Seconds * 1000) / $PollingFrequencyInMilliseconds)
	}
	catch { }

	while (!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt $loops)) {
		[Threading.Thread]::Sleep($PollingFrequencyInMilliseconds)
	}
}

#endregion FUNCTIONS

#region VARIABLES

# Variables - DO NOT CHANGE
# swapA is the first file to toggle
$swapA = $fileA
# swapB is the second file to toggle
$swapB = $fileB
$path = "C:\Windows\System32\drivers\etc"
$swap0 = "hosts"
$swapBLANK = "hosts_BLANK"
$swapBACKUP = "hosts_BACKUP"
$date = $(Get-Date).ToString("yyyy-MM-dd")
$fileIndex = 1
while (Test-Path ("$($path)\$($swapBACKUP)_$($date)_$($fileIndex)")) {
	$fileIndex += 1
}
$swapBACKUP = "$($swapBACKUP)_$($date)_$($fileIndex)"
$old = ""
$new = ""

#endregion VARIABLES

#region LOGIC

Write-Host " * Inputs (change in .ps1 file)"
Write-Host "A:    '$swapA'"
Write-Host "B:    '$swapB'"

Write-Host " * Determine state of files"

# Check for correct paths
if (!(Test-Path "$path\$swap0")) { throw "File not found: '$path\$swap0'" }
if (!(Test-Path "$path\$swapA")) { 
	if (Test-Path "$path\hosts_$swapA") { $swapA = "hosts_$swapA" }
	else { throw "File not found: '$path\$swapA'" }
}
if (!(Test-Path "$path\$swapB")) { 
	if (Test-Path "$path\hosts_$swapB") { $swapB = "hosts_$swapB" }
	else { throw "File not found: '$path\$swapB'" }
}
	
# Get content of files
$swap0content = Get-Content "$path\$swap0"
$swapAcontent = Get-Content "$path\$swapA"
$swapBcontent = Get-Content "$path\$swapB"

# Handle null file content by setting to empty string
if (!$swap0content) { $swap0content = '' }
if (!$swapAcontent) { $swapAcontent = '' }
if (!$swapBcontent) { $swapBcontent = '' }

$resultsA = Compare-Object $swap0content $swapAcontent
$resultsB = Compare-Object $swap0content $swapBcontent

if ($resultsA.Count -eq 0) {
	$old = $swapA
	$new = $swapB
}
elseif ($resultsB.Count -eq 0) {
	$old = $swapB
	$new = $swapA
}
else {
	Write-Host " * Existing file does not match options"
	Clear-Content -Path "$path\$swapBLANK" -Force

	Write-Host " * Copy existing file to '$swapBACKUP'"
	Copy-Item -Path "$path\$swap0" -Destination "$path\$swapBACKUP" -Force

	Write-Host " * Clear destination file"

	$old = "???"
	$new = $swapBLANK
}

Write-Host "Old:  '$old'"
Write-Host "New:  '$new'"

Set-HostsFile -source "$path\$new" -destination "$path\$swap0"

Write-Host " * BOOYAH!"

#endregion LOGIC

# Pause window for X seconds or until a key is pressed, but only if this script ran from the CMD .bat file
if ($fromCMD) {
	Write-Host ""
	Start-PauseAndSleep -Seconds 5
}
