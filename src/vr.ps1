function RemoveVirtualEnvironment {
    param (
        [string]$_project_name
    )
    # Show help if no project name is provided
    if (-not $_project_name -or $_project_name -eq "-h") {
        ShowHelp
        return
    }

    # Check for required environment variables and display help if they're missing
    if (-not $env:PROJECTS_BASE_DIR -or -not $env:VENVIT_DIR -or -not $env:VENV_BASE_DIR) {
        ShowEnvVarHelp
        return
    }

    # Deactivate the current virtual environment if it is active
    deactivate

    # Construct the paths based on the script directory and project name
    $venvit_path = Join-Path $env:VENVIT_DIR "venv_${_project_name}_install.ps1"
    $mandatory_path = Join-Path $env:VENVIT_DIR "venv_${_project_name}_setup_mandatory.ps1"
    $custom_path = Join-Path $env:VENVIT_DIR "venv_${_project_name}_setup_custom.ps1"
    $archive_dir = Join-Path $env:VENVIT_DIR "Archive"

    # Move the files to the archive directory
    if (Test-Path $venvit_path) {
        Move-Item $venvit_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Host "Moved $venvit_path to $archive_dir"
    } else {
        Write-Host "Not moved: $venvit_path (does not exist)."
    }

    if (Test-Path $mandatory_path) {
        Move-Item $mandatory_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Host "Moved $mandatory_path to $archive_dir"
    } else {
        Write-Host "Not moved: $mandatory_path (does not exist)."
    }

    if (Test-Path $custom_path) {
        Move-Item $custom_path $archive_dir -ErrorAction SilentlyContinue -Force
        Write-Host "Moved $custom_path to $archive_dir"
    } else {
        Write-Host "Not moved: $custom_path (does not exist)."
    }

    # Navigate to the projects base directory and remove the specified directory
    Set-Location $env:PROJECTS_BASE_DIR
    $venv_dir = "${env:VENV_BASE_DIR}\${_project_name}_env"
    if (Test-Path $venv_dir) {
        Remove-Item "$venv_dir" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $venv_dir."
    } else {
        Write-Host "Not removed: $venv_dir (does not exist)."
    }
}

function ShowHelp {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
@"
This script, 'vr.ps1', remove the installed Python virtual environment. This include
removing the ${env:VENV_BASE_DIR}\${_project_name}_env directory and moving the
venv_${_project_name}_install.ps1 and venv_${_project_name}_setup_mandatory.ps1 scripts
to the Archive directory.  It does not remove the venv_${_project_name}_setup_custom.ps1
script.
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan

    # Environment Variables
@"
    Environment Variables:
    ----------------------
    Prior to starting the PowerShell script, ensure these environment variables are set.

    1. PROJECTS_BASE_DIR: The directory for all projects (e.g., d:\Dropbox\Projects).
    2. VENVIT_DIR: Directory where this script resides.
    3. VENV_BASE_DIR: Directory for virtual environments (e.g., c:\venv).
"@ | Write-Host

@"
    Usage:
    ------
    vr.ps1 ProjectName
    vr.ps1 -h

    Parameters:
        -h           Help
        ProjectName  The name of the project.
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan
}

function ShowEnvVarHelp {
    Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("VENVIT_DIR", "$env:VENVIT_DIR"),
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
Write-Host "=[ START $dateTime ]=======================================[ vr.ps1 ]=" -ForegroundColor Blue
Write-Host "REmove the $args[0] virtual environment" -ForegroundColor Blue
RemoveVirtualEnvironment -_project_name $args[0]
Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
