# timeto.ps1
# Purpose:  Closes non-related apps and services, then opens
#           related apps and services based on the given input.
# Requires: PowerShell, Administrator privileges, MultiMonitorTool.exe for display changes
# Usage:    timeto [action]
# Examples: timeto work
#           timeto play
#           timeto chill
#           timeto battery

param(
	[string] $Action
	, [switch] $Admin
	, [Alias('v')][switch] $Verbose
	, [Alias('p')][switch] $Pause
	, [Alias('w')][switch] $WhatIf
)

#region CLASSES AND ENUMS

enum Action {
	Battery
	Chill
	Play
	Work
}

enum Type {
	App
	Cmd
	Service
}

class Thing {
	[Action] $Action
	[bool] $Start
	[bool] $AsAdmin
	[string] $Name
	[System.Object] $Object

	Thing (
		[Action] $action
		, [bool] $start
		, [bool] $asAdmin
		, [App] $object
	) {
		$this.Action = $action
		$this.Start = $start
		$this.AsAdmin = $asAdmin
		$this.Name = $object.Name
		$this.Object = $object
	}

	Thing (
		[Action] $action
		, [bool] $start
		, [bool] $asAdmin
		, [Cmd] $object
	) {
		$this.Action = $action
		$this.Start = $start
		$this.AsAdmin = $asAdmin
		$this.Name = $object.Command
		$this.Object = $object
	}

	Thing (
		[Action] $action
		, [bool] $start
		, [bool] $asAdmin
		, [Service] $object
	) {
		$this.Action = $action
		$this.Start = $start
		$this.AsAdmin = $asAdmin
		$this.Name = $object.Name
		$this.Object = $object
	}
}

class App {
	[string] $Name
	[string] $Path
	[string] $Arguments

	App (
		[string] $name
	) {
		$this.Name = $name
		$this.Path = $null
		$this.Arguments = $null
	}
	
	App (
		[string] $name
		, [string] $path
	) {
		$this.Name = $name
		$this.Path = $path
		$this.Arguments = $null
	}
		
	App (
		[string] $name
		, [string] $path
		, [string] $arguments
	) {
		$this.Name = $name
		$this.Path = $path
		$this.Arguments = $arguments
	}
}

class Cmd {
	[string] $Command

	Cmd (
		[string] $command
	) {
		$this.Command = $command
	}
}

class Service {
	[string] $Name

	Service (
		[string] $name
	) {
		$this.Name = $name
	}
}

#endregion CLASSES AND ENUMS

#region FUNCTIONS

