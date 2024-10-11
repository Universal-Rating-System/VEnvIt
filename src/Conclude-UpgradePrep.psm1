# A list of version changes (This is just an example)
function Get-ManifestFileName {
    return "Manifest.psd1"
}

# function Get-VersionChanges {
#     return @{
#         '6.0.0' = 'Upgrade_6_0_0'
#         '7.0.0' = 'Upgrade_7_0_0'
#     }
# }
$VersionChanges = @{
        '6.0.0' = 'Invoke-Upgrade_6_0_0'
        '7.0.0' = 'Invoke-Upgrade_7_0_0'
    }

function Invoke-Upgrade_6_0_0 {
    Write-Host "Applying upgrade for version 6.0.0"
    # Apply necessary changes for version 6.0.0
}

function Invoke-Upgrade_7_0_0 {
    Write-Host "Applying upgrade for version 7.0.0"
    # Apply necessary changes for version 7.0.0
}

function Update-Package {
    param(
        [string]$UpgradeScriptDir
    )
    # Import current and latest manifest
    $CurrentManifestPath = Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)
    $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
    $CurrentManifest = Import-PowerShellDataFile -Path $CurrentManifestPath
    $UpgradeManifest = Import-PowerShellDataFile -Path $UpgradeManifestPath

    $CurrentVersion = [version]$CurrentManifest.ModuleVersion
    $UpgradeVersion = [version]$UpgradeManifest.ModuleVersion

    # Apply changes from current version to latest
    # foreach ($version in $VersionChanges.Keys) {
    # $VersionChanges = (Get-VersionChanges)
    foreach ($version in $VersionChanges.Keys | Sort-Object { [version]$_ }) {
        if ([version]$version -gt $currentVersion -and [version]$version -le $UpgradeVersion) {
            Write-Host "Applying changes for version $version"
            # Invoke-Upgrade_6_0_0
            & $VersionChanges[$version]  # Call the corresponding upgrade function
        }
    }
}

# Script execution starts here
# This block is ONLY executed if the script is run directly, not dot-sourced i.e. by Pester
# if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
#     param (
#         [string]$CurrentManifestPath,
#         [string]$UpgradeManifestPath
#     )
#     Write-Host ''
#     Write-Host ''
#     $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     Write-Host "=[ START $dateTime ]============================================[ Upgrade.ps1 ]=" -ForegroundColor Blue
#     Write-Host "Update manifest" -ForegroundColor Blue

#     if (-not $CurrentManifestPath -or -not $UpgradeManifestPath) {
#         throw "Both -CurrentManifestPath and -UpgradeManifestPath parameters are required."
#     }
#     Update-Package -CurrentDir $CurrentManifestPath -LatestDir $UpgradeManifestPath
#     Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
#     Write-Host ''
#     Write-Host ''
# }
Export-ModuleMember -Function Get-ManifestFileName, Update-Package, Invoke-Upgrade_6_0_0, Invoke-Upgrade_7_0_0
