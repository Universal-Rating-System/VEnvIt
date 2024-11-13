# Uninstall.ps1

param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$BackupDir,

    [Parameter(Mandatory = $false)]
    [Switch]$Help,

    # Used to indicate that the code is called by Pester to avoid unwanted code execution during Pester testing.
    [Parameter(Mandatory = $false)]
    [Switch]$Pester
)

if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\Utils.psm1

function Invoke-Uninstall {
    param (
        [string]$BackupDir
    )
    if (-not $BackupDir) {
        $BackupDir = "~.\VEnvIt Backup"
    }
    if ( -not (Test-Path $BackupDir )) {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
    }

    $timeStamp = Get-Date -Format "yyyyMMddHHmm"
    Backup-ArchiveOldVersion -InstallationDir $env:VENVIT_DIR -TimeStamp $timeStamp -DestinationDir $BackupDir
}

function Show-Help {
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
    @"
'Uninstall.ps1', uninstall all veraions of VEnvIt.  It will create a zip archive containing:
- All source scriipts.
- All configuration files.
- All secrtes scrripts
- A data file with the current system variable settings.

The zip file will be stored in the BackupDir.  If the BackupDir parameter is omitted, it will be stired in "~.\VEnvIt Backup"

"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan
    @"
Usage:
------
Uninstall
Uninstall -BackupDir
Uninstall -Help

Parameters:
1. -BackupDir: Save a backup to a cpecific directory.
2. -Help:      Display this help

"@ | Write-Host

}

# Script execution starts here
# Pester parameter is to ensure that the script does not execute when called from
# pester BeforeAll.  Any better ideas would be welcome.
if (-not $Pester) {
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]=================================================[ vn.ps1 ]=" -ForegroundColor Blue
    Write-Host "Initialize the $project_name virtual environment" -ForegroundColor Blue
    if ($BackupDir -eq "" -or $Help) {
        Show-Help
    }
    else {
        Invoke-Uninstall -BackupDir $BackupDir
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}

