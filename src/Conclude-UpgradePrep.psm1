# A list of version changes (This is just an example)
$VersionChanges = @{
    '0.0.0' = 'Invoke-Upgrade_0_0_0'
    '6.0.0' = 'Invoke-PrepForUpgrade_6_0_0'
    '7.0.0' = 'Invoke-PrepForUpgrade_7_0_0'
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

function Invoke-PrepForUpgrade_6_0_0 {
    # Apply necessary changes and cleanup to prepare an implement v6.0.0
    # The current installed version is pre v6.0.0
    Write-Host "Applying upgrade for version 6.0.0"
}

function Invoke-PrepForUpgrade_7_0_0 {
    # Apply necessary changes and cleanup to prepare an implement v7.0.0
    # The current installed version is pre v7.0.0
    Write-Host "Applying upgrade for version 7.0.0"
}

function Update-PackagePrep {
    param(
        [string]$UpgradeScriptDir
    )

    $CurrentVersion = Get-Version -ScriptDir $env:VENVIT_DIR
    $UpgradeVersion = Get-Version -ScriptDir $UpgradeScriptDir

    # Apply changes from current version to latest
    foreach ($version in $VersionChanges.Keys | Sort-Object { [version]$_ }) {
        if ([version]$version -gt $currentVersion -and [version]$version -le $UpgradeVersion) {
            Write-Host "Applying changes for version $version"
            & $VersionChanges[$version]  # Call the corresponding upgrade function
        }
    }
}

Export-ModuleMember -Function Get-ManifestFileName, Get-Version, Update-PackagePrep, Invoke-PrepForUpgrade_6_0_0, Invoke-PrepForUpgrade_7_0_0
