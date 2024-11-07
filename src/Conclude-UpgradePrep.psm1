if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

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

function Get-Version {
    if (Test-Path "env:SCRIPTS_DIR") {
            $version = "0.0.0"
    } elseif (Test-Path "env:VENVIT_DIR") {
        $manifestPath = Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)
        if (Test-Path $manifestPath) {
            $Manifest = Import-PowerShellDataFile -Path $manifestPath
            $version = [version]$Manifest.ModuleVersion
        } else {
            $version = "6.0.0"
        }
    } else {
        $version = $null
    }

    return $version
}

function Invoke-PrepForUpgrade_6_0_0 {
    # Apply necessary changes and cleanup to prepare and implement v6.0.0
    # The current installed version is pre v6.0.0
    Write-Host "Applying upgrade for version 6.0.0"
    if ((Get-Item "env:RTE_ENVIRONMENT").Value) {
        $env:VENV_ENVIRONMENT = $env:RTE_ENVIRONMENT
    }
    $env:VENV_CONFIG_DIR = $env:SCRIPTS_DIR
    $env:VENV_SECRETS_DIR = $env:SECRETS_DIR
    $env:VENVIT_DIR = $env:SCRIPTS_DIR

    foreach ($var in $PreVersion600EnvVars) {
        Remove-EnvVarIfExists -EnvVarName $var[0]
    }
}

function Invoke-PrepForUpgrade_7_0_0 {
    # Apply necessary changes and cleanup to prepare and implement v7.0.0
    # The current installed version is pre v7.0.0
    Write-Host "Applying upgrade for version 7.0.0"

    $env:VENV_CONFIG_USER_DIR = $env:VENV_CONFIG_DIR


    $fileName = "venv_*"
    $scriptPath = Join-Path -Path $env:SCRIPTS_DIR -ChildPath $fileName
    Move-Item -Path $scriptPath -Destination $env:VENVIT_DIR -Force
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
    if ((Get-Item "Env:$EnvVarName" -ErrorAction Ignore).Value) {
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
        $fileList = "$env:SCRIPTS_DIR"
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
