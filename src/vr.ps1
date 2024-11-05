param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [Switch]$Help,

    # Used to indicate that the code is called by Pester to avoid unwanted code execution during Pester testing.
    [Parameter(Mandatory = $false)]
    [Switch]$Pester
)

if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\Utils.psm1

function New-ProjectArchive {
    param (
        [string]$ProjectName
    )

    $timeStamp = Get-Date -Format "yyyyMMddHHmm"

    $archiveDir = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath "Archive"
    $filePostfixToArchive = @(
        "EnvVar",
        "Install",
        "CustomSetup"
    )
    foreach ($postfix in $filePostfixToArchive) {
        $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath (Get-ConfigFileName -ProjectName $ProjectName -Postfix $postfix)
        if (Test-Path -Path $scriptPath) {
            $archivePath = Backup-ScriptToArchiveIfExists -ScriptPath $scriptPath -ArchiveDir $archiveDir -TimeStamp $TimeStamp
            Remove-Item -Path $scriptPath -Recurse -Force
        }
    }
    return $archivePath
}

function Unregister-VirtualEnvironment {
    param (
        [string]$ProjectName
    )

    # Deactivate the current virtual environment if it is active
    if ($env:VIRTUAL_ENV) {
        "Deactivate VEnv $env:VIRTUAL_ENV."
        Invoke-Script -Script "deactivate"
    }

    New-ProjectArchive -ProjectName $ProjectName
    # Navigate to the projects base directory and remove the specified directory
    Set-Location $env:PROJECTS_BASE_DIR
    $venv_dir = "${env:VENV_BASE_DIR}\${ProjectName}_env"
    if (Test-Path $venv_dir) {
        Remove-Item "$venv_dir" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $venv_dir."
    }
    else {
        Write-Host "Not removed: $venv_dir (does not exist)."
    }
}


function Show-Help {
    Write-Host $separator -ForegroundColor Cyan

    @"
'vr.ps1', remove the nominated project. This include the script relate to the
project.  THe scripts are archived to the installation directory.
"@ | Write-Host

    @"
Usage:
------
vr.ps1 -ProjectName
vr.ps1 -h

Parameters:
    -ProjectName  The name of the project to remove.
    -Help           Help
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan
}

# Script execution starts here
# Pester parameter is to ensure that the script does not execute when called from
# pester BeforeAll.  Any better ideas would be welcome.
if (-not $Pester) {
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]=================================================[ vn.ps1 ]=" -ForegroundColor Blue
    Write-Host "Remove the $project_name virtual environment" -ForegroundColor Blue
    if ($ProjectName -eq "" -or $Help) {
        Show-Help
    }
    else {
        Unregister-VirtualEnvironment -ProjectName $ProjectName
        Show-EnvironmentVariables
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}