function Invoke-DoAllTheThings {
	param( 
		[Action] $Action
		, [Thing[]] $ThingsToDo
		, [switch] $PSCore
		, [switch] $WhatIf
	)
	
	$thingsToStart = @()
	$thingsToKill = @()
	$uniqueThingsToStart = @()
	$uniqueThingsToKill = @()

	foreach ($thing in $ThingsToDo.Where( { $_.Action -like $Action -or ($_.Action -like $Action -and $_.Object -like [Cmd]) } ) ) {
		if ($uniqueThingsToStart -notcontains $thing.Name) {
			$uniqueThingsToStart += $thing.Name
			$thingsToStart += $thing
		}
	}

	foreach ($thing in $ThingsToDo.Where( { $_.Action -notlike $Action -and $_.Object -notlike [Cmd] } ) ) {
		if ($uniqueThingsToKill -notcontains $thing.Name -and $uniqueThingsToStart -notcontains $thing.Name) {
			$uniqueThingsToKill += $thing.Name
			$thingsToKill += $thing
		}
	}
	
	$thingsToProcess = $thingsToKill + $thingsToStart
	$padIndex = ([string] $thingsToProcess.Count).Length

	if ($Verbose) {
		Write-Output "--"
		Write-Output "  thingsToStart.Count:   '$($thingsToStart.Count)'"
		foreach ($thing in $thingsToStart) { Write-Output $thing.Name }
	
		Write-Output ""
		Write-Output "  thingsToKill.Count:    '$($thingsToKill.Count)'"
		foreach ($thing in $thingsToKill) { Write-Output $thing.Name }
		
		Write-Output ""
		Write-Output "  thingsToProcess.Count: '$($thingsToProcess.Count)'"
		Write-Output "--"
	}
	
	$index = 1
	foreach ($thing in $thingsToProcess) {

		$verb = if ($thing.Action -like $Action) { "Starting" } else { "Killing" }
		$verb = if ($thing.Action -like $Action -and - !$thing.Start) { "Leaving" } else { $verb }
		$verb = if ($thing.Action -like $Action -and $thing.Object -like [Cmd]) { "Running" } else { $verb }
		$title = if ($thing.Object.Name) { $thing.Object.Name } else { $thing.Object.Command }
		$noun = switch ($thing.Object) {
			"App" { "  app  "; break; }
			"Cmd" { "command"; break; }
			"Service" { "service"; break; }
			default { "unknown"; break; }
		}
			
		$padVerb = [Math]::Max($verb.Length, 8)
		$indexP = ([string]($index++)).PadLeft($padIndex)
		$verbP = $verb.PadRight($padVerb)
		$nounP = $noun.PadRight(7)

		Write-Output "$(($indexP)) of $($thingsToProcess.Count) - $($verbP) $($nounP) - $($title)"

		if ($thing.Action -notlike $Action) {
			if ($thing.Object -like [App]) {
				Invoke-KillApps @($thing) -WhatIf:$WhatIf -PSCore:$PSCore
			}
			elseif ($thing.Object -like [Cmd]) {
				# Do nothing
			}
			elseif ($thing.Object -like [Service]) {
				Invoke-KillServices @($thing) -WhatIf:$WhatIf -PSCore:$PSCore
			}
			else {
				Write-Warning "Verb: Unknown object!"
			}
		}
		elseif ($thing.Action -like $Action -and $thing.Start ) {
			if ($thing.Object -like [App]) {
				Invoke-StartApps @($thing) -WhatIf:$WhatIf -PSCore:$PSCore
			}
			elseif ($thing.Object -like [Cmd]) {
				Invoke-RunCommands @($thing) -WhatIf:$WhatIf -PSCore:$PSCore
			}
			elseif ($thing.Object -like [Service]) {
				Invoke-StartServices @($thing) -WhatIf:$WhatIf -PSCore:$PSCore
			}
			else {
				Write-Warning "Verb: Unknown object"
			}
		}
		elseif ($thing.Action -like $Action -and !$thing.Start ) {
			# Do nothing
		}
		else {
			Write-Warning "Action: Unknown state!"
		}
	}
}

function Invoke-KillServices {
	param(
		[Thing[]] $ServicesToKill
		, [switch] $PSCore
		, [switch] $WhatIf
	)

	foreach ($thing in $ServicesToKill) {
		if (Get-Service $thing.Object.Name -ErrorAction SilentlyContinue) {
			Stop-Service $thing.Object.Name -WhatIf:$WhatIf
		}
	}
}

function Invoke-StartServices {
	param(
		[Thing[]] $ServicesToStart
		, [switch] $PSCore
		, [switch] $WhatIf
	)

	foreach ($thing in $ServicesToStart) {
		if (Get-Service $thing.Object.Name -ErrorAction SilentlyContinue) {
			Start-Service $thing.Object.Name -WhatIf:$WhatIf
		}
	}
}

function Invoke-KillApps {
	param(
		[Thing[]] $AppsToKill
		, [switch] $PSCore
		, [switch] $WhatIf
	)

	foreach ($thing in $AppsToKill) {
		$processes = Get-Process $thing.Object.Name -ErrorAction SilentlyContinue
		
		foreach ($process in $processes) {
			try {
				if (!$WhatIf) {
					$process.CloseMainWindow() | Out-Null
				}
			}
			catch {
				Write-Warning "Exception during 'process.CloseMainWindow() | Out-Null'"
			}
		}
			
		# Close any processes that didn't respond to process.CloseMainWindow()
		$process = Get-Process $thing.Object.Name -ErrorAction SilentlyContinue
		if ($process) {
			try {
				Stop-Process -Name $process.Name -WhatIf:$WhatIf
			}
			catch {
				Write-Warning "Exception during 'Stop-Process -Name $($process.Name)'"
			}
		}
	}
}

