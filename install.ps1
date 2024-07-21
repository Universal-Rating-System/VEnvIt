param (
    [string]$release
)

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole($adminRole)
}

if (-not (Test-Admin)) {
    Write-Host "This script needs to be run as an administrator. Restarting with elevated privileges..."
    Start-Process powershell.exe "-File `"$PSCommandPath`" -ArgumentList `"$release`"" -Verb RunAs
    exit
}

# Define the URL for downloading the zip file
$url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$release/installation_files.zip"

# Define the path for the downloaded zip file
$zipFilePath = "installation_files.zip"

# Download the zip file
Write-Host "Downloading installation files from $url..."
Invoke-WebRequest -Uri $url -OutFile $zipFilePath

# Acquire user input for environment variables
# $PROJECTS_BASE_DIR = Read-Host "Enter value for PROJECTS_BASE_DIR"
$SECRETS_DIR = Read-Host "Enter value for SECRETS_DIR"
$VENVIT_DIR = Read-Host "Enter value for VENVIT_DIR"
# $VENV_BASE_DIR = Read-Host "Enter value for VENV_BASE_DIR"
# $VENV_ENVIRONMENT = Read-Host "Enter value for VENV_ENVIRONMENT"
# $VENV_PYTHON_BASE_DIR = Read-Host "Enter value for VENV_PYTHON_BASE_DIR"

# Set the System Properties environment variables permanently
# [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $PROJECTS_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $SECRETS_DIR, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $VENVIT_DIR, [System.EnvironmentVariableTarget]::Machine)
# [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $VENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
# [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $VENV_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
# [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $VENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)

# Ensure the VENVIT_DIR directory exists
if (-not (Test-Path -Path $VENVIT_DIR)) {
    New-Item -ItemType Directory -Path $VENVIT_DIR | Out-Null
}

# Unzip the file in the VENVIT_DIR directory
Write-Host "Unzipping installation_files.zip to $VENVIT_DIR..."
Expand-Archive -Path $zipFilePath -DestinationPath $VENVIT_DIR

# Remove the zip file after extraction
Remove-Item -Path $zipFilePath -Force

# Add VENVIT_DIR to the System Path variable
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$VENVIT_DIR*") {
    $newPath = "$path;$VENVIT_DIR"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "VENVIT_DIR has been added to the System Path."
} else {
    Write-Host "VENVIT_DIR is already in the System Path."
}

Write-Host "Environment variables have been set successfully."

# Confirmation message
Write-Host "Installation and configuration are complete."
