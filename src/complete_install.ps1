param (
    [string]$release,
    [string]$installScriptDir
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
        Write-Host $varName": "$existingValue
        return $existingValue
    } else {
        $newValue = Read-Host $promptText
        [System.Environment]::SetEnvironmentVariable($varName, $newValue, [System.EnvironmentVariableTarget]::Machine)
        # Write-Host "$varName\: $newValue"
        return $newValue
    }
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole($adminRole)
}

# Function to remove an environment variable if it exists
function Remove-EnvVarIfExists {
    param (
        [string]$varName
    )
    $existingValue = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    if ($existingValue) {
        [System.Environment]::SetEnvironmentVariable($varName, $null, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "$varName has been removed."
    }
}

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "=[ START $dateTime ]=========================[ complete_install.ps1 ]=" -ForegroundColor Blue
Write-Host "Install venvit" -ForegroundColor Blue

Write-Host $separator -ForegroundColor Cyan

$url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$release/installation_files.zip"
$zipFilePath = Join-Path -Path $installScriptDir -ChildPath "installation_files.zip"

# Check for administrative privileges
if (-not (Test-Admin)) {
    Write-Host "This script needs to be run as an administrator. Please run it in an elevated PowerShell session." -ForegroundColor Red
    exit
}

# Remove historical (Batch) environment variables if they exist
$_old_env_vars = @(
    @("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT),
    @("SCRIPTS_DIR", "$env:SCRIPTS_DIR")
    @("SECRETS_DIR", "$env:SECRETS_DIR")
)
foreach ($var in $_old_env_vars) {
    Remove-EnvVarIfExists -varName $var[0]
}

# Download the zip file
Write-Host "Downloading installation files from $url..."
Invoke-WebRequest -Uri $url -OutFile $zipFilePath

Write-Host $separator -ForegroundColor Cyan

# Acquire user input for environment variables if they are not already set
Write-Host "Provide the values for the following environment variables:" -ForegroundColor Yellow
    Get-Or-PromptEnvVar -varName "VENV_ENVIRONMENT" -promptText "VENV_ENVIRONMENT"
    $env:PROJECTS_BASE_DIR = Get-Or-PromptEnvVar -varName "PROJECTS_BASE_DIR" -promptText "PROJECTS_BASE_DIR"
    $env:VENVIT_DIR = Get-Or-PromptEnvVar -varName "VENVIT_DIR" -promptText "VENVIT_DIR"
    $env:VENV_SECRETS_DIR = Get-Or-PromptEnvVar -varName "VENV_SECRETS_DIR" -promptText "VENV_SECRETS_DIR"
    $env:VENV_BASE_DIR = Get-Or-PromptEnvVar -varName "VENV_BASE_DIR" -promptText "VENV_BASE_DIR"
    $env:VENV_PYTHON_BASE_DIR = Get-Or-PromptEnvVar -varName "VENV_PYTHON_BASE_DIR" -promptText "VENV_PYTHON_BASE_DIR"
    $env:VENV_CONFIG_DIR = Get-Or-PromptEnvVar -varName "VENV_CONFIG_DIR" -promptText "VENV_CONFIG_DIR"

# Ensure the directories exist
$_system_dirs = @(
    @("PROJECTS_BASE_DIR", $env:PROJECTS_BASE_DIR),
    @("VENVIT_DIR", $env:VENVIT_DIR),
    @("VENV_SECRETS_DIR", $env:VENV_SECRETS_DIR),
    @("PROJECTS_BASE_DIR", $env:PROJECTS_BASE_DIR),
    @("VENV_BASE_DIR", $env:VENV_BASE_DIR),
    @("VENV_PYTHON_BASE_DIR", $env:VENV_PYTHON_BASE_DIR),
    @("VENV_CONFIG_DIR", "$env:VENV_CONFIG_DIR")
)
foreach ($var in $_system_dirs) {
    if (-not (Test-Path -Path $var[1])) {
        New-Item -ItemType Directory -Path $var[1] | Out-Null
    }
}

# Unzip the file in the VENVIT_DIR directory, overwriting any existing files
Write-Host "Unzipping installation_files.zip to $env:VENVIT_DIR..."
Expand-Archive -Path $zipFilePath -DestinationPath $env:VENVIT_DIR -Force

# Move the dev_env_var.ps1 file from VENVIT_DIR to VENV_SECRETS_DIR if it does not already exist in VENV_SECRETS_DIR
$sourceFilePath = Join-Path -Path $env:VENVIT_DIR -ChildPath "dev_env_var.ps1"
$destinationFilePath = Join-Path -Path $env:VENV_SECRETS_DIR -ChildPath "dev_env_var.ps1"

if (Test-Path -Path $sourceFilePath) {
    if (-not (Test-Path -Path $destinationFilePath)) {
        Write-Host "Moving dev_env_var.ps1 to $env:VENV_SECRETS_DIR..."
        Move-Item -Path $sourceFilePath -Destination $destinationFilePath -Force
    } else {
        Write-Host "dev_env_var.ps1 already exists in $env:VENV_SECRETS_DIR. It will not be overwritten."
    }
} else {
    Write-Host "dev_env_var.ps1 not found in $env:VENVIT_DIR."
}

Write-Host $separator -ForegroundColor Cyan

# Remove the zip file after extraction
Remove-Item -Path $zipFilePath -Force
Write-Host "installation_files.zip has been deleted." -ForegroundColor Green

# Add VENVIT_DIR to the System Path variable
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($path -notlike "*$env:VENVIT_DIR*") {
    $newPath = "$path;$env:VENVIT_DIR"
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
