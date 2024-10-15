# A list of version changes (This is just an example)
$VersionChanges = @{
    '0.0.0' = 'Invoke-Upgrade_0_0_0'
    '6.0.0' = 'Invoke-Upgrade_6_0_0'
    '7.0.0' = 'Invoke-Upgrade_7_0_0'
}

function Get-ManifestFileName {
    return "Manifest.psd1"
}

function Get-Version {
    param(
        [string]$ScriptDir
    )
    $ManifestPath = Join-Path -Path $ScriptDir -ChildPath (Get-ManifestFileName)
    if (Test-Path -Path $ManifestPath) {
        $Manifest = Import-PowerShellDataFile -Path $ManifestPath
        $Version = [version]$Manifest.ModuleVersion
    }
    else {
        $Version = "0.0.0"
    }

    return $Version
}

function Invoke-Upgrade_0_0_0 {
    Write-Host "Applying upgrade for version 6.0.0"
    # Apply necessary changes for version 6.0.0
}

function Invoke-Upgrade_6_0_0 {
    Write-Host "Applying upgrade for version 6.0.0"
    # Apply necessary changes for version 6.0.0
}

function Invoke-Upgrade_7_0_0 {
    Write-Host "Applying upgrade for version 7.0.0"
    # Apply necessary changes for version 7.0.0
}

function Update-PackagePrep {
    param(
        [string]$UpgradeScriptDir
    )
    # Import current and latest manifest
    # $CurrentManifestPath = Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)
    # $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
    # $CurrentManifest = Get-Version Import-PowerShellDataFile -Path $CurrentManifestPath
    # $UpgradeManifest = Import-PowerShellDataFile -Path $UpgradeManifestPath

    $CurrentVersion = Get-Version -ScriptDir $env:VENVIT_DIR
    $UpgradeVersion = Get-Version -ScriptDir $UpgradeScriptDir

    # Apply changes from current version to latest
    foreach ($version in $VersionChanges.Keys | Sort-Object { [version]$_ }) {
        if ([version]$version -gt $currentVersion -and [version]$version -le $UpgradeVersion) {
            Write-Host "Applying changes for version $version"
            # Invoke-Upgrade_6_0_0
            & $VersionChanges[$version]  # Call the corresponding upgrade function
        }
    }
}

Export-ModuleMember -Function Get-ManifestFileName, Get-Version, Update-PackagePrep, Invoke-Upgrade_6_0_0, Invoke-Upgrade_7_0_0
