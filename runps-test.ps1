Write-Host " * runps-test.ps1"
Write-Host " * args: '$($args.Count)'"

$index = 1
foreach ($arg in $args) {
	Write-Host "$(($index++)) of $($args.Count):  '$arg'"
}

Write-Host " * BOOYAH!"

Pause
