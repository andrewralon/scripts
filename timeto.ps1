# timeto.ps1
# Purpose:  Closes non-related apps and services, then opens
#           related apps and services based on the given input.
# Requires: PowerShell, Administrator privileges, MultiMonitorTool.exe for display changes
# Usage:    timeto [action]
# Examples: timeto work
#           timeto play
#           timeto chill
#           timeto battery
# TO DO:
# * Resolve environment variables like '%programfiles(x86)%'

param(
	[string] $Action = ""
	, [string] $Command = $null
	, [switch] $Admin
)

#region CLASSES AND ENUMS

enum Type {
	App
	CommandString
	Script
	Service
}

enum Action {
	Work
	Play
	Chill
	Battery
}

class Thing {
	[Action] $Action
	[bool] $Start
	[bool] $AsAdmin
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
		$this.Object = $object
	}

	Thing (
		[Action] $action
		, [bool] $start
		, [bool] $asAdmin
		, [CommandString] $object
	) {
		$this.Action = $action
		$this.Start = $start
		$this.AsAdmin = $asAdmin
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
		$this.Object = $object
	}

	Thing (
		[Action] $action
		, [bool] $start
		, [bool] $asAdmin
		, [Script] $object
	) {
		$this.Action = $action
		$this.Start = $start
		$this.AsAdmin = $asAdmin
		$this.Object = $object
	}
}

class App {
	[string] $Name
	[string] $Path
	[string] $Arguments

	App(
		[string] $name
	) {
		$this.Name = $name
		$this.Path = $null
		$this.Arguments = $null
	}
	
	App(
		[string] $name
		, [string] $path
	) {
		$this.Name = $name
		$this.Path = $path
		$this.Arguments = $null
	}
		
	App(
		[string] $name
		, [string] $path
		, [string] $arguments
	) {
		$this.Name = $name
		$this.Path = $path
		$this.Arguments = $arguments
	}
}

class CommandString {
	[string] $CommandString

	CommandString(
		[string] $commandString
	) {
		$this.CommandString = $commandString
	}
}

class Script {
	[string] $File
	[string] $Arguments

	Script(
		[string] $file
	) {
		$this.File = $file
		$this.Arguments = $null
	}
	
	Script(
		[string] $file
		, [string] $arguments
	) {
		$this.File = $file
		$this.Arguments = $arguments
	}
}

class Service {
	[string] $Name
        
	Service(
		[string] $name
	) {
		$this.Name = $name
	}
}

#endregion CLASSES AND ENUMS

#region FUNCTIONS

function Invoke-KillServices {
	param(
		[Thing[]] $ServicesToKill
	)

	if ($ServicesToKill) {
		Write-Output "`n * Killing $($ServicesToKill.Count) service(s)...."
	}

	$index = 1
	foreach ($service in $ServicesToKill) {

		Write-Output "$(($index++)) - $($service.Object.Name)"

		if (Get-Service $service.Object.Name -ErrorAction SilentlyContinue) {
			Stop-Service $service.Object.Name #-Force
		}
	}
}

function Invoke-StartServices {
	param(
		[Thing[]] $ServicesToStart
	)

	if ($ServicesToStart) {
		Write-Output "`n * Starting $($ServicesToStart.Object.Count) service(s)...."
	}

	$index = 1
	foreach ($service in $ServicesToStart) {

		Write-Output "$(($index++)) - $($service.Object.Name)"

		if (Get-Service $service.Object.Name -ErrorAction SilentlyContinue) {
			Start-Service $service.Object.Name
		}
	}
}

function Invoke-KillApps {
	param(
		[Thing[]] $AppsToKill
	)

	if ($AppsToKill) {
		Write-Output "`n * Killing $($AppsToKill.Count) app(s)...."
	}

	$index = 1
	foreach ($app in $AppsToKill) {

		Write-Output "$(($index++)) - $($app.Object.Name)"

		$processes = Get-Process $app.Object.Name -ErrorAction SilentlyContinue

		try {
			foreach ($process in $processes) {
				$process.CloseMainWindow() | Out-Null
			}
		}
		catch [Exception] {
			# Stop-Process -Name $processes.Name #-Force
		}

		# Close any processes that didn't respond to .CloseMainWindow()
		$process = Get-Process $app.Object.Name -ErrorAction SilentlyContinue
		if ($process) {
			Stop-Process -Name $process.Name #-Force
		}
	}
}

function Invoke-StartApps {
	param(
		[Thing[]] $AppsToStart
	)

	if ($AppsToStart) {
		Write-Output "`n * Starting $($AppsToStart.Count) app(s)...."
	}

	$index = 1
	foreach ($app in $AppsToStart) {

		Write-Output "$(($index++)) - $($app.Object.Name)"

		if (!(Get-Process $app.Object.Name -ErrorAction SilentlyContinue)) {

			if ($app.Object.Arguments) {
				Start-Process $app.Object.Path $app.Object.Arguments
			}
			else {
				Start-Process $app.Object.Path
			}
		}
	}
}

function Invoke-RunCommands {
	param(
		[Thing[]] $CommandsToRun
	)

	if ($CommandsToRun) {
		Write-Output "`n * Running $($CommandsToRun.Count) script(s)...."
	}

	$index = 1
	foreach ($command in $CommandsToRun) {

		Write-Output "$(($index++)) - $($command.Object.CommandString)"

		Invoke-Expression -Command "$($command.Object.CommandString)"
	}
}


