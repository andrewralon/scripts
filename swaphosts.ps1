# swaphosts.ps1
#Requires -RunAsAdministrator
# PURPOSE:  Swap / toggle / replace hosts files in C:\Windows\System32\drivers\etc

param(
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

#endregion FUNCTIONS

#region VARIABLES

# Variables - CHANGE AS NEEDED
# swapA is the first file to toggle
$swapA = "hosts_BLANK"
# swapB is the second file to toggle
$swapB = "hosts_GN-RC2-2019"

# Variables - DO NOT CHANGE
$path = "C:\Windows\System32\drivers\etc"
$old = ""
$new = ""
$swap0 = "hosts"
$swapBLANK = "hosts_BLANK"
$swapBACKUP = "hosts_BACKUP"
$date = $(Get-Date).ToString("yyyy-MM-dd")
$fileIndex = 1
while (Test-Path ("$($path)\$($swapBACKUP)_$($date)_$($fileIndex)")) {
	$fileIndex += 1
}
$swapBACKUP = "$($swapBACKUP)_$($date)_$($fileIndex)"

#endregion VARIABLES

#region LOGIC

Write-Host " * Inputs (change in .ps1 file)"
Write-Host "A:    '$swapA'"
Write-Host "B:    '$swapB'"

Write-Host " * Determine state of files"

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

# Keep the PowerShell window if this script ran from the CMD .bat file
if ($fromCMD) {
	Write-Host ""
	Pause
}
