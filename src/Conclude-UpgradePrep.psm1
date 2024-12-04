if ((Get-Module -Name "Utils") -and $Pester ) {
    Remove-Module -Name "Utils"
}
Import-Module $PSScriptRoot\..\src\Utils.psm1
$VersionChanges = @{
    '0.0.0' = 'Invoke-Upgrade_0_0_0'
    '6.0.0' = 'Invoke-PrepForUpgrade_6_0_0'
    '7.0.0' = 'Invoke-PrepForUpgrade_7_0_0'
}
$PreVersion600EnvVars = @( "RTE_ENVIRONMENT", "SCRIPTS_DIR", "SECRETS_DIR" )
$PreVersion700EnvVars = @( "VENV_CONFIG_DIR", "VENV_SECRETS_DIR" )

function Invoke-PrepForUpgrade_6_0_0 {
    # Apply necessary changes and cleanup to prepare and implement v6.0.0
    # The current installed version is pre v6.0.0
    if ((Get-Item "env:RTE_ENVIRONMENT").Value) {
        $env:VENV_ENVIRONMENT = $env:RTE_ENVIRONMENT
    }
    $env:VENV_CONFIG_DIR = $env:SCRIPTS_DIR
    $env:VENV_SECRETS_DIR = $env:SECRETS_DIR
    $env:VENVIT_DIR = $env:SCRIPTS_DIR

    [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DIR", $env:VENV_CONFIG_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DIR", $env:VENV_SECRETS_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $env:VENVIT_DIR, [System.EnvironmentVariableTarget]::Machine)

    foreach ($var in $PreVersion600EnvVars) {
        Remove-EnvVarIfExists -EnvVarName $var
    }
}

function Invoke-PrepForUpgrade_7_0_0 {
    # Apply necessary changes and cleanup to prepare and implement v7.0.0
    # The current installed version is pre v7.0.0
    $env:VENV_CONFIG_USER_DIR = $env:VENV_CONFIG_DIR | Out-Null
    $env:VENV_SECRETS_USER_DIR = $env:VENV_SECRETS_DIR | Out-Null

    [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $env:VENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $env:VENV_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)


    $postFix = @(@("install", "Install"), @("setup_custom", "CustomSetup"))
    foreach ($postfix in $postFix) {
        $filenameFilter = "venv_*_" + $postFix[0] + ".ps1"
        $files = Get-ChildItem -Path $env:VENV_CONFIG_USER_DIR -Filter $filenameFilter
        foreach ($file in $files) {
            $filterRe = "venv_(.+)_" + $postFix[0] + "\.ps1"
            if ($file.Name -match $filterRe) {
                $projectName = $matches[1]
                $newFileName = "VEnv$ProjectName" + $postFix[1] + ".ps1"
                Rename-Item -Path $file.FullName -NewName $newFileName
                # Write-Host "Renamed '$($file.Name)' to '$newFileName'"
            }
        }
    }

    foreach ($var in $PreVersion700EnvVars) {
        Remove-EnvVarIfExists -EnvVarName $var
    }
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
    # Write-Host "$EnvVarName has been removed."
}

function Update-PackagePrep {
    param(
        [string]$UpgradeScriptDir
    )

    if (Test-Path "env:VENVIT_DIR") {
        $CurrentVersion = Get-Version -SourceDir $env:VENVIT_DIR
        $currentInstallDir = $env:VENVIT_DIR
    }
    elseif (Test-Path "env:SCRIPTS_DIR") {
        $CurrentVersion = Get-Version -SourceDir $env:SCRIPTS_DIR
        $currentInstallDir = $env:SCRIPTS_DIR
    }
    else {
        $CurrentVersion = $null
        $currentInstallDir = $null
    }

    if ($CurrentVersion) {
        $UpgradeVersion = Get-Version -SourceDir $UpgradeScriptDir
        $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        Backup-ArchiveOldVersion -InstallationDir $currentInstallDir -TimeStamp $timeStamp | Out-Null
        # Apply changes from current version to latest
        foreach ($version in $VersionChanges.Keys | Sort-Object { [version]$_ }) {
            if ([version]$version -gt $currentVersion -and [version]$version -le $UpgradeVersion) {
                & $VersionChanges[$version]  | Out-Null # Call the corresponding upgrade function
            }
        }
    }

    return $CurrentVersion
}

Export-ModuleMember -Function Get-ManifestFileName, Get-Version, Update-PackagePrep, Invoke-PrepForUpgrade_6_0_0
Export-ModuleMember -Function Invoke-PrepForUpgrade_7_0_0, Remove-EnvVarIfExists
Export-ModuleMember -Variable PreVersion600EnvVars
