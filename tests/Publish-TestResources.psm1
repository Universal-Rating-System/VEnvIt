if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

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

function Invoke-TestSetup_0_0_0 {
    $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    $tempDir = New-CustomTempDir -Prefix "VenvIt"
    $mockInstalVal | Add-Member -MemberType NoteProperty -Name "TempDir" -Value $tempDir

    $env:ENVIRONMENT = "loc_dev"
    $env:PROJECTS_BASE_DIR = "$tempDir\Projects"
    $env:RTE_ENVIRONMENT = "loc_dev"
    $env:SCRIPTS_DIR = "$tempDir\Batch"
    $env:VENV_BASE_DIR = "$tempDir\venv"
    $env:VENV_PYTHON_BASE_DIR = "$tempDir\Python"

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

function Invoke-TestSetup_6_0_0 {
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
    Write-Host $mockInstalVal.OrganizationDir
    Write-Host $env:PROJECT_DIR

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

function Invoke-TestSetup_7_0_0 {
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

    #Create the directory structure
    $directories = @(
        $env:PROJECT_DIR,
        "$env:VENV_BASE_DIR\${env:PROJECT_NAME}_env\Scripts",
        $env:VENV_CONFIG_DEFAULT_DIR,
        $env:VENV_CONFIG_USER_DIR,
        $env:VENV_SECRETS_DEFAULT_DIR,
        $env:VENV_SECRETS_USER_DIR
    )
    foreach ($directory in $directories) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }

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

    # Create the sccrtet's files
    $directories = @( $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR )
    foreach ($directory in $directories) {
        $scriptPath = Join-Path -Path $directory -ChildPath "secrets.ps1"
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        Set-Content -Path $scriptPath -Value ('Write-Host "Executing ' + $scriptPath + '"')
    }

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

Export-ModuleMember -Function Get-BackedupEnvironmentVariables, Invoke-TestSetup_0_0_0, Invoke-TestSetup_6_0_0, Invoke-TestSetup_7_0_0
Export-ModuleMember -Function New-CreateAppScripts, New-TestEnvironment, Set-BackupEnvironmentVariables