function Invoke-StartApps {
	param(
		[Thing[]] $AppsToStart
		, [switch] $PSCore
		, [switch] $WhatIf
	)

	foreach ($thing in $AppsToStart) {
		if (!(Get-Process $thing.Object.Name -ErrorAction SilentlyContinue)) {
			if ($thing.Object.Path -and $thing.Object.Arguments) {
				if ($PSCore) {
					Start-Process $thing.Object.Path $thing.Object.Arguments -WhatIf:$WhatIf
				}
				else {
					if (!$WhatIf) {
						Start-Process $thing.Object.Path $thing.Object.Arguments
					}
				}
			}
			elseif ($thing.Object.Path) {
				if ($PSCore) {
					Start-Process $thing.Object.Path -WhatIf:$WhatIf
				}
				else {
					if (!$WhatIf) {
						Start-Process $thing.Object.Path
					}
				}
			}
			else {
				Write-Warning "Unable to start. Path is empty!"
			}
		}
	}
}

function Invoke-RunCommands {
	param(
		[Thing[]] $CommandsToRun
		, [switch] $PSCore
		, [switch] $WhatIf
	)

	if (!$WhatIf) {
		foreach ($thing in $CommandsToRun) {
			Invoke-Expression -Command "$($thing.Object.Command)"
		}
	}
}

#endregion FUNCTIONS

#region VARIABLES

