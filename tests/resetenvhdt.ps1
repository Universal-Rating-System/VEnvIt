$separator = "-" * 80

Write-Host $separator  -ForegroundColor Cyan
Write-Host "Current values" -ForegroundColor Green
Write-Host "VENV_ENVIRONMENT =" $env:VENV_ENVIRONMENT
Write-Host "PROJECTS_BASE_DIR =" $env:PROJECTS_BASE_DIR
Write-Host "VENVIT_DIR =" $env:VENVIT_DIR
Write-Host "VENVIT_SECRETS_DIR =" $env:VENVIT_SECRETS_DIR
Write-Host "VENV_BASE_DIR =" $env:VENV_BASE_DIR
Write-Host "VENV_PYTHON_BASE_DIR =" $env:VENV_PYTHON_BASE_DIR
Write-Host "VENV_CONFIG_DIR =" $env:VENV_CONFIG_DIR

[System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", "loc_dev", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", "D:\Dropbox\Projects", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENVIT_DIR", "G:\Shared drives\VenvIt", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_DIR", "G:\Shared drives\VenvIt Secrets", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", "D:\GoogleDrive\venv", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", "C:\Python", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DIR", "G:\Shared drives\VenvIt Secrets\config", [System.EnvironmentVariableTarget]::Machine)

$env:VENV_ENVIRONMENT = "loc_dev"
$env:PROJECTS_BASE_DIR = "D:\Dropbox\Projects"
$env:VENVIT_DIR = "G:\Shared drives\VenvIt"
$env:VENVIT_SECRETS_DIR = "G:\Shared drives\VenvIt Secrets"
$env:VENV_BASE_DIR = "D:\GoogleDrive\venv"
$env:VENV_PYTHON_BASE_DIR = "C:\Python"
$env:VENV_CONFIG_DIR = "G:\Shared drives\VenvIt Secrets\config"

Write-Host $separator -ForegroundColor Cyan
Write-Host "After resetting" -ForegroundColor Green
Write-Host "VENV_ENVIRONMENT =" $env:VENV_ENVIRONMENT
Write-Host "PROJECTS_BASE_DIR =" $env:PROJECTS_BASE_DIR
Write-Host "VENVIT_DIR =" $env:VENVIT_DIR
Write-Host "VENVIT_SECRETS_DIR =" $env:VENVIT_SECRETS_DIR
Write-Host "VENV_BASE_DIR =" $env:VENV_BASE_DIR
Write-Host "VENV_PYTHON_BASE_DIR =" $env:VENV_PYTHON_BASE_DIR
Write-Host "VENV_CONFIG_DIR =" $env:VENV_CONFIG_DIR

