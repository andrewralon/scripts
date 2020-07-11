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
	[string] $Action = ""
	, [string] $Command = $null
	, [switch] $Admin
	, [switch] $Debug
)

#region CLASSES AND ENUMS

enum Action {
	Battery
	Chill
	Work
	Play
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
		, [bool] $Debug
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
	$padIndex = ([string]$thingsToProcess.Count).Length

	if ($Debug) {
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

		$verb = & { if ($thing.Action -like $Action) { "Starting" } else { "Killing" } }
		$verb = & { if ($thing.Action -like $Action -and - !$thing.Start) { "Leaving" } else { $verb } }
		$verb = & { if ($thing.Action -like $Action -and $thing.Object -like [Cmd]) { "Running" } else { $verb } }
		$title = & { if ($thing.Object.Name) { $thing.Object.Name } else { $thing.Object.Command } }
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

		Write-Output "  $(($indexP)) of $($thingsToProcess.Count) - $($verbP) $($nounP) - $($title)"

		if ($thing.Action -notlike $Action) {
			if ($thing.Object -like [App]) {
				Invoke-KillApps @($thing)
			}
			elseif ($thing.Object -like [Cmd]) {
				# Do nothing
			}
			elseif ($thing.Object -like [Service]) {
				Invoke-KillServices @($thing)
			}
			else {
				Write-Warning "Verb: Unknown object!"
			}
		}
		elseif ($thing.Action -like $Action -and $thing.Start ) {
			if ($thing.Object -like [App]) {
				Invoke-StartApps @($thing)
			}
			elseif ($thing.Object -like [Cmd]) {
				Invoke-RunCommands @($thing)
			}
			elseif ($thing.Object -like [Service]) {
				Invoke-StartServices @($thing)
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
	param( [Thing[]] $ServicesToKill )

	foreach ($service in $ServicesToKill) {
		if (Get-Service $service.Object.Name -ErrorAction SilentlyContinue) {
			Stop-Service $service.Object.Name
		}
	}
}

function Invoke-StartServices {
	param( [Thing[]] $ServicesToStart )

	foreach ($service in $ServicesToStart) {
		if (Get-Service $service.Object.Name -ErrorAction SilentlyContinue) {
			Start-Service $service.Object.Name
		}
	}
}

function Invoke-KillApps {
	param( [Thing[]] $AppsToKill )

	foreach ($thing in $AppsToKill) {
		$processes = Get-Process $thing.Name -ErrorAction SilentlyContinue
		
		foreach ($process in $processes) {
			try {
				$process.CloseMainWindow() | Out-Null
			}
			catch {
				Write-Warning "Exception during 'process.CloseMainWindow() | Out-Null'"
			}
		}
			
		# Close any processes that didn't respond to process.CloseMainWindow()
		$process = Get-Process $thing.Name -ErrorAction SilentlyContinue
		if ($process) {
			try {
				Stop-Process -Name $process.Name
			}
			catch {
				Write-Warning "Exception during 'Stop-Process -Name $($process.Name)'"
			}
		}
	}
}

function Invoke-StartApps {
	param( [Thing[]] $AppsToStart )

	foreach ($app in $AppsToStart) {
		if (!(Get-Process $app.Object.Name -ErrorAction SilentlyContinue)) {
			if ($app.Object.Path -and $app.Object.Arguments) {
				Start-Process $app.Object.Path $app.Object.Arguments
			}
			elseif ($app.Object.Path) {
				Start-Process $app.Object.Path
			}
			else {
				Write-Warning "Unable to start. Path is empty!"
			}
		}
	}
}

function Invoke-RunCommands {
	param( [Thing[]] $CommandsToRun )

	foreach ($command in $CommandsToRun) {
		Invoke-Expression -Command "$($command.Object.Command)"
	}
}

#endregion FUNCTIONS

#region VARIABLES

$secondsToWait = 5
$things = @(
	# Action, Start, AsAdmin, Type
	# [Thing]::new([Action]::<ACTION>, $<BOOL>, $<BOOL>, [<TYPE>]::(<PARAM1, PARAM2>))

	[Thing]::new([Action]::Work, $true, $true, [Service]::new("PanGPS"))

	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Evernote", "${env:ProgramFiles(x86)}\Evernote\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Chill, $false, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("OneDrive", "${env:USERPROFILE}\AppData\Local\Microsoft\OneDrive\OneDrive.exe")) # Requires NON-admin
	, [Thing]::new([Action]::Chill, $true, $false, [App]::new("Slack", "${env:USERPROFILE}\AppData\Local\slack\slack.exe"))

	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Discord", "${env:USERPROFILE}\AppData\Local\Discord\Update.exe", "--processStart Discord.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("EpicGamesLauncher", "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Evernote", "${env:ProgramFiles(x86)}\Evernote\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Origin", "${env:ProgramFiles(x86)}\Origin\Origin.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Snap Camera"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Slack", "${env:USERPROFILE}\AppData\Local\slack\slack.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Steam", "${env:ProgramFiles(x86)}\Steam\steam.exe"))

	, [Thing]::new([Action]::Work, $false, $false, [App]::new("Beyond Compare"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Chrome", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", '--profile-directory="Default"'))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Dropbox", "${env:ProgramFiles(x86)}\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Evernote", "${env:ProgramFiles(x86)}\Evernote\Evernote\Evernote.exe"))
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
	, [Thing]::new([Action]::Chill, $true, $false, [Cmd]::new("multimonitortool /enable 3"))

	, [Thing]::new([Action]::Play, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 on -NoDelay"))
	, [Thing]::new([Action]::Play, $true, $false, [Cmd]::new("multimonitortool /disable 3"))
	, [Thing]::new([Action]::Play, $true, $false, [Cmd]::new("ipconfig /flushdns"))

	, [Thing]::new([Action]::Work, $true, $false, [Cmd]::new("multimonitortool /enable 3"))
	, [Thing]::new([Action]::Work, $true, $true, [Cmd]::new("Set-NetworkAdapterState.ps1 on -NoDelay"))
)

#endregion VARIABLES

#region LOGIC

if ([Action].GetEnumNames() -icontains $Action) {
	$thingsToDo = $things.Where( { $_.AsAdmin -like $Admin } )

	Write-Output "** TIME TO $($Action.ToUpper())! **"
	Write-Output "Admin: '$($Admin)'"
	
	if ($Debug) {
		Write-Output "--"

		$index = 1
		foreach ($thing in $thingsToDo) {
			$object = $thing.Object
			Write-Output "  $(($index++)) of $($thingsToDo.Count) - $($thing.Name)"
			Write-Output "Action:    '$($thing.Action)'"
			Write-Output "Start:     '$($thing.Start)'"
			& { if ($thing.AsAdmin) { Write-Output "AsAdmin:   '$($thing.AsAdmin)'" } }
			Write-Output "Object:    '$($thing.Object)'"
			& { if ($object.Path) { Write-Output "Path:      '$($object.Path)'" } }
			& { if ($object.Arguments) { Write-Output "Arguments: '$($object.Arguments)'" } }
		}
		
		Write-Output ""
		Write-Output "Action:           '$($Action)'"
		Write-Output "Debug:            '$($Debug)'"
		Write-Output "thingsToDo.Count: '$($thingsToDo.Count)'"
		Write-Output "--"
	}

	Invoke-DoAllTheThings $Action $thingsToDo $Debug
}
else {
	Write-Output "** TIME TO.... $($Action)??? **"
	Write-Output "No idea what to do with that one."
}

Write-Output ""
Write-Output "BOOYAH!"

if ($Debug) {
	Pause
}
else {
	Write-Output ""
	Write-Output "Exiting in $secondsToWait seconds...."
	Start-Sleep -Seconds $secondsToWait
	Pause
}

#endregion LOGIC
