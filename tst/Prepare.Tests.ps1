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

$rc = $true
$rc = Add-EnvVarIfNotExists -varName "RTE_ENVIRONMENT" "loc_dev" -and $rc
$rc = Add-EnvVarIfNotExists -varName "SCRIPTS_DIR" "g:\scripts" -and $rc

if ($rc) {
    exit 0
} else {
    exit 1
}
