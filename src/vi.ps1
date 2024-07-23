function DisplayEnvironmentVariables {
    Write-Information ""
    Write-Information "System Environment Variables"  -ForegroundColor Green
    Write-Information "RTE_ENVIRONMENT:       $env:RTE_ENVIRONMENT"
    Write-Information "PROJECTS_BASE_DIR:     $env:PROJECTS_BASE_DIR"
    Write-Information "PROJECT_DIR:           $env:PROJECT_DIR"
    Write-Information "SCRIPTS_DIR:           $env:SCRIPTS_DIR"
    Write-Information "SECRETS_DIR:           $env:SECRETS_DIR"
    Write-Information "VENV_BASE_DIR:         $env:VENV_BASE_DIR"
    Write-Information "VENV_PYTHON_BASE_DIR:  $env:VENV_PYTHON_BASE_DIR"
    Write-Information ""
    Write-Information "Project Environment Variables"  -ForegroundColor Green
    Write-Information "INSTALLER_PWD:        $env:INSTALLER_PWD"
    Write-Information "INSTALLER_USERID:     $env:INSTALLER_USERID"
    Write-Information "MYSQL_DATABASE:       $env:MYSQL_DATABASE"
    Write-Information "MYSQL_HOST:           $env:MYSQL_HOST"
    Write-Information "MYSQL_ROOT_PASSWORD:  $env:MYSQL_ROOT_PASSWORD"
    Write-Information "MYSQL_TCP_PORT:       $env:MYSQL_TCP_PORT"
    Write-Information "PROJECT_NAME:         $env:PROJECT_NAME"
    Write-Information ""
    Write-Information "Git Information"  -ForegroundColor Green
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

    Write-Information "Initialize the  $_project_name virtual environment"

    # Check for required environment variables and display help if they're missing
    if (-not $env:RTE_ENVIRONMENT -or -not $env:SCRIPTS_DIR -or -not $env:SECRETS_DIR -or -not $env:PROJECTS_BASE_DIR -or -not $env:VENV_BASE_DIR) {
        ShowEnvVarHelp
        return
    }
    # Set local variables from environment variables
    $_project_base_dir = $env:PROJECTS_BASE_DIR
    $_scripts_dir = $env:SCRIPTS_DIR
    $_secrets_dir = $env:SECRETS_DIR
    $_venv_base_dir = $env:VENV_BASE_DIR
    $_venv_dir = "$_venv_base_dir\${_project_name}_env"

    if ($env:VIRTUAL_ENV) {
        "Virtual environment is active at: $env:VIRTUAL_ENV, deactivating"
        deactivate
    } else {
        "No virtual environment is active."
    }
    & "$_venv_dir\Scripts\activate.ps1"
    & "${_scripts_dir}\venv_${_project_name}_setup_mandatory.ps1" $_project_name
    $_project_dir = $env:PROJECT_DIR

    if ($env:RTE_ENVIRONMENT -eq "loc_dev") {
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

    & "${_scripts_dir}\venv_${_project_name}_setup_custom.ps1" $_project_name
}

function ShowEnvVarHelp {
    Write-Information "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("SCRIPTS_DIR", "$env:SCRIPTS_DIR"),
        @("SECRETS_DIR", "$env:SECRETS_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Information $var[0] -ForegroundColor Red -NoNewline
            Write-Information " - Not Set"
        } else {
            Write-Information $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " +  $var[1]
            Write-Information $s
        }
    }
}

function ShowHelp {
    $separator = "-" * 80
    Write-Information $separator -ForegroundColor Cyan

    # Introduction
@"
This script, 'vi.ps1', initializes a Python virtual environment. This include running the
venv_${_project_name}_setup_custom .ps1 and venv_${_project_name}_setup_mandatory.ps1 scripts.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan

    # Environment Variables
@"
    Environment Variables:
    ----------------------
    Prior to starting the PowerShell script, ensure these environment variables are set.

    1. RTE_ENVIRONMENT:   Sets the development environment. Possible values: loc_dev, github_dev, prod, etc.
    2. PROJECTS_BASE_DIR: The directory for all projects (e.g., d:\Dropbox\Projects).
    3. SECRETS_DIR:       Directory for storing secrets (e.g., g:\Google Drive\Secrets).
    4. SCRIPTS_DIR:       Directory where this script resides.
    5. VENV_BASE_DIR:     Directory for virtual environments (e.g., c:\venv).
"@ | Write-Information
Write-Information $separator -ForegroundColor Cyan
@"
    Usage:
    ------
    vi.ps1 ProjectName
    vi.ps1 -h

    Parameters:
    1. ProjectName:  The name of the project.
"@ | Write-Information

}

function ShowEnvVarHelp {
    Write-Information "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("SCRIPTS_DIR", "$env:SCRIPTS_DIR"),
        @("SECRETS_DIR", "$env:SECRETS_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Information $var[0] -ForegroundColor Red -NoNewline
            Write-Information " - Not Set"
        } else {
            Write-Information $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " +  $var[1]
            Write-Information $s
        }
    }
}

# Script execution starts here
Write-Information ''
Write-Information ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Information "=[ START $dateTime ]==================================================" -ForegroundColor Blue
InitVirtualEnvironment -_project_name $args[0]
DisplayEnvironmentVariables
Write-Information '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Information ''
Write-Information ''
