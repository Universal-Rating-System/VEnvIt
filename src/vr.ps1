function MakeProjectArchive {
    param (
        [string]$projectName
    )

    # Ensure the Archive subdirectory exists
    $archiveDir = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath "Archive"
    if (-not (Test-Path -Path $archiveDir)) {
        New-Item -ItemType Directory -Path $archiveDir | Out-Null
    }

    # Generate the zip file name with the project name and a date-time stamp
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $zipFileName = "$projectName" + "_" + "$timestamp" + ".zip"
    $zipFilePath = Join-Path -Path $archiveDir -ChildPath $zipFileName

    # Define the files to be archived
    # Construct the paths based on the script directory and project name
    $install_path = Join-Path $env:VENV_CONFIG_DIR "venv_${projectName}_install.ps1"
    $mandatory_path = Join-Path $env:VENV_CONFIG_DIR "venv_${projectName}_setup_mandatory.ps1"
    $custom_path = Join-Path $env:VENV_CONFIG_DIR "venv_${projectName}_setup_custom.ps1"
    $filesToArchive = @($install_path, $mandatory_path, $custom_path)

    # Check if the files exist before attempting to archive them
    $existingFiles = @()
    foreach ($file in $filesToArchive) {
        if (Test-Path -Path $file) {
            $existingFiles += $file
        } else {
            Write-Host "Warning: $file does not exist and will not be included in the archive." -ForegroundColor Yellow
        }
    }

    # Create the zip file
    if ($existingFiles.Count -gt 0) {
      $tempExtractDir = Join-Path -Path ($env:VENV_CONFIG_DIR) -ChildPath ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Path $tempExtractDir | Out-Null
        # Move files to the root of the temporary directory
        foreach ($file in $existingFiles) {
            Move-Item -Path $file -Destination $tempExtractDir -Force
        }
        Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempExtractDir, $zipFilePath, [System.IO.Compression.CompressionLevel]::Optimal, $false)

        # Clean up temporary directory
        Remove-Item -Path $tempExtractDir -Recurse -Force

        Write-Host "Archive created successfully: $zipFilePath" -ForegroundColor Green
    } else {
        Write-Host "No files were found to archive." -ForegroundColor Red
    }
}

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
    if (
        -not $env:PROJECTS_BASE_DIR -or
        -not $env:VENVIT_DIR -or
        -not $env:VENV_BASE_DIR  -or
        -not $env:VENV_CONFIG_DIR ){
        ShowEnvVarHelp
        return
    }

    # Deactivate the current virtual environment if it is active
    if ($env:VIRTUAL_ENV) {
        "Virtual environment is active at: $env:VIRTUAL_ENV, deactivating"
        deactivate
    }

    # Move the files to the archive directory
    MakeProjectArchive -projectName $_project_name
    # if (Test-Path $install_path) {
    #     Move-Item $install_path $archive_dir -ErrorAction SilentlyContinue -Force
    #     Write-Host "Moved $install_path to $archive_dir"
    # } else {
    #     Write-Host "Not moved: $install_path (does not exist)."
    # }

    # if (Test-Path $mandatory_path) {
    #     Move-Item $mandatory_path $archive_dir -ErrorAction SilentlyContinue -Force
    #     Write-Host "Moved $mandatory_path to $archive_dir"
    # } else {
    #     Write-Host "Not moved: $mandatory_path (does not exist)."
    # }

    # if (Test-Path $custom_path) {
    #     Move-Item $custom_path $archive_dir -ErrorAction SilentlyContinue -Force
    #     Write-Host "Moved $custom_path to $archive_dir"
    # } else {
    #     Write-Host "Not moved: $custom_path (does not exist)."
    # }

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

function ShowEnvVarHelp {
    Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("PROJECT_NAME", "$env:PROJECT_NAME"),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("VENV_CONFIG_DIR", "$env:VENV_CONFIG_DIR"),
        @("VENVIT_DIR", "$env:VENVIT_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR")
    )

    foreach ($var in $_env_vars)
    {
        if ( [string]::IsNullOrEmpty($var[1]))
        {
            Write-Host $var[0] -ForegroundColor Red -NoNewline
            Write-Host " - Not Set"
        }
        else
        {
            Write-Host $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " + $var[1]
            Write-Host $s
        }
    }
}

function ShowHelp {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

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

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$project_name = $args[0]
Write-Host "=[ START $dateTime ]=======================================[ vr.ps1 ]=" -ForegroundColor Blue
Write-Host "Remove the $project_name virtual environment" -ForegroundColor Blue
RemoveVirtualEnvironment -_project_name $args[0]
Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
