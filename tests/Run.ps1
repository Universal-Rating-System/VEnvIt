$separator = "-" * 80

# Function to run a script and check for errors
function Invoke-Scripts {
    param (
        [string]$scriptPath,
        [string]$arguments = ""
    )

    Write-Host "Executing $scriptPath $arguments" -ForegroundColor Cyan
    try {
        & $scriptPath $arguments
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Script $scriptPath encountered an error with exit code $LASTEXITCODE." -ForegroundColor Red
            exit $LASTEXITCODE
        } else {
            Write-Host "Script $scriptPath executed successfully." -ForegroundColor Green
        }
    } catch {
        Write-Host "An error occurred while executing $scriptPath\: $_" -ForegroundColor Red
        exit 1
    }
}

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "=[ START $dateTime ]==================================================" -ForegroundColor Blue

# Run Prepare.Tests.ps1
Invoke-Scripts -scriptPath ".\Prepare.Tests.ps1"

Write-Host $separator -ForegroundColor Cyan

# Run download.ps1
Invoke-Scripts -scriptPath "..\src\download.ps1"

Write-Host $separator -ForegroundColor Cyan

# Run Results.Tests.ps1
Invoke-Scripts -scriptPath ".\Results.Tests.ps1"

Write-Host $separator -ForegroundColor Cyan

Write-Host "All scripts executed successfully." -ForegroundColor Green

Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
