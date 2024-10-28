if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1
function New-TestEnvironment {

}

function Get-BackedupEnvironmentVariables {
    param(
        [PSCustomObject]$OriginalValues
    )
    $env:PROJECT_NAME = $OriginalValues.PROJECT_NAME
    $env:PROJECTS_BASE_DIR = $OriginalValues.PROJECTS_BASE_DIR
    $env:VENV_BASE_DIR = $OriginalValues.VENV_BASE_DIR
    $env:VENV_CONFIG_DEFAULT_DIR = $OriginalValues.VENV_CONFIG_DEFAULT_DIR
    $env:VENV_CONFIG_USER_DIR = $OriginalValues.VENV_CONFIG_USER_DIR
    $env:VENV_ENVIRONMENT = $OriginalValues.VENV_ENVIRONMENT
    $env:VENV_ORGANIZATION_NAME = $OriginalValues.VENV_ORGANIZATION_NAME
    $env:VENV_PYTHON_BASE_DIR = $OriginalValues.VENV_PYTHON_BASE_DIR
    $env:VENV_SECRETS_DEFAULT_DIR = $OriginalValues.VENV_SECRETS_DEFAULT_DIR
    $env:VENV_SECRETS_USER_DIR = $OriginalValues.VENV_SECRETS_USER_DIR
    $env:VENVIT_DIR = $OriginalValues.VENVIT_DIR
}

    function Invoke-TestSetup {
    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $env:PROJECT_NAME = $mockInstalVal.ProjectName
    $env:PROJECTS_BASE_DIR = "$tempDir\Projects"
    $env:VENV_BASE_DIR = "$tempDir\VEnv"
    $env:VENVIT_DIR = "$tempDir\VEnvIt"

    $env:VENV_CONFIG_DEFAULT_DIR = "$env:VENVIT_DIR\VENV_CONFIG_DEFAULT_DIR"
    $env:VENV_CONFIG_USER_DIR = "$tempDir\User\VENV_CONFIG_USER_DIR"
    $env:VENV_ENVIRONMENT = "loc_dev"
    $env:VENV_ORGANIZATION_NAME = $mockInstalVal.Organization
    $env:VENV_SECRETS_DEFAULT_DIR = "$env:VENVIT_DIR\VENV_SECRETS_DEFAULT_DIR"
    $env:VENV_SECRETS_USER_DIR = "$tempDir\User\VENV_SECRETS_USER_DIR"
    $env:VIRTUAL_ENV = ("$env:VENV_BASE_DIR\" + $mockInstalVal.ProjectName)

    $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
    $env:PROJECT_DIR = (Join-Path -Path $mockInstalVal.OrganizationDir -ChildPath $env:PROJECT_NAME)
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value $env:PROJECT_DIR

    New-Item -ItemType Directory -Path $env:PROJECT_DIR | Out-Null
    New-Item -ItemType Directory -Path $env:VENV_CONFIG_DEFAULT_DIR | Out-Null
    New-Item -ItemType Directory -Path $env:VENV_CONFIG_USER_DIR | Out-Null
    New-Item -ItemType Directory -Path $env:VENV_SECRETS_DEFAULT_DIR | Out-Null
    New-Item -ItemType Directory -Path $env:VENV_SECRETS_USER_DIR | Out-Null

    $fileName = Get-ConfigFileName -ProjectName $mockInstalVal.ProjectName -Prefix "CustomSetup"
    $scriptPath = Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null
    $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null

    $scriptPath = Join-Path -Path $env:VENV_SECRETS_DEFAULT_DIR -ChildPath "dev_env_var.ps1"
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null
    Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $scriptPath + '"')

    $scriptPath = Join-Path -Path $env:VENV_SECRETS_USER_DIR -ChildPath "dev_env_var.ps1"
    New-Item -Path $scriptPath -ItemType File -Force | Out-Null
    Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $scriptPath + '"')

    return $mockInstalVal
}

function Set-BackupEnvironmentVariables {
    return [PSCustomObject]@{
        PROJECT_NAME             = $env:PROJECT_NAME
        PROJECTS_BASE_DIR        = $env:PROJECTS_BASE_DIR
        VENV_BASE_DIR            = $env:VENV_BASE_DIR
        VENV_CONFIG_USER_DIR     = $env:VENV_CONFIG_USER_DIR
        VENV_CONFIG_DEFAULT_DIR  = $env:VENV_CONFIG_DEFAULT_DIR
        VENV_ENVIRONMENT         = $env:VENV_ENVIRONMENT
        VENV_ORGANIZATION_NAME   = $env:VENV_ORGANIZATION_NAME
        VENV_PYTHON_BASE_DIR     = $env:VENV_PYTHON_BASE_DIR
        VENV_SECRETS_DEFAULT_DIR = $env:VENV_SECRETS_DEFAULT_DIR
        VENV_SECRETS_USER_DIR    = $env:VENV_SECRETS_USER_DIR
        VENVIT_DIR               = $env:VENVIT_DIR
    }
}

Export-ModuleMember -Function Get-BackedupEnvironmentVariables, Invoke-TestSetup, New-TestENvironment, Set-BackupEnvironmentVariables
