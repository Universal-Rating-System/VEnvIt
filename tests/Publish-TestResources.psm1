# Publish-TestResources.psm1


if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1

if ((Get-Module -Name "Utils") -and $Pester ) {
    if (Test-Path function:function:prompt) { Copy-Item -Path function:prompt -Destination function:bakupPrompt }
    if (Test-Path function:_OLD_VIRTUAL_PROMPT) { Copy-Item function:_OLD_VIRTUAL_PROMPT -Destination function:backup_OLD_VIRTUAL_PROMPT }
    Remove-Module -Name "Utils"
    if (Test-Path function:function:bakupPrompt) { Copy-Item -Path function:bakupPrompt -Destination function:prompt }
    if (Test-Path function:backup_OLD_VIRTUAL_PROMPT) { Copy-Item -Path function:backup_OLD_VIRTUAL_PROMPT -Destination function:_OLD_VIRTUAL_PROMPT }
}
Import-Module $PSScriptRoot\..\src\Utils.psm1
if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1

$ManifestData000 = @{
    Version     = "0.0.0"
    Authors     = "Ann Other <ann@other.com>"
    Description = "Description of 0.0.0"
}
$ManifestData600 = @{
    Version     = "6.0.0"
    Authors     = "Ann Other <ann@other.com>"
    Description = "Description of 6.0.0"
}
$ManifestData700 = @{
    Version     = "7.0.0"
    Authors     = "Ann Other <ann@other.com>"
    Description = "Description of 7.0.0"
}

function Backup-SessionEnvironmentVariables {
    return [PSCustomObject]@{
        PROJECT_NAME             = $env:PROJECT_NAME
        PROJECTS_BASE_DIR        = $env:PROJECTS_BASE_DIR
        RTE_ENVIRONMENT          = $env:RTE_ENVIRONMENT
        SECRETS_DIR              = $env:SECRETS_DIR
        SCRIPTS_DIR              = $env:SCRIPTS_DIR
        VENV_BASE_DIR            = $env:VENV_BASE_DIR
        VENV_CONFIG_USER_DIR     = $env:VENV_CONFIG_USER_DIR
        VENV_CONFIG_DEFAULT_DIR  = $env:VENV_CONFIG_DEFAULT_DIR
        VENV_ENVIRONMENT         = $env:VENV_ENVIRONMENT
        VENV_ORGANIZATION_NAME   = $env:VENV_ORGANIZATION_NAME
        VENV_PYTHON_BASE_DIR     = $env:VENV_PYTHON_BASE_DIR
        VENV_SECRETS_DEFAULT_DIR = $env:VENV_SECRETS_DEFAULT_DIR
        VENV_SECRETS_USER_DIR    = $env:VENV_SECRETS_USER_DIR
        VENVIT_DIR               = $env:VENVIT_DIR
        VIRTUAL_ENV              = $env:VIRTUAL_ENV
    }
}

