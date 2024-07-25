$existingValue = [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
if ($existingValue) {
    Write-Host "RTE_ENVIRONMENT was not removed successfully" -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine)
if ($existingValue) {
    Write-Host "SCRIPTS_DIR was not removed successfully" -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "VENV_ENVIRONMENT does not exist." -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "PROJECTS_BASE_DIR does not exist." -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "VENVIT_DIR does not exist." -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "VENV_SECRETS_DIR does not exist." -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "VENV_BASE_DIR does not exist." -ForegroundColor Red
}
$existingValue = [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
if (-not $existingValue) {
    Write-Host "VENV_PYTHON_BASE_DIR does not exist." -ForegroundColor Red
}

Remove-Item -Path $env:VENV_SECRETS_DIR -Recurse -Force
Remove-Item -Path $env:VENVIT_DIR -Recurse -Force
