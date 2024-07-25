function DisplayEnvironmentVariables {
    Write-Host ""
    Write-Host "System Environment Variables"  -ForegroundColor Green
    Write-Host "VENV_ENVIRONMENT:      $env:VENV_ENVIRONMENT"
    Write-Host "PROJECTS_BASE_DIR:     $env:PROJECTS_BASE_DIR"
    Write-Host "PROJECT_DIR:           $env:PROJECT_DIR"
    Write-Host "VENVIT_DIR:            $env:VENVIT_DIR"
    Write-Host "VENV_SECRETS_DIR:      $env:VENV_SECRETS_DIR"
    Write-Host "VENV_BASE_DIR:         $env:VENV_BASE_DIR"
    Write-Host "VENV_PYTHON_BASE_DIR:  $env:VENV_PYTHON_BASE_DIR"
    Write-Host ""
    Write-Host "Project Environment Variables"  -ForegroundColor Green
    Write-Host "INSTALLER_PWD:        $env:INSTALLER_PWD"
    Write-Host "INSTALLER_USERID:     $env:INSTALLER_USERID"
    Write-Host "MYSQL_DATABASE:       $env:MYSQL_DATABASE"
    Write-Host "MYSQL_HOST:           $env:MYSQL_HOST"
    Write-Host "MYSQL_ROOT_PASSWORD:  $env:MYSQL_ROOT_PASSWORD"
    Write-Host "MYSQL_TCP_PORT:       $env:MYSQL_TCP_PORT"
    Write-Host "PROJECT_NAME:         $env:PROJECT_NAME"
    Write-Host ""
    Write-Host "Git Information"  -ForegroundColor Green
    git branch --all
}
function InitVirtualEnvironment {
    param (
        [string]$_project_name
    )
    # Show help if no project name is provided
    if (-not $_project_name -or $_project_name -eq "-h") {
        ShowHelp
        return
    }

    # Check for required environment variables and display help if they're missing
    if (-not $env:VENV_ENVIRONMENT -or -not $env:VENVIT_DIR -or -not $env:VENV_SECRETS_DIR -or -not $env:PROJECTS_BASE_DIR -or -not $env:VENV_BASE_DIR) {
        ShowEnvVarHelp
        return
    }
    # Set local variables from environment variables
    $_project_base_dir = $env:PROJECTS_BASE_DIR
    $_venvit_dir = $env:VENVIT_DIR
    $_secrets_dir = $env:VENV_SECRETS_DIR
    $_venv_base_dir = $env:VENV_BASE_DIR
    $_venv_dir = "$_venv_base_dir\${_project_name}_env"

    if ($env:VIRTUAL_ENV) {
        "Virtual environment is active at: $env:VIRTUAL_ENV, deactivating"
        deactivate
    } else {
        "No virtual environment is active."
    }
    & "$_venv_dir\Scripts\activate.ps1"
    & "${_venvit_dir}\venv_${_project_name}_setup_mandatory.ps1" $_project_name
    $_project_dir = $env:PROJECT_DIR

    $env:PROJECT_NAME = $_project_name
    if ($env:VENV_ENVIRONMENT -eq "loc_dev") {
        & "$_secrets_dir\env_var_dev.ps1"
    }

    # Remove temporary directories from previous sessions
    Get-ChildItem -Path $env:TEMP -Directory -Filter "$_project_name`_*" | Remove-Item -Recurse -Force
    Get-ChildItem -Path $env:TEMP -Directory -Filter "temp*" | Remove-Item -Recurse -Force

    if (Test-Path $_project_dir) {
        Set-Location -Path $_project_dir.Substring(0,2)
        Set-Location -Path $_project_dir
    } else {
        Set-Location -Path $_project_base_dir.Substring(0,2)
        Set-Location -Path $_project_base_dir
    }

    & "${_venvit_dir}\venv_${_project_name}_setup_custom.ps1" $_project_name
}

function ShowEnvVarHelp {
    Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("VENVIT_DIR", "$env:VENVIT_DIR"),
        @("VENV_SECRETS_DIR", "$env:VENV_SECRETS_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Host $var[0] -ForegroundColor Red -NoNewline
            Write-Host " - Not Set"
        } else {
            Write-Host $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " +  $var[1]
            Write-Host $s
        }
    }
}

function ShowHelp {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
@"
This script, 'vi.ps1', initializes a Python virtual environment. This include running the
venv_${_project_name}_setup_custom .ps1 and venv_${_project_name}_setup_mandatory.ps1 scripts.
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan

    # Environment Variables
@"
    Environment Variables:
    ----------------------
    Prior to starting the PowerShell script, ensure these environment variables are set.

    1. VENV_ENVIRONMENT:   Sets the development environment. Possible values: loc_dev, github_dev, prod, etc.
    2. PROJECTS_BASE_DIR: The directory for all projects (e.g., d:\Dropbox\Projects).
    3. VENV_SECRETS_DIR:       Directory for storing secrets (e.g., g:\Google Drive\Secrets).
    4. VENVIT_DIR:        Directory where this script resides.
    5. VENV_BASE_DIR:     Directory for virtual environments (e.g., c:\venv).
"@ | Write-Host
Write-Host $separator -ForegroundColor Cyan
@"
    Usage:
    ------
    vi.ps1 ProjectName
    vi.ps1 -h

    Parameters:
    1. ProjectName:  The name of the project.
"@ | Write-Host

}

function ShowEnvVarHelp {
    Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("VENVIT_DIR", "$env:VENVIT_DIR"),
        @("VENV_SECRETS_DIR", "$env:VENV_SECRETS_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Host $var[0] -ForegroundColor Red -NoNewline
            Write-Host " - Not Set"
        } else {
            Write-Host $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " +  $var[1]
            Write-Host $s
        }
    }
}

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$project_name = $args[0]
Write-Host "=[ START $dateTime ]=======================================[ vi.ps1 ]=" -ForegroundColor Blue
Write-Host "Initialize the $project_name virtual environment" -ForegroundColor Blue
InitVirtualEnvironment -_project_name $args[0]
DisplayEnvironmentVariables
Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