function Backup-SystemEnvironmentVariables {
    return [PSCustomObject]@{
        PROJECT_NAME             = [System.Environment]::GetEnvironmentVariable("PROJECT_NAME", [System.EnvironmentVariableTarget]::Machine)
        PROJECTS_BASE_DIR        = [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
        RTE_ENVIRONMENT          = [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
        SECRETS_DIR              = [System.Environment]::GetEnvironmentVariable("SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine)
        SCRIPTS_DIR              = [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_BASE_DIR            = [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_CONFIG_USER_DIR     = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_CONFIG_DEFAULT_DIR  = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_ENVIRONMENT         = [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
        VENV_ORGANIZATION_NAME   = [System.Environment]::GetEnvironmentVariable("VENV_ORGANIZATION_NAME", [System.EnvironmentVariableTarget]::Machine)
        VENV_PYTHON_BASE_DIR     = [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_SECRETS_DEFAULT_DIR = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENV_SECRETS_USER_DIR    = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
        VENVIT_DIR               = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
    }
}

function ConvertFrom-ProdToTestEnvVar {
    param(
        $EnvVarSet,
        [String]$TempDir
    )

    $newEnvVarSet = Copy-Deep $EnvVarSet

    foreach ($envVar in $newEnvVarSet.Keys) {
        if ($newEnvVarSet[$envVar]["IsDir"]) {
            if ($newEnvVarSet[$envVar]["DefVal"] -like "~*") {
                $newEnvVarSet[$envVar]["DefVal"] = $newEnvVarSet[$envVar]["DefVal"] -replace "^~", $tempDir
            }
            elseif ($newEnvVarSet[$envVar]["DefVal"] -like "$env:ProgramFiles*") {
                $escapedProgramFiles = [Regex]::Escape($env:ProgramFiles)
                $newEnvVarSet[$envVar]["DefVal"] = $newEnvVarSet[$envVar]["DefVal"] -replace $escapedProgramFiles, "$tempDir\Program Files"
            }
            elseif (-not $newEnvVarSet[$envVar]["DefVal"]) {
                $newEnvVarSet[$envVar]["DefVal"] = $tempDir
            }
            else {
                $lastChild = Split-Path -Path $newEnvVarSet[$envVar]["DefVal"] -Leaf
                $newEnvVarSet[$envVar]["DefVal"] = Join-Path -Path $tempDir -ChildPath $lastChild
            }
        }
    }
    return $newEnvVarSet
}

function Set-TestSetup_0_0_0 {
    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $env:ENVIRONMENT = "loc_dev"
    $env:PROJECTS_BASE_DIR = "$tempDir\Projects"
    $env:RTE_ENVIRONMENT = "loc_dev"
    $env:SECRETS_DIR = "$tempDir\Batch"
    $env:SCRIPTS_DIR = "$tempDir\Batch"
    $env:VENV_BASE_DIR = "$tempDir\venv"
    $env:VENV_PYTHON_BASE_DIR = "$tempDir\Python"
    $env:VIRTUAL_ENV = ("$env:VENV_BASE_DIR\" + $mockInstalVal.ProjectName)

    $env:VENV_CONFIG_DIR = $null
    $env:VENV_ENVIRONMENT = $null
    $env:VENV_ORGANIZATION_NAME = $null
    $env:VENV_SECRETS_DIR = $null
    $env:VENVIT_DIR = $null

    #Create the directory structure
    $directories = @(
        $env:PROJECTS_BASE_DIR,
        $env:SCRIPTS_DIR,
        $env:VENV_BASE_DIR,
        $env:VENV_PYTHON_BASE_DIR
    )
    foreach ($directory in $directories) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }

    # Create the configuration scripts
    $postfixes = @( "setup_mandatory", "setup_custom", "install" )
    foreach ($postfix in $postfixes) {
        $fileName = "venv_" + $mockInstalVal.ProjectName + "_$postfix.ps1"
        $scriptPath = Join-Path -Path $env:SCRIPTS_DIR -ChildPath $fileName
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value "Mock $fileName file"
    }

    # Create the sccrtet's files
    $scriptPath = Join-Path -Path $env:SCRIPTS_DIR -ChildPath "env_var_loc_dev.bat"
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null
    Set-Content -Path $scriptPath -Value "Mock secrets file"

    New-CreateAppScripts -BaseDirectory $env:SCRIPTS_DIR

    return $mockInstalVal
}

function Set-TestSetup_6_0_0 {
    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $env:PROJECT_NAME = $mockInstalVal.ProjectName
    $env:PROJECTS_BASE_DIR = "$tempDir\Projects"
    $env:VENV_BASE_DIR = "$tempDir\VEnv"
    $env:VENV_CONFIG_DIR = "$tempDir\VENV_CONFIG_DIR"
    $env:VENV_ENVIRONMENT = "loc_dev"
    $env:VENV_ORGANIZATION_NAME = $mockInstalVal.Organization
    $env:VENV_PYTHON_BASE_DIR = "$tempDir\Python"
    $env:VENV_SECRETS_DIR = "$tempDir\VENV_SECRETS_DIR"
    $env:VENVIT_DIR = "$tempDir\VEnvIt"
    $env:VIRTUAL_ENV = ("$env:VENV_BASE_DIR\" + $mockInstalVal.ProjectName)

    $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
    $env:PROJECT_DIR = (Join-Path -Path $mockInstalVal.OrganizationDir -ChildPath $env:PROJECT_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value $env:PROJECT_DIR

    #Create the directory structure
    $directories = @(
        $env:PROJECT_DIR,
        "$env:VENV_BASE_DIR\${env:PROJECT_NAME}_env\Scripts",
        $env:VENV_CONFIG_DIR,
        $env:VENV_PYTHON_BASE_DIR,
        $env:VENV_SECRETS_DIR,
        $env:VENVIT_DIR
    )
    foreach ($directory in $directories) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }

    # Create the configuration scripts
    $postfixes = @( "setup_mandatory", "install", "setup_custom" )
    foreach ($postfix in $postfixes) {
        $fileName = "venv_" + $mockInstalVal.ProjectName + "_$postfix.ps1"
        $scriptPath = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $fileName
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value "Mock $fileName file"
    }

    # Create the sccrtet's files
    $scriptPath = Join-Path -Path $env:VENV_SECRETS_DIR -ChildPath "dev_env_var.ps1"
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null
    Set-Content -Path $scriptPath -Value "Mock $scriptPath file"

    return $mockInstalVal
}

function Set-TestSetup_7_0_0 {
    Import-Module $PSScriptRoot\..\src\Utils.psm1 -Variable defEnvVarSet_7_0_0

    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $newEnvVar = ConvertFrom-ProdToTestEnvVar -EnvVarSet $defEnvVarSet_7_0_0 -TempDir $mockInstalVal.TempDir
    $newEnvVar["PROJECT_NAME"]["DefVal"] = $mockInstalVal.ProjectName
    $newEnvVar["VENV_ORGANIZATION_NAME"]["DefVal"] = $mockInstalVal.Organization
    $newEnvVar["VIRTUAL_ENV"]["DefVal"] = ($newEnvVar["VENV_BASE_DIR"]["DefVal"] + "\" + $mockInstalVal.ProjectName)
    Publish-EnvironmentVariables -EnvVarSet $newEnvVar

    $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
    $env:PROJECT_DIR = (Join-Path -Path $mockInstalVal.OrganizationDir -ChildPath $env:PROJECT_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value $env:PROJECT_DIR

    New-Directories -EnvVarSet $newEnvVar
    New-Item -ItemType Directory -Path $env:PROJECT_DIR | Out-Null

    # Create the configuration scripts
    $postfixes = @( "EnvVar", "Install", "CustomSetup" )
    foreach ($postfix in $postfixes) {
        $fileName = Get-ConfigFileName -ProjectName $mockInstalVal.ProjectName -Postfix $postfix
        $scriptPath = Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $fileName + '"')
        $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $fileName + '"')
    }

    # Create the secrtet's files
    $directories = @( $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR )
    foreach ($directory in $directories) {
        $scriptPath = Join-Path -Path $directory -ChildPath "secrets.ps1"
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $scriptPath + '"')
    }

    # Create a manifest
    New-ManifestPsd1 -DestinationPath (Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)) -Data $ManifestData700

    return $mockInstalVal
}

function Set-TestSetup_InstallationFiles {
    Import-Module $PSScriptRoot\..\src\Utils.psm1

    $installationFileList = @()
    $TempDir = New-CustomTempDir -Prefix "VenvIt"
    $upgradeScriptDir = Join-Path -Path $TempDir -ChildPath "TempUpgradeDir"
    New-Item -ItemType Directory -Path "$upgradeScriptDir\src" | Out-Null
    foreach ($fileName in $sourceFileCopyList) {
        Copy-Item -Path "$PSScriptRoot\..\$fileName" -Destination ("$upgradeScriptDir\$filename")
        $installationFileList += $fileName
    }
    $manifestFileName = Get-ManifestFileName
    $manifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath $manifestFileName
    New-ManifestPsd1 -DestinationPath $manifestPath -data $ManifestData700
    $installationFileList += $manifestFileName
    $installationDetail = @{
        Dir      = "$upgradeScriptDir"
        FileList = $installationFileList.Clone()
    }

    return $installationDetail
}

function Set-TestSetup_New {
    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $env:PROJECT_NAME = $null
    $env:PROJECTS_BASE_DIR = $null
    $env:VENV_BASE_DIR = $null
    $env:VENV_CONFIG_DEFAULT_DIR = $null
    $env:VENV_CONFIG_DIR = $null
    $env:VENV_CONFIG_USER_DIR = $null
    $env:VENV_ENVIRONMENT = $null
    $env:VENV_ORGANIZATION_NAME = $null
    $env:VENV_PYTHON_BASE_DIR = $null
    $env:VENV_SECRETS_DEFAULT_DIR = $null
    $env:VENV_SECRETS_USER_DIR = $null
    $env:VENV_SECRETS_DIR = $null
    $env:VENVIT_DIR = $null
    $env:VIRTUAL_ENV = $null

    return $mockInstalVal
}

function New-CreateAppScripts {
    param(
        [string]$BaseDirectory
    )
    $appScripts = @( "vi.ps1", "vn.ps1", "vr.ps1" )
    foreach ($scriptName in $appScripts) {
        $scriptPath = Join-Path -Path $BaseDirectory -ChildPath $scriptName
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value "Mock script for $scriptName"
    }
}

function Restore-SessionEnvironmentVariables {
    param(
        [PSCustomObject]$OriginalValues
    )
    $env:PROJECT_NAME = $OriginalValues.PROJECT_NAME
    $env:PROJECTS_BASE_DIR = $OriginalValues.PROJECTS_BASE_DIR
    $env:RTE_ENVIRONMENT = $OriginalValues.RTE_ENVIRONMENT
    $env:SECRETS_DIR = $OriginalValues.SECRETS_DIR
    $env:SCRIPTS_DIR = $OriginalValues.SCRIPTS_DIR
    $env:VENV_BASE_DIR = $OriginalValues.VENV_BASE_DIR
    $env:VENV_CONFIG_DEFAULT_DIR = $OriginalValues.VENV_CONFIG_DEFAULT_DIR
    $env:VENV_CONFIG_USER_DIR = $OriginalValues.VENV_CONFIG_USER_DIR
    $env:VENV_ENVIRONMENT = $OriginalValues.VENV_ENVIRONMENT
    $env:VENV_ORGANIZATION_NAME = $OriginalValues.VENV_ORGANIZATION_NAME
    $env:VENV_PYTHON_BASE_DIR = $OriginalValues.VENV_PYTHON_BASE_DIR
    $env:VENV_SECRETS_DEFAULT_DIR = $OriginalValues.VENV_SECRETS_DEFAULT_DIR
    $env:VENV_SECRETS_USER_DIR = $OriginalValues.VENV_SECRETS_USER_DIR
    $env:VENVIT_DIR = $OriginalValues.VENVIT_DIR
    $env:VIRTUAL_ENV = $OriginalValues.VIRTUAL_ENV

}

function Restore-SystemEnvironmentVariables {
    param(
        [PSCustomObject]$OriginalValues
    )
    [System.Environment]::SetEnvironmentVariable("PROJECT_NAME", $OriginalValues.PROJECT_NAME, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $OriginalValues.PROJECTS_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $OriginalValues.RTE_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $OriginalValues.SECRETS_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $OriginalValues.SCRIPTS_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $OriginalValues.VENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $OriginalValues.VENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $OriginalValues.VENV_CONFIG_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $OriginalValues.VENV_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_ORGANIZATION_NAME", $OriginalValues.VENV_ORGANIZATION_NAME, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $OriginalValues.VENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $OriginalValues.VENV_SECRETS_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $OriginalValues.VENV_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $OriginalValues.VENVIT_DIR, [System.EnvironmentVariableTarget]::Machine)
}

Export-ModuleMember -Function Backup-SessionEnvironmentVariables, Backup-SystemEnvironmentVariables, ConvertFrom-ProdToTestEnvVar
Export-ModuleMember -Function Set-TestSetup_0_0_0, Set-TestSetup_6_0_0, Set-TestSetup_7_0_0, Set-TestSetup_InstallationFiles, Set-TestSetup_New
Export-ModuleMember -Function New-CreateAppScripts, New-TestEnvironment, Restore-SessionEnvironmentVariables, Restore-SystemEnvironmentVariables
Export-ModuleMember -Variable ManifestData000, ManifestData600, ManifestData700, sourceFileCopyList