function Invoke-RunScripts {
	param(
		[Thing[]] $ScriptsToRun
	)

	if ($ScriptsToRun) {
		Write-Output "`n * Running $($ScriptsToRun.Count) script(s)...."
	}

	$index = 1
	foreach ($script in $ScriptsToRun) {

		Write-Output "$(($index++)) - $($script.Object.File) $($script.Object.Arguments)"

		if ($script.Object.Arguments) {
			Invoke-Expression -Command "& '$($script.Object.File)' $($script.Object.Arguments)"
		}
		else {
			Invoke-Expression -Command "& '$($script.Object.File)'" 
		}
	}
}

#endregion FUNCTIONS

#region VARIABLES

$debug = $false
$secondsToWait = 5
$things = @(
	# Action, Start, AsAdmin, Type
	# [Thing]::new([Action]::<ACTION>, $<BOOL>, $<BOOL>, [<TYPE>]::(<PARAM1, PARAM2>))

	[Thing]::new([Action]::Work, $true, $true, [Service]::new("PanGPS"))

	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Discord", "%USERPROFILE%\AppData\Local\Discord\Update.exe", "--processStart Discord.exe"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("EpicGamesLauncher", "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("GitHubDesktop"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Origin", "C:\Program Files (x86)\Origin\Origin.exe"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Postman"))
	, [Thing]::new([Action]::Play, $false, $false, [App]::new("Snap Camera"))
	, [Thing]::new([Action]::Play, $true, $false, [App]::new("Steam", "C:\Program Files (x86)\Steam\steam.exe"))

	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Chrome", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", '--profile-directory="Default"'))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Dropbox", "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe", "/home"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Evernote", "C:\Program Files (x86)\Evernote\Evernote\Evernote.exe"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("EvernoteTray"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Excel"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("KeePass"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("notepad++", "C:\Program Files\Notepad++\notepad++.exe"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("OneDrive", "%USERPROFILE%\AppData\Local\Microsoft\OneDrive\OneDrive.exe")) # Requires NON-admin
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Outlook", "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("RemoteDesktopManager64", "C:\Program Files (x86)\Devolutions\Remote Desktop Manager\RemoteDesktopManager64.exe"))
	, [Thing]::new([Action]::Work, $false, $false, [App]::new("Slack"))
	, [Thing]::new([Action]::Work, $false, $true, [App]::new("Taskmgr"))
	, [Thing]::new([Action]::Work, $true, $false, [App]::new("Teams", "%USERPROFILE%\AppData\Local\Microsoft\Teams\Update.exe", "--processStart Teams.exe"))
	
	, [Thing]::new([Action]::Play, $true, $false, [CommandString]::new("multimonitortool /disable 3"))
	, [Thing]::new([Action]::Play, $true, $false, [CommandString]::new("ipconfig /flushdns"))
	, [Thing]::new([Action]::Work, $true, $false, [CommandString]::new("multimonitortool /enable 3"))

	, [Thing]::new([Action]::Battery, $true, $true, [Script]::new("Set-NetworkAdapterState.ps1", "off -NoDelay"))
)

#endregion VARIABLES

#region LOGIC

if ([Action].GetEnumNames() -icontains $Action) {

	$servicesToKill = $things.Where( { 
			$_.Object -like [Service] -and 
			$_.Action -notlike $Action -and 
			$_.AsAdmin -like $Admin } )
	$servicesToStart = $things.Where( { 
			$_.Object -like [Service] -and 
			$_.Action -like $Action -and 
			$_.AsAdmin -like $Admin -and 
			$_.Start } )
	$appsToKill = $things.Where( { 
			$_.Object -like [App] -and 
			$_.Action -notlike $Action -and 
			$_.AsAdmin -like $Admin } )
	$appsToStart = $things.Where( { 
			$_.Object -like [App] -and  
			$_.Action -like $Action -and 
			$_.AsAdmin -like $Admin -and 
			$_.Start } )
	$scriptsToRun = $things.Where( { 
			$_.Object -like [Script] -and 
			$_.Action -like $Action -and 
			$_.AsAdmin -like $Admin } )

	if ($debug) {
		$index = 1
		foreach ($thing in $things) {
			Write-Output "  $(($index++)) of $($things.Count)"
			Write-Output "Start:     '$($thing.Start)'"
			Write-Output "AsAdmin:   '$($thing.AsAdmin)'"
			Write-Output "Name:      '$($thing.Object.Name)'"
			Write-Output "Object:    '$($thing.Object)'"
			Write-Output "Action:    '$($thing.Action)'"
			Write-Output "Path:      '$($thing.Object.Path)'"
			Write-Output "Arguments: '$($thing.Object.Arguments)'"
			Write-Output "Command:   '$($thing.Object.Command)'"
		}
			
		Write-Output "--"
		Write-Output "Action:          '$($Action)'"
		Write-Output "servicesToKill:  '$($servicesToKill.Count)'"
		Write-Output "servicesToStart: '$($servicesToStart.Count)'"
		Write-Output "appsToKill:      '$($appsToKill.Count)'"
		Write-Output "appsToStart:     '$($appsToStart.Count)'"
		Write-Output "scriptsToRun:    '$($scriptsToRun.Count)'"
		Write-Output "--"
	}

	Write-Output "** TIME TO $($Action.ToUpper())! **"
	Write-Output "ADMIN: $Admin"

	Invoke-KillServices $servicesToKill
	Invoke-StartServices $servicesToStart
	Invoke-KillApps $appsToKill
	Invoke-StartApps $appsToStart
	Invoke-RunScripts $scriptsToRun
}
else {
	Write-Output "** TIME TO.... $($Action)??? **"
	Write-Output "No idea what to do with that one."
}

Write-Output ""
Write-Output "Exiting in $secondsToWait seconds...."
Start-Sleep -Seconds $secondsToWait

#endregion LOGIC