$secondsToWait = 5
$things = @(
	# Action, Start, AsAdmin, Type
	# [Thing]::new([Action]::<ACTION>, $<BOOL>, $<BOOL>, [<TYPE>]::(<PARAM1, PARAM2>))

	[Thing]::new([Action]::Work, $true, $true, [Service]::new("PanGPS"))

	, [Thing]::new([Action]::Chill, $false, $false, [App]::new("Chrome", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", '--profile-directory="Default"'))
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Evernote", "${env:USERPROFILE}\AppData\Local\Programs\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Chill, $false, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("OneDrive", "${env:USERPROFILE}\AppData\Local\Microsoft\OneDrive\OneDrive.exe")) # Requires NON-admin
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Slack", "${env:USERPROFILE}\AppData\Local\slack\slack.exe"))

	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Discord", "${env:USERPROFILE}\AppData\Local\Discord\Update.exe", "--processStart Discord.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("EpicGamesLauncher", "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Evernote", "${env:USERPROFILE}\AppData\Local\Programs\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Origin", "${env:ProgramFiles(x86)}\Origin\Origin.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Snap Camera"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Slack", "${env:USERPROFILE}\AppData\Local\slack\slack.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Steam", "${env:ProgramFiles(x86)}\Steam\steam.exe"))

	, [Thing]::new([Action]::Work, $false, $false, [App]::new("BCompare"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Chrome", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "--profile-directory='Default'"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Evernote", "${env:USERPROFILE}\AppData\Local\Programs\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("Excel"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("GitHubDesktop"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("KeePass"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("notepad++", "${env:ProgramFiles}\Notepad++\notepad++.exe"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("OneDrive", "${env:USERPROFILE}\AppData\Local\Microsoft\OneDrive\OneDrive.exe")) # Requires NON-admin
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Outlook", "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\OUTLOOK.EXE"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("Postman"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("RemoteDesktopManager64", "${env:ProgramFiles(x86)}\Devolutions\Remote Desktop Manager\RemoteDesktopManager64.exe"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("Slack", "${env:USERPROFILE}\AppData\Local\slack\slack.exe"))
	, [Thing]::new([Action]::Work, $false, $true, [App]::new("Taskmgr"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Teams", "${env:USERPROFILE}\AppData\Local\Microsoft\Teams\Update.exe", "--processStart Teams.exe"))
	
	, [Thing]::new([Action]::Battery, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 off -NoDelay"))

	, [Thing]::new([Action]::Chill, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 on -NoDelay"))
	, [Thing]::new([Action]::Chill, $true, $false, [Cmd]::new("multimonitortool /enable 1"))
	, [Thing]::new([Action]::Chill, $true, $false, [Cmd]::new("multimonitortool /enable 2"))
	, [Thing]::new([Action]::Chill, $true, $false, [Cmd]::new("multimonitortool /enable 3"))

	, [Thing]::new([Action]::Play, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 on -NoDelay"))
	# , [Thing]::new([Action]::Play, $true, $false, [Cmd]::new("multimonitortool /disable 1"))
	# , [Thing]::new([Action]::Play, $true, $false, [Cmd]::new("multimonitortool /disable 3"))
	, [Thing]::new([Action]::Play, $true, $false, [Cmd]::new("ipconfig /flushdns"))

	, [Thing]::new([Action]::Work, $true, $false, [Cmd]::new("multimonitortool /enable 1"))
	, [Thing]::new([Action]::Work, $true, $false, [Cmd]::new("multimonitortool /enable 2"))
	, [Thing]::new([Action]::Work, $true, $false, [Cmd]::new("multimonitortool /enable 3"))
	, [Thing]::new([Action]::Work, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 on -NoDelay"))
)
$PSVersion = $PSVersionTable.PSVersion.ToString()
$PSCore = if ($PSVersion -ge 6) { $true } else { $false }

#endregion VARIABLES

#region LOGIC

if ([Action].GetEnumNames() -icontains $Action) {

	$thingsToDo = $things.Where( { $_.AsAdmin -like $Admin } )
	Write-Output "** TIME TO $($Action.ToUpper())! **"

	if (!$Verbose) {
		Write-Output "Admin:   '$($Admin)'"
		Write-Output "WhatIf:  '$($WhatIf)'"
		Write-Output "thingsToDo.Count: '$($thingsToDo.Count)'"
	}
	else {
		Write-Output "Action:  '$($Action)'"
		Write-Output "Admin:   '$($Admin)'"
		Write-Output "Verbose: '$($Verbose)'"
		Write-Output "Pause:   '$($Pause)'"
		Write-Output "WhatIf:  '$($WhatIf)'"
		Write-Output "PSCore:  '$($PSCore)'"
		Write-Output "thingsToDo.Count: '$($thingsToDo.Count)'"

		Write-Output "--"

		$index = 1
		foreach ($thing in $thingsToDo) {
			$object = $thing.Object
			Write-Output "  $(($index++)) of $($thingsToDo.Count) - $($thing.Name)"
			Write-Output "Action:    '$($thing.Action)'"
			Write-Output "Start:     '$($thing.Start)'"
			if ($thing.AsAdmin) { Write-Output "AsAdmin:   '$($thing.AsAdmin)'" }
			Write-Output "Object:    '$($thing.Object)'"
			if ($object.Path) { Write-Output "Path:      '$($object.Path)'" }
			if ($object.Arguments) { Write-Output "Arguments: '$($object.Arguments)'" }
		}
		
		Write-Output "--"
		Write-Output "Action:  '$($Action)'"
		Write-Output "Admin:   '$($Admin)'"
		Write-Output "Verbose: '$($Verbose)'"
		Write-Output "Pause:   '$($Pause)'"
		Write-Output "WhatIf:  '$($WhatIf)'"
		Write-Output "PSCore:  '$($PSCore)'"
		Write-Output "thingsToDo.Count: '$($thingsToDo.Count)'"
	}

	Invoke-DoAllTheThings $Action $thingsToDo -PSCore:$PSCore -WhatIf:$WhatIf
}
else {
	Write-Output "** TIME TO.... $($Action)??? **"
	Write-Output "No idea what to do with that one."
}

Write-Output ""
Write-Output " * BOOYAH!"
Write-Output ""

if ($Pause) {
	Pause
}
else {
	Write-Output "Exiting in $secondsToWait seconds...."
	Start-Sleep -Seconds $secondsToWait
}

#endregion LOGIC
