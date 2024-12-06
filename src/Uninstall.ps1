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

function Backup-EnvironmentVariables {
    param (
        [String]$DestinationPath
    )

    $BackupFileName = "EnvironmentVariables" + "_" + "$TimeStamp.txt"
    $BackupPath = Join-Path -Path (Split-Path $DestinationPath) -ChildPath $BackupFileName

    $backupEnvVars = Get-ChildItem Env: | Where-Object { $_.Name -like "VENV*" }
    # Open the file for writing
    try {
        $fileStream = [System.IO.StreamWriter]::new($BackupPath, $false)
        foreach ($envVar in $backupEnvVars) {
            $fileStream.WriteLine("$($envVar.Name)=$($envVar.Value)")
        }
    }
    finally {
        $fileStream.Close()
    }

    $compress = @{
        Path             = $BackupPath
        CompressionLevel = "Fastest"
        DestinationPath  = $DestinationPath
        Update           = $true
    }
    Compress-Archive @compress | Out-Null
    Remove-Item $BackupPath -Force
}

function Invoke-Uninstall {
    param (
        [string]$BackupDir
    )
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    if ((Get-Module -Name "Utils") -and $Pester ) {
        Remove-Module -Name "Utils"
    }
    Import-Module $PSScriptRoot\Utils.psm1

    if (-not $BackupDir) {
        $BackupDir = "~.\VEnvIt Backup"
    }
    if ( -not (Test-Path $BackupDir )) {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
    }

    $timeStamp = Get-Date -Format "yyyyMMddHHmm"
    $InstallationDir = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
    if ($InstallationDir) {
        $archivePath = Backup-ArchiveOldVersion -InstallationDir $InstallationDir -TimeStamp $timeStamp -DestinationDir $BackupDir
        Backup-EnvironmentVariables -DestinationPath $archivePath
        Remove-InstallationFiles -InstallationDir $env:VENVIT_DIR
        Unpublish-EnvironmentVariables -EnvVarSet $defEnvVarSet_7_0_0
    }
    else {
        $archivePath = $false
    }

    return $archivePath
}

function  Remove-InstallationFiles {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$InstallationDir
    )

    Import-Module $PSScriptRoot\Utils.psm1
    $archiveVersion = Get-Version -SourceDir $InstallationDir

    if ($archiveVersion -eq "0.0.0") {
        $fileList = $env:SCRIPTS_DIR
    }
    elseif ($archiveVersion -eq "6.0.0") {
        $fileList = $env:VENVIT_DIR, $env:VENV_CONFIG_DIR, $env:VENV_SECRETS_DIR
    }
    elseif ($archiveVersion -eq "7.0.0") {
        $fileList = $env:VENVIT_DIR, $env:VENV_CONFIG_DEFAULT_DIR, $env:VENV_CONFIG_USER_DIR, $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR
    }

    foreach ( $dir in $fileList) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Force -Recurse
        }
    }
    Remove-Item -Path $env:VENV_BASE_DIR -Force -Recurse
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
    Write-Host "=[ START $dateTime ]==========================================[ Uninstall.ps1 ]=" -ForegroundColor Blue
    Write-Host "Uninstall VEnvIt" -ForegroundColor Blue
    if ($BackupDir -eq "" -or $Help) {
        Show-Help
    }
    else {
        Invoke-Uninstall -BackupDir $BackupDir
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}

