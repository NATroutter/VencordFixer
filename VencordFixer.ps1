###########################################################################
#                                                                         #
#                           NOTICE / DISCLAIMER                           #
#                                                                         #
# I'm well a wear how bad and ugly this code is and i'm not proud of it   #
# but i needed to make some kind of fix for problem that i had            #
# and i wanted to playaround with powershell scripts                      #
###########################################################################

[CmdletBinding(DefaultParameterSetName = 'gui')]
param(
	[Parameter(ParameterSetName = 'repair')]
	[switch]$repair,

	[Parameter(ParameterSetName = 'help')]
	[switch]$help
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

######################
#       SCRIPT       #
######################

#Function to parse variables in config values
function Expand-JsonVariables($object) {
	$object.PSObject.Properties | ForEach-Object {
		if ($_.Value -is [string]) {
			$_.Value = $ExecutionContext.InvokeCommand.ExpandString($_.Value)
		}
		elseif ($_.Value -is [PSCustomObject]) {
			$_.Value = Expand-JsonVariables($_.Value)
		}
	}
	return $object
}

#Load config
$Config = Expand-JsonVariables(Get-Content -Path $(Join-Path $PSScriptRoot "config.json") | ConvertFrom-Json)

#GUI Characters
$H = [string][char]9552
$V = [string][char]9553
$TL = [string][char]9556
$TR = [string][char]9559
$BL = [string][char]9562
$BR = [string][char]9565

#Global Variables
$Index = 0
$Options = @("Install Shortcut", "Fix Vencord", "Display help", "Exit")

function Show-Banner {
	Clear-Host
	Write-Host $TL$($H * 67)$TR -ForegroundColor Red
	Write-Host $V -NoNewline -ForegroundColor Red
	Write-Host "   _    __                               _________                " -ForegroundColor DarkRed -NoNewline
	Write-Host " $V" -ForegroundColor Red
	Write-Host $V -NoNewline -ForegroundColor Red
	Write-Host "  | |  / /__  ____  _________  _________/ / ____(_)  _____  _____ " -ForegroundColor DarkRed -NoNewline
	Write-Host " $V" -ForegroundColor Red
	Write-Host $V -NoNewline -ForegroundColor Red
	Write-Host "  | | / / _ \/ __ \/ ___/ __ \/ ___/ __  / /_  / / |/_/ _ \/ ___/ " -ForegroundColor DarkRed -NoNewline
	Write-Host " $V" -ForegroundColor Red
	Write-Host $V -NoNewline -ForegroundColor Red
	Write-Host "  | |/ /  __/ / / / /__/ /_/ / /  / /_/ / __/ / />  </  __/ /     " -ForegroundColor DarkRed -NoNewline
	Write-Host " $V" -ForegroundColor Red
	Write-Host $V -NoNewline -ForegroundColor Red
	Write-Host "  |___/\___/_/ /_/\___/\____/_/   \__,_/_/   /_/_/|_|\___/_/      " -ForegroundColor DarkRed -NoNewline
	Write-Host " $V" -ForegroundColor Red
	Write-Host $V (" " * 65) $V -NoNewline -ForegroundColor Red
	Write-Host " "

	Write-Host $V -ForegroundColor Red -NoNewline
	Write-Host " Author: " -ForegroundColor Gray -NoNewline
	Write-Host "NATroutter" -ForegroundColor Yellow -NoNewline
	Write-Host "$(" " * 48)$V" -ForegroundColor Red

	Write-Host $V -ForegroundColor Red -NoNewline
	Write-Host " Version: " -ForegroundColor Gray -NoNewline
	Write-Host "1.0.0" -ForegroundColor Yellow -NoNewline
	Write-Host "$(" " * 52)$V" -ForegroundColor Red

	Write-Host $V -ForegroundColor Red -NoNewline
	Write-Host " Website: " -ForegroundColor Gray -NoNewline
	Write-Host "https://NATroutter.fi" -ForegroundColor Yellow -NoNewline
	Write-Host "$(" " * 36)$V" -ForegroundColor Red

	Write-Host $V -ForegroundColor Red -NoNewline
	Write-Host " Project: " -ForegroundColor Gray -NoNewline
	Write-Host "https://git.nat.gg/VencordFixer" -ForegroundColor Yellow -NoNewline
	Write-Host "$(" " * 26)$V" -ForegroundColor Red

	Write-Host $V (" " * 65) $V -ForegroundColor Red
	Write-Host $BL$($H * 67)$BR -ForegroundColor Red
	Write-Host " "
}

function Show-Help {
	Show-Banner
	Write-Host "Parameters:" -ForegroundColor DarkRed
	Write-Host "-repair " -ForegroundColor Red -NoNewline
	Write-Host "Activate the vencord fixing whitout gui" -ForegroundColor Gray

	Write-Host "-help " -ForegroundColor Red -NoNewline
	Write-Host "Shows this help message" -ForegroundColor Gray

	Write-Host " "
	Write-Host "Example paramter usage:" -ForegroundColor DarkRed
	Write-Host "./VencordFixer.ps1 -repair " -ForegroundColor Red -NoNewline
	Write-Host "This will activate the fixing process" -ForegroundColor Gray

	Write-Host " "

	Write-Host "Navigation:" -ForegroundColor DarkRed

	Write-Host " - UP: " -ForegroundColor Gray -NoNewline
	Write-Host "Arrow Up, W, PageUp " -ForegroundColor Red

	Write-Host " - DOWN: " -ForegroundColor Gray -NoNewline
	Write-Host "Arrow Arrow Down, S, PageDown " -ForegroundColor Red

	Write-Host " - SELECT: " -ForegroundColor Gray -NoNewline
	Write-Host "Enter, Space " -ForegroundColor Red
	Write-Host " "

	Write-Host " "
}

function Move-Selection {
	[CmdletBinding()]
	param(
		[switch]$Up,
		[switch]$Down
	)

	if ($Up) {
        if ($script:Index -gt 0) {
            $script:Index--
        }
    }
    elseif ($Down) {
        if ($script:Index -lt ($Options.Count - 1)) {
            $script:Index++
        }
    }
}

function Submit-Selection {
	switch ($Index) {
		'0' {
			Install-Shortcut
			Write-Host " "
			Read-Host -Prompt "Press any key to continue"
		}
		'1' {
			Repair-Vencord
			Read-Host -Prompt "Press any key to continue"
		}
		'2' {
			Show-Help
			Read-Host -Prompt "Press any key to continue"
		}
		'3' {
			Show-Banner
			Write-Host "Bye Bye!" -ForegroundColor Red
			Write-Host " "
			exit
		}
	}
}

function Update-GUI {
	Show-Banner

	Write-Host "Selection:" -ForegroundColor DarkRed
	for ($i = 0; $i -lt $Options.Count; $i++) {
		if ($i -eq $Index) {
			Write-Host " > $($Options[$i])" -ForegroundColor Red
		}
		else {
			Write-Host " $($Options[$i])"
		}
	}
	Write-Host " "
}

function Show-GUI {
	Update-GUI

	$keyActions = @{
		38 = { Move-Selection -Up }  #Arrow up
		33 = { Move-Selection -Up }  #PageUp
		87 = { Move-Selection -Up }  #W

		40 = { Move-Selection -Down }  #Arrow down
		34 = { Move-Selection -Down }  #PageDown
		83 = { Move-Selection -Down }  #S

		32 = { Submit-Selection }  #Space
		13 = { Submit-Selection }  #Enter
	}

	while ($true) {
		if ($Host.UI.RawUI.KeyAvailable) {
			$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

			if ($keyActions.ContainsKey($key.VirtualKeyCode)) {
				# Execute the corresponding action and update the gui
				& $keyActions[$key.VirtualKeyCode]
				Update-GUI
			}
		}
		Start-Sleep -Milliseconds 10 # Small delay to reduce CPU usage
	}
}

function Install-Shortcut {
	Show-Banner
	Write-Host "Input shotcut name or press enter to accept default value" -ForegroundColor DarkRed
	Write-Host "Default: " -NoNewline -ForegroundColor Gray
	Write-Host "VencordFixer" -ForegroundColor Red
	Write-Host " "
	$Name = Read-Host -Prompt "Name"

	if ($Name.Length -eq 0) {
		$Name = "VencordFixer"
	}

	Write-Host " "
	Write-Host "Do you want the shortcut to open GUI if not it will just run the repair process [Y/N]" -ForegroundColor DarkRed
	Write-Host "Default: " -NoNewline -ForegroundColor Gray
	Write-Host "N" -ForegroundColor Red
	Write-Host " "
	$RawUseGUI = Read-Host -Prompt "Use GUI" -
	$UseGUI = $false

	if ($RawUseGUI.Length -gt 0) {
		$RawUseGUI = $RawUseGUI.ToUpper()
		if ($RawUseGUI -eq 'Y' -or $RawUseGUI -eq 'N') {
			if ($RawUseGUI -eq 'Y') {
				$UseGUI = $true
			}
		} else {
			Write-Host "Error: Input must be 'Y' or 'N'" -ForegroundColor Red
			Write-Host " "
			Read-Host -Prompt "Press any key to continue!"
			Install-Shortcut
		}
	}
	#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\Users\NATroutter\Documents\VencordFixer\run.ps1

	$ProgramPath = Join-Path $PSScriptRoot "VencordFixer.ps1";

	$WshShell = New-Object -ComObject WScript.Shell
    $StartMenuPath = [System.Environment]::GetFolderPath('StartMenu')
    $ShortcutPath = Join-Path $StartMenuPath "Programs\$Name.lnk"

    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
	$Shortcut.IconLocation = (Join-Path $PSScriptRoot "favicon.ico")
	if (-not $UseGUI) {
		$Shortcut.Arguments = "$ProgramPath -repair"
	} else {
		$Shortcut.Arguments = "$ProgramPath"
	}
    $Shortcut.Save()

    Write-Host "Shortcut Has been created!"
}

function Repair-Vencord {
	#Variables
	$CLI_Path = Join-Path $PSScriptRoot "VencordInstallerCli.exe"

	# Check if the Vencord CLI file exists
	if (Test-Path $CLI_Path) {
		Write-Host "Vencord CLI file already exists. Skipping download."
	}
	else {
		Write-Host "Vencord CLI file not found. Downloading..."
		# Download the vencord CLI
		Invoke-WebRequest -Uri $($Config.CLI.Download) -OutFile $CLI_Path
		Write-Host "Download complete."
	}

	#Close Discord
	Get-Process -Name "Discord" -ErrorAction SilentlyContinue | Stop-Process -Force

	#Try to update vencord CLI!
	Start-Process -FilePath $CLI_Path -NoNewWindow -Wait -ArgumentList "-update-self"

	#Patch discord client using vencord CLI
	Start-Process -FilePath $CLI_Path -NoNewWindow -Wait -ArgumentList "-repair -branch $($Config.CLI.Branch)"

	#Start discord again
	Start-Process -FilePath $($Config.Discord.Updater) -ArgumentList "--processStart Discord.exe"
}

switch ($PSCmdlet.ParameterSetName) {
	'gui' {
		Show-GUI
	}
	'repair' {
		Repair-Vencord
		#Wait for the user input
		Read-Host -Prompt "Press any key to exit"
	}
	'help' {
		Show-Help
	}
}