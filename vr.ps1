function RemoveVirtualEnvironment {
    param (
        [string]$_project_name
    )
    # Show help if no project name is provided
    if (-not $_project_name -or $_project_name -eq "-h") {
        ShowHelp
        return
    }

    Write-Information "Remove new $_project_name virtual environment"

    # Check for required environment variables and display help if they're missing
    if (-not $env:PROJECTS_BASE_DIR -or -not $env:SCRIPTS_DIR -or -not $env:VENV_BASE_DIR) {
        ShowEnvVarHelp
        return
    }

    # Deactivate the current virtual environment if it is active
    deactivate

    # Construct the paths based on the script directory and project name
    $script_path = Join-Path $env:SCRIPTS_DIR "venv_${_project_name}_install.ps1"
    $mandatory_path = Join-Path $env:SCRIPTS_DIR "venv_${_project_name}_setup_mandatory.ps1"
    $custom_path = Join-Path $env:SCRIPTS_DIR "venv_${_project_name}_setup_custom.ps1"
    $archive_dir = Join-Path $env:SCRIPTS_DIR "Archive"

    # Move the files to the archive directory
    if (Test-Path $script_path) {
        Move-Item $script_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Information "Moved $script_path to $archive_dir"
    } else {
        Write-Information "Not moved: $script_path (does not exist)."
    }

    if (Test-Path $mandatory_path) {
        Move-Item $mandatory_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Information "Moved $mandatory_path to $archive_dir"
    } else {
        Write-Information "Not moved: $mandatory_path (does not exist)."
    }

    if (Test-Path $custom_path) {
        Move-Item $custom_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Information "Moved $custom_path to $archive_dir"
    } else {
        Write-Information "Not moved: $custom_path (does not exist)."
    }

    # Navigate to the projects base directory and remove the specified directory
    Set-Location $env:PROJECTS_BASE_DIR
    $venv_dir = "${env:VENV_BASE_DIR}\${_project_name}_env"
    if (Test-Path $venv_dir) {
        Remove-Item "$venv_dir" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Information "Removed: $venv_dir."
    } else {
        Write-Information "Not removed: $venv_dir (does not exist)."
    }
}

function ShowHelp {
    $separator = "-" * 80
    Write-Information $separator -ForegroundColor Cyan

    # Introduction
@"
This script, 'vr.ps1', remove the installed Python virtual environment. This include
removing the ${env:VENV_BASE_DIR}\${_project_name}_env directory and moving the
venv_${_project_name}_install.ps1 and venv_${_project_name}_setup_mandatory.ps1 scripts
to the Archive directory.  It does not remove the venv_${_project_name}_setup_custom.ps1
script.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan

    # Environment Variables
@"
    Environment Variables:
    ----------------------
    Prior to starting the PowerShell script, ensure these environment variables are set.

    1. PROJECTS_BASE_DIR: The directory for all projects (e.g., d:\Dropbox\Projects).
    2. SCRIPTS_DIR: Directory where this script resides.
    3. VENV_BASE_DIR: Directory for virtual environments (e.g., c:\venv).
"@ | Write-Information

@"
    Usage:
    ------
    vr.ps1 ProjectName
    vr.ps1 -h

    Parameters:
    1. ProjectName:  The name of the project.
    2. PythonVer:    Python version for the virtual environment.
    3. Institution:  Acronym for the institution owning the project.
    4. DevMode:      If "Y", installs [dev] modules from pyproject.toml.
    5. ResetScripts: If "Y", moves certain scripts to the Archive directory.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan
}

function ShowEnvVarHelp {
    Write-Information "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("SCRIPTS_DIR", "$env:SCRIPTS_DIR"),
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
RemoveVirtualEnvironment -_project_name $args[0]
Write-Information '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
