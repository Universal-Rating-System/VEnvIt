$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "=[ START $dateTime ]============================================[ Install.ps1 ]=" -ForegroundColor Blue
$separator = "-" * 80

Write-Host $separator -ForegroundColor Cyan
Write-Host "Current system variable values" -ForegroundColor Green
Write-Host "PROJECTS_BASE_DIR =        $env:PROJECTS_BASE_DIR"
Write-Host "VENV_BASE_DIR =            $env:VENV_BASE_DIR"
Write-Host "VENV_CONFIG_DIR =          $env:VENV_CONFIG_DIR"
Write-Host "VENV_CONFIG_DEFAULT_DIR =  $env:VENV_CONFIG_DEFAULT_DIR"
Write-Host "VENV_CONFIG_USER_DIR =     $env:VENV_CONFIG_USER_DIR"
Write-Host "VENV_ENVIRONMENT =         $env:VENV_ENVIRONMENT"
Write-Host "VENV_PYTHON_BASE_DIR =     $env:VENV_PYTHON_BASE_DIR"
Write-Host "VENV_SECRETS_DEFAULT_DIR = $env:VENV_SECRETS_DEFAULT_DIR"
Write-Host "VENV_SECRETS_DIR =         $env:VENV_SECRETS_USER_DIR"
Write-Host "VENV_SECRETS_USER_DIR =    $env:VENV_SECRETS_USER_DIR"
Write-Host "VENVIT_DIR =               $env:VENVIT_DIR"
Write-Host "`nCurrent session variable values" -ForegroundColor Green
Write-Host "PROJECT_DIR =              $env:PROJECT_DIR"
Write-Host "PROJECT_NAME =             $env:PROJECT_NAME"
Write-Host "VIRTUAL_ENV =              $env:VIRTUAL_ENV"

Write-Host "Writing PROJECTS_BASE_DIR..."
[System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", "D:\Dropbox\Projects", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_BASE_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", "D:\GoogleDrive\venv", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_CONFIG_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DIR", "G:\Shared drives\VenvIt Secrets\config", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_CONFIG_DEFAULT_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", "G:\Shared drives\VenvIt\Config", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_CONFIG_USER_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", "G:\Shared drives\Apps\VenvItClient\Config", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_ENVIRONMENT..."
[System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", "loc_dev", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_PYTHON_BASE_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", "C:\Python", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_SECRETS_DEFAULT_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", "G:\Shared drives\VenvIt\Secrets", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_SECRETS_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DIR", "G:\Shared drives\VenvIt Secrets", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENV_SECRETS_USER_DIR..."
[System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", "G:\Shared drives\Apps\VenvItClient\Secrets", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Writing VENVIT_DIR..."
[System.Environment]::SetEnvironmentVariable("VENVIT_DIR", "G:\Shared drives\VenvIt", [System.EnvironmentVariableTarget]::Machine)

$env:PROJECTS_BASE_DIR = "D:\Dropbox\Projects"
$env:VENV_BASE_DIR = "D:\GoogleDrive\venv"
$env:VENV_CONFIG_DIR = "G:\Shared drives\VenvIt Secrets\config"
$env:VENV_CONFIG_DEFAULT_DIR = "G:\Shared drives\VenvIt\Config"
$env:VENV_CONFIG_USER_DIR = "G:\Shared drives\Apps\VenvItClient\Config"
$env:VENV_ENVIRONMENT = "loc_dev"
$env:VENV_PYTHON_BASE_DIR = "C:\Python"
$env:VENV_SECRETS_DEFAULT_DIR = "G:\Shared drives\VenvIt\Secrets"
$env:VENV_SECRETS_DIR = "G:\Shared drives\VenvIt Secrets"
$env:VENV_SECRETS_USER_DIR = "G:\Shared drives\Apps\VenvItClient\Secrets"
$env:VENVIT_DIR = "G:\Shared drives\VenvIt"

$env:PROJECT_DIR = "D:\Dropbox\Projects\BEE\venvit"
$env:PROJECT_NAME = "VenvIt"
$env:VIRTUAL_ENV = "D:\GoogleDrive\venv\venvit_env"

Write-Host $separator -ForegroundColor Cyan
Write-Host "`nAfter resetting system variables" -ForegroundColor Green
Write-Host "PROJECTS_BASE_DIR =        $env:PROJECTS_BASE_DIR"
Write-Host "VENV_BASE_DIR =            $env:VENV_BASE_DIR"
Write-Host "VENV_CONFIG_DIR =          $env:VENV_CONFIG_DIR"
Write-Host "VENV_CONFIG_DEFAULT_DIR =  $env:VENV_CONFIG_DEFAULT_DIR"
Write-Host "VENV_CONFIG_USER_DIR =     $env:VENV_CONFIG_USER_DIR"
Write-Host "VENV_ENVIRONMENT =         $env:VENV_ENVIRONMENT"
Write-Host "VENV_SECRETS_DEFAULT_DIR = $env:VENV_SECRETS_DEFAULT_DIR"
Write-Host "VENV_SECRETS_DIR =         $env:VENV_SECRETS_DIR"
Write-Host "VENV_SECRETS_USER_DIR =    $env:VENV_SECRETS_USER_DIR"
Write-Host "VENV_PYTHON_BASE_DIR =     $env:VENV_PYTHON_BASE_DIR"
Write-Host "VENVIT_DIR =               $env:VENVIT_DIR"
Write-Host "`nAfter resetting session variables" -ForegroundColor Green
Write-Host "PROJECT_DIR =              $env:PROJECT_DIR"
Write-Host "PROJECT_NAME =             $env:PROJECT_NAME"
Write-Host "VIRTUAL_ENV =              $env:VIRTUAL_ENV`n"
Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
