$VersionChanges = @{
    '0.0.0' = 'Invoke-Upgrade_0_0_0'
    '6.0.0' = 'Invoke-PrepForUpgrade_6_0_0'
    '7.0.0' = 'Invoke-PrepForUpgrade_7_0_0'
}
$PreVersion600EnvVars = @(
    @("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT),
    @("SCRIPTS_DIR", "$env:SCRIPTS_DIR"),
    @("SECRETS_DIR", "$env:SECRETS_DIR")
)

function Backup-ArchiveOldVersion {
    param(
        [string]$ArchiveVersion,
        [string]$FileList,
        [string]$TimeStamp
    )

    $archiveDir = Join-Path -Path $env:SCRIPTS_DIR -ChildPath "Archive"
    $destination = Join-Path -Path $archiveDir -Child "Version_$ArchiveVersion$TimeStamp.zip"
    if (-not(Test-Path $archiveDir)) {
        New-Item -Path $archiveDir -ItemType Directory | Out-Null
    }
    $compress = @{
        Path             = $FileList
        CompressionLevel = "Fastest"
        DestinationPath  = $destination
    }
    Compress-Archive @compress | Out-Null

    return $destination
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
    # Apply necessary changes and cleanup to prepare and implement v6.0.0
    # The current installed version is pre v6.0.0
    Write-Host "Applying upgrade for version 6.0.0"
    foreach ($var in $PreVersion600EnvVars) {
        Remove-EnvVarIfExists -EnvVarName $var[0]
    }
}

function Invoke-PrepForUpgrade_7_0_0 {
    # Apply necessary changes and cleanup to prepare and implement v7.0.0
    # The current installed version is pre v7.0.0
    Write-Host "Applying upgrade for version 7.0.0"
    VENV_SECRETS_DIR
    VENV_CONFIG_DIR
}

function Remove-EnvVarIfExists {
    param (
        [array]$EnvVarName
    )
    $existingValue = [System.Environment]::GetEnvironmentVariable($EnvVarName, [System.EnvironmentVariableTarget]::Machine)
    if ($existingValue) {
        [System.Environment]::SetEnvironmentVariable($EnvVarName, $null, [System.EnvironmentVariableTarget]::Machine)
    }
    if ((Get-Item "Env:$EnvVarName").Value) {
        $var = "Env:$EnvVarName"
        Remove-Item -Path "Env:$EnvVarName"
    }
    Write-Host "$EnvVarName has been removed."
}

function Update-PackagePrep {
    param(
        [string]$UpgradeScriptDir
    )

    $CurrentVersion = Get-Version -ScriptDir $env:VENVIT_DIR
    $UpgradeVersion = Get-Version -ScriptDir $UpgradeScriptDir

    $timeStamp = Get-Date -Format "yyyyMMddHHmm"
    if ($CurrentVersion -eq "0.0.0") {
        $fileList = "$env:SCRIPTS_DIR\*.*"
    }
    else {
        $fileList = $env:VENVIT_DIR
    }
    Backup-ArchiveOldVersion -ArchiveVersion $CurrentVersion -FileList $fileList -TimeStamp $timeStamp

    # Apply changes from current version to latest
    foreach ($version in $VersionChanges.Keys | Sort-Object { [version]$_ }) {
        if ([version]$version -gt $currentVersion -and [version]$version -le $UpgradeVersion) {
            Write-Host "Applying changes for version $version"
            & $VersionChanges[$version]  # Call the corresponding upgrade function
        }
    }
}

Export-ModuleMember -Function Backup-ArchiveOldVersion, Get-ManifestFileName, Get-Version, Update-PackagePrep, Invoke-PrepForUpgrade_6_0_0
Export-ModuleMember -Function Invoke-PrepForUpgrade_7_0_0, Remove-EnvVarIfExists
Export-ModuleMember -Variable PreVersion600EnvVars
