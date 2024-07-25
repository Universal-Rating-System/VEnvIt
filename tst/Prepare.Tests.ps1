function Add-EnvVarIfNotExists {
    param (
        [string]$varName,
        [string]$varValue
    )
    $existingValue = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    if (-not $existingValue) {
        [System.Environment]::SetEnvironmentVariable($varName, $varValue, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "$varName = $varValue has been set."
    }
    return $true
}

function Remove-EnvVarIfExists {
    param (
        [string]$varName
    )
    $existingValue = [System.Environment]::GetEnvironmentVariable($varName, [System.EnvironmentVariableTarget]::Machine)
    if ($existingValue) {
        [System.Environment]::SetEnvironmentVariable($varName, $null, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "$varName has been removed."
    }
    return $true
}

$rc = $true
$rc = Add-EnvVarIfNotExists -varName "RTE_ENVIRONMENT" "loc_dev" -and $rc
$rc = Add-EnvVarIfNotExists -varName "SCRIPTS_DIR" "g:\scripts" -and $rc
$rc = Add-EnvVarIfNotExists -varName "SECRETS_DIR" "g:\secrets" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENV_ENVIRONMENT" -and $rc
$rc = Remove-EnvVarIfExists -varName "PROJECTS_BASE_DIR" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENVIT_DIR" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENV_SECRETS_DIR" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENV_BASE_DIR" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENV_PYTHON_BASE_DIR" -and $rc
$rc = Remove-EnvVarIfExists -varName "VENV_CONFIG_DIR" -and $rc

if ($rc) {
    exit 0
} else {
    exit 1
}
