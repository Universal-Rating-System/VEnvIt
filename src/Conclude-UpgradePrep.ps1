# A list of version changes (This is just an example)
$versionChanges = @{
    '6.0.1' = 'Upgrade_6_0_1'
    '6.1.0' = 'Upgrade_6_1_0'
    '7.0.0' = 'Upgrade_7_0_0'
}


function Upgrade_6_0_1 {
    Write-Host "Applying upgrade for version 6.0.1"
    # Apply necessary changes for version 6.0.1
}

function Upgrade_6_1_0 {
    Write-Host "Applying upgrade for version 6.1.0"
    # Apply necessary changes for version 6.1.0
}

function Upgrade_7_0_0 {
    Write-Host "Applying upgrade for version 7.0.0"
    # Apply necessary changes for version 7.0.0
}

function Update-Package {
    param(
        [string]$currentManifestPath,
        [string]$latestManifestPath
    )
    # Import current and latest manifest
    $currentManifest = Import-PowerShellDataFile -Path $currentManifestPath
    $latestManifest = Import-PowerShellDataFile -Path $latestManifestPath

    $currentVersion = [version]$currentManifest.ModuleVersion
    $latestVersion = [version]$latestManifest.ModuleVersion

    # Apply changes from current version to latest
    foreach ($version in $versionChanges.Keys) {
        if ([version]$version -gt $currentVersion -and [version]$version -le $latestVersion) {
            Write-Host "Applying changes for version $version"
            & $versionChanges[$version]  # Call the corresponding upgrade function
        }
    }
}
# Script execution starts here
# This block is ONLY executed if the script is run directly, not dot-sourced i.e. by Pester
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    param (
        [string]$currentManifestPath,
        [string]$latestManifestPath
    )
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]============================================[ Upgrade.ps1 ]=" -ForegroundColor Blue
    Write-Host "Update manifest" -ForegroundColor Blue

    if (-not $currentManifestPath -or -not $latestManifestPath) {
        throw "Both -currentManifestPath and -latestManifestPath parameters are required."
    }
    Update-Package -currentPath $currentManifestPath -latestPath $latestManifestPath
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
    Write-Host ''
    Write-Host ''
}
