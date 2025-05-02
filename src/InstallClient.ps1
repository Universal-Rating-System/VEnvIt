# InstallClient.ps1

param (
    [Parameter(Mandatory = $false)]
    [Switch]$Help,

    # Used to indicate that the code is called by Pester to avoid unwanted code execution during Pester testing.
    [Parameter(Mandatory = $false)]
    [Switch]$Pester
)

function Install-Client {
    Write-Host "Installing client..." -ForegroundColor Green
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
        Install-Client
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
    Write-Host ''
    Write-Host ''
}
