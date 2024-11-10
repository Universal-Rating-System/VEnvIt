# vi.ps1

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

function Invoke-VirtualEnvironment {
    param (
        [string]$ProjectName
    )

    Invoke-Script ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar"))
    Invoke-Script ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar"))

    if ($env:VIRTUAL_ENV) {
        "Deactivate VEnv $env:VIRTUAL_ENV."
        Invoke-Script -Script "deactivate"
    }
    Invoke-Script -Script ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1")

    # $env:PROJECT_NAME = $_project_name
    if ($env:VENV_ENVIRONMENT -eq "loc_dev") {
        Invoke-Script -Script ("$env:VENV_SECRETS_DEFAULT_DIR\secrets.ps1")
        Invoke-Script -Script ("$env:VENV_SECRETS_USER_DIR\secrets.ps1")
    }

    # Remove temporary directories from previous sessions
    # TODO
    # https://github.com/BrightEdgeeServices/venvit/issues/21
    # Exclude the current temp directory if there is one.
    # Possibly move this to some clean up procedsure.
    Get-ChildItem -Path $env:TEMP -Directory -Filter "$env:PROJECT_NAME*" | Remove-Item -Recurse -Force

    if (Test-Path $env:PROJECT_DIR) {
        Set-Location -Path (Split-Path $env:PROJECT_DIR -Qualifier)
        Set-Location -Path $env:PROJECT_DIR
    }
    else {
        Set-Location -Path Split-Path $env:PROJECT_BASE_DIR -Qualifier
        Set-Location -Path $env:PROJECT_BASE_DIR
    }

    Invoke-Script ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup"))
    Invoke-Script ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup"))
}

# function ShowEnvVarHelp {
#     Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan
#
#     $_env_vars = @(
#         @("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT),
#         @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
#         @("VENVIT_DIR", "$env:VENVIT_DIR"),
#         @("VENV_SECRETS_DIR", "$env:VENV_SECRETS_DIR"),
#         @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
#     )
#
#     foreach ($var in $_env_vars) {
#         if ([string]::IsNullOrEmpty($var[1])) {
#             Write-Host $var[0] -ForegroundColor Red -NoNewline
#             Write-Host " - Not Set"
#         }
#         else {
#             Write-Host $var[0] -ForegroundColor Green -NoNewline
#             $s = " - Set to: " + $var[1]
#             Write-Host $s
#         }
#     }
# }

function Show-Help {
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
    @"
This script, 'vi.ps1', initializes a Python virtual environment. This include running the
VEnv${_project_name}CustomSetup .ps1 script.
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan
    @"
Usage:
------
vi.ps1 ProjectName
vi.ps1 -Help

Parameters:
1. ProjectName: The name of the project.
2. -Help:       Display this help

Environment Variables:
----------------------
Prior to starting the PowerShell script, ensure these environment variables are set.

1. PROJECTS_BASE_DIR:     The directory for all projects (e.g., d:\Dropbox\Projects).
2. VENV_BASE_DIR:         Directory for virtual environments (e.g., c:\venv).
3. VENV_CONFIG_DEFAULT_DIR:   Directory where the organization configuration scripts for the project are stored.
3. VENV_CONFIG_USER_DIR:  Directory where the user configuration scripts for the project are stored.
1. VENV_ENVIRONMENT:      Sets the development environment amrker. Possible values: loc_dev, github_dev, prod, etc.
3. VENV_SECRETS_DEFAULT_DIR:  Directory for storing organization secrets related to the project (e.g., g:\Google Drive\Secrets).
3. VENV_SECRETS_USER_DIR: Directory for storing user secrets related to the project (e.g., g:\Google Drive\Secrets).
4. VENVIT_DIR:            Directory where this script resides.
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
    if ($ProjectName -eq "" -or $Help) {
        Show-Help
    }
    else {
        Invoke-VirtualEnvironment -ProjectName $ProjectName
        Show-EnvironmentVariables
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}
