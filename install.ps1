param (
    [string]$release
)
$separator = "-" * 80

# Function to get or prompt for an environment variable
function Get-Or-PromptEnvVar {
    param (
        [string]$varName,
        [string]$promptText
    )
    $existingValue = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    if ($existingValue) {
        Write-Host "$varName\: $existingValue"
        return $existingValue
    } else {
        $newValue = Read-Host $promptText
        [System.Environment]::SetEnvironmentVariable($varName, $newValue, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "$varName\: $newValue"
        return $newValue
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole($adminRole)
}

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "=[ START $dateTime ]==================================================" -ForegroundColor Blue

$url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$release/installation_files.zip"
$zipFilePath = "installation_files.zip"

# Check for administrative privileges
if (-not (Test-Admin)) {
    Write-Host "This script needs to be run as an administrator. Please run it in an elevated PowerShell session." -ForegroundColor Red
    exit
}

# Download the zip file
Write-Host "Downloading installation files from $url..."
Invoke-WebRequest -Uri $url -OutFile $zipFilePath

Write-Information $separator -ForegroundColor Cyan

# Acquire user input for environment variables if they are not already set
Write-Host "Provide the values for the following environment variables:" -ForegroundColor Yellow
$VENV_ENVIRONMENT = Get-Or-PromptEnvVar -varName "VENV_ENVIRONMENT" -promptText "VENV_ENVIRONMENT: "
$PROJECTS_BASE_DIR = Get-Or-PromptEnvVar -varName "PROJECTS_BASE_DIR" -promptText "PROJECTS_BASE_DIR: "
$VENVIT_DIR = Get-Or-PromptEnvVar -varName "VENVIT_DIR" -promptText "VENVIT_DIR: "
$SECRETS_DIR = Get-Or-PromptEnvVar -varName "SECRETS_DIR" -promptText "SECRETS_DIR: "
$VENV_BASE_DIR = Get-Or-PromptEnvVar -varName "VENV_BASE_DIR" -promptText "VENV_BASE_DIR: "
$VENV_PYTHON_BASE_DIR = Get-Or-PromptEnvVar -varName "VENV_PYTHON_BASE_DIR" -promptText "VENV_PYTHON_BASE_DIR: "

# Ensure the VENVIT_DIR and SECRETS_DIR directories exist
if (-not (Test-Path -Path $VENVIT_DIR)) {
    New-Item -ItemType Directory -Path $VENVIT_DIR | Out-Null
}
if (-not (Test-Path -Path $SECRETS_DIR)) {
    New-Item -ItemType Directory -Path $SECRETS_DIR | Out-Null
}

# Unzip the file in the VENVIT_DIR directory, overwriting any existing files
Write-Host "Unzipping installation_files.zip to $VENVIT_DIR..."
Expand-Archive -Path $zipFilePath -DestinationPath $VENVIT_DIR -Force

# Move the env_var_dev.ps1 file from VENVIT_DIR to SECRETS_DIR if it does not already exist in SECRETS_DIR
$sourceFilePath = Join-Path -Path $VENVIT_DIR -ChildPath "env_var_dev.ps1"
$destinationFilePath = Join-Path -Path $SECRETS_DIR -ChildPath "env_var_dev.ps1"

if (Test-Path -Path $sourceFilePath) {
    if (-not (Test-Path -Path $destinationFilePath)) {
        Write-Host "Moving env_var_dev.ps1 to $SECRETS_DIR..."
        Move-Item -Path $sourceFilePath -Destination $destinationFilePath -Force
    } else {
        Write-Host "env_var_dev.ps1 already exists in $SECRETS_DIR. It will not be overwritten."
    }
} else {
    Write-Host "env_var_dev.ps1 not found in $VENVIT_DIR."
}

Write-Information $separator -ForegroundColor Cyan

# Remove the zip file after extraction
Remove-Item -Path $zipFilePath -Force
Write-Host "installation_files.zip has been deleted." -ForegroundColor Green

# Add VENVIT_DIR to the System Path variable
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$VENVIT_DIR*") {
    $newPath = "$path;$VENVIT_DIR"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "VENVIT_DIR has been added to the System Path."  -ForegroundColor Green
} else {
    Write-Host "VENVIT_DIR is already in the System Path."  -ForegroundColor Green
}

Write-Host "Environment variables have been set successfully."  -ForegroundColor Green

# Confirmation message
Write-Host "Installation and configuration are complete."  -ForegroundColor Green

# Remove the install.ps1 script
$scriptPath = $MyInvocation.MyCommand.Path
Write-Host "Removing the install.ps1 script..."  -ForegroundColor Green
Remove-Item -Path $scriptPath -Force
Write-Host "install.ps1 has been deleted."  -ForegroundColor Green

Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
