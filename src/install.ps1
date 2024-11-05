param (
    [Parameter(Mandatory = $false)]
    [Switch]$Help,

    # Used to indicate that the code is called by Pester to avoid unwanted code execution during Pester testing.
    [Parameter(Mandatory = $false)]
    [Switch]$Pester
)

function Invoke-Install {
    # The intention is to keep the following script as short as possible
    # --[ Start copy for readme.md ]------------------------------------------------
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $env:TEMP -ChildPath ("venvit_" + [Guid]::NewGuid().ToString()))
    $Tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
    $UpgradeScriptPath = Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "Installation-Files.zip"
    Invoke-WebRequest "https://github.com/BrightEdgeeServices/venvit/releases/download/$Tag/Installation-Files.zip" -OutFile $UpgradeScriptPath
    Expand-Archive -Path $UpgradeScriptPath -DestinationPath $UpgradeScriptDir
    Import-Module -Name (Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "src/Install-Conclude.psm1")
    Invoke-ConcludeInstall -Release $Tag -UpgradeScriptDir $UpgradeScriptDir
    Remove-Item -Path $UpgradeScriptDir -Recurse -Force
    Get-Item "$env:VENVIT_DIR\*.ps1" | ForEach-Object { Unblock-File $_.FullName }
    Get-Item "$env:VENV_SECRETS_DIR\secrets.ps1" | ForEach-Object { Unblock-File $_.FullName }
    # --[ End copy for readme.md ]----------------------------------------------------
}

function Show-Help {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
    @"
Update the manifest for the project from the pyproject.toml files.
"@ | Write-Host
    Write-Host $separator -ForegroundColor Cyan
    @"
    Usage:
    ------
    Install.ps1 config_base_dir
    Install.ps1 -h | --help

    where:
      config_base_dir:  Location of the pyproject.toml configuration file.
"@ | Write-Host
}

# Script execution starts here
# Pester parameter is to ensure that the script does not execute when called from
# pester BeforeAll.  Any better ideas would be welcome.
if (-not $Pester) {
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]============================================[ Install.ps1 ]=" -ForegroundColor Blue
    Write-Host "Install" -ForegroundColor Blue
    # The script should not run if it is invoked by Pester
    if ($ConfigBaseDir -eq "" -or $Help) {
        Show-Help
    }
    else {
        # Invoke-Install -config_base_dir $args[0]
        Invoke-Install
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
    Write-Host ''
    Write-Host ''
}
