# Pester test for vn.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vn.ps1 -Pester
    }
    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }
    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-Vn" -MockWith { Write-Host "Mock: Invoke-Vn called" }
        }
        It "Should call Invoke-Vn function with ProjectName" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName "Tes01"
            # Assert-MockCalled -CommandName "Invoke-MyScript" -Exactly 1 -ParameterFilter { $Var01 -eq 'TestValue' }
            Assert-MockCalled -CommandName "Invoke-Vn" -Exactly 1
        }
    }

    Context "When Var01 is an empty string and Help is not passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function testing" {
    BeforeAll {
        . $PSScriptRoot\..\src\vn.ps1 -Pester
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module $PSScriptRoot\..\src\Utils.psm1

        $OrigPROJECT_NAME = $env:PROJECT_NAME
        $OrigPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
        $OrigVENV_BASE_DIR = $env:VENV_BASE_DIR
        $OrigVENV_CONFIG_USER_DIR = $env:VENV_CONFIG_USER_DIR
        $OrigVENV_CONFIG_ORG_DIR = $env:VENV_CONFIG_ORG_DIR
        $OrigVENV_ENVIRONMENT = $env:VENV_ENVIRONMENT
        $OrigVENV_ORGANIZATION_NAME = $env:VENV_ORGANIZATION_NAME
        $OrigVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
        $OrigVENV_SECRETS_ORG_DIR = $env:VENV_SECRETS_ORG_DIR
        $OrigVENV_SECRETS_USER_DIR = $env:VENV_SECRETS_USER_DIR
        $OrigVENVIT_DIR = $env:VENVIT_DIR

        $mockInstalVal = [PSCustomObject]@{ ProjectName = "MyProject"; PythonVer = "312"; Organization = "MyOrg"; DevMode = "Y"; ResetScripts = "Y" }
    }

    Context "Backup-ScriptToArchiveIfExists" {
        # TODO
        # Test to be implemented
    }
    Context "Backup-CongigScripts" {
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $env:VENV_CONFIG_ORG_DIR = "$tempDir\VENV_CONFIG_ORG_DIR"
            $env:VENV_CONFIG_USER_DIR = "$tempDir\VENV_CONFIG_USER_DIR"

            New-Item -ItemType Directory -Path $env:VENV_CONFIG_ORG_DIR | Out-Null
            New-Item -ItemType Directory -Path $env:VENV_CONFIG_USER_DIR | Out-Null

            $fileName = ("VEnv" + $mockInstalVal.ProjectName + "Install.ps1")
            $scriptPath = Join-Path -Path $env:VENV_CONFIG_ORG_DIR -ChildPath $fileName
            New-Item -Path $scriptPath -ItemType File -Force

            $fileName = ("VEnv" + $mockInstalVal.ProjectName + "CustomSetup.ps1")
            $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName
            New-Item -Path $scriptPath -ItemType File -Force

        }
        It "Should chreate zip archives" {
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            Backup-CongigScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_ORG_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_USER_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
        }

        AfterEach {

        }
    }

    Context "Confirm-EnvironmentVariables" {
        BeforeEach {
            $env:VENV_ENVIRONMENT = "venv_environment"
            $env:VENVIT_DIR = "venvit_dir"
            $env:VENV_SECRETS_DIR = "venv_secrets_dir"
            $env:VENV_CONFIG_DIR = "venv_config_dir"
            $env:PROJECTS_BASE_DIR = "projects_base_dir"
            $env:VENV_BASE_DIR = "venv_base_dir"
            $env:VENV_PYTHON_BASE_DIR = "venv_python_base_dir"
        }
        It "Should be true" {
            Confirm-EnvironmentVariables | Should -Be $true
        }
        It "Should be false" {
            $env:VENV_ENVIRONMENT = ""
            Confirm-EnvironmentVariables | Should -Be $false
        }
        AfterEach {
        }
    }

    Context "Get-InstallationValues" {
        It "All parameters set" {
            $InstallValues = Get-InstallationValues -ProjectName "MyProject" -PythonVer "311" -Organization "MyOrg" -DevMode "Y" -ResetScripts "Y"
            $InstallValues.PythonVer | Should -Be "311"
            $InstallValues.Organization | Should -Be "MyOrg"
            $InstallValues.DevMode | Should -Be "Y"
            $InstallValues.ResetScripts | Should -Be "Y"
        }
    }

    Context "Get-Value" {
        It "With set values" {
            $Value = Get-Value -CurrValue "311" -Prompt "Python version" -DefValue "312"
            $Value | Should -Be "311"
        }
        It "Read from console" {
            Mock Read-Host { "314" } -ParameterFilter { $Prompt -eq "Python version (default: 310)" }
            $Value = Get-Value -Prompt "Python version" -DefValue "310"
            $Value | Should -Be "314"
        }
        It "Get default value" {
            Mock Read-Host { "" } -ParameterFilter { $Prompt -eq "Python version (default: 39)" }
            $Value = Get-Value -Prompt "Python version" -DefValue "39"
            $Value | Should -Be "39"
        }
    }

    Context "Invoke-VirtualEnvironment" {
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $env:PROJECT_NAME = $mockInstalVal.ProjectName
            $env:PROJECTS_BASE_DIR = "$tempDir\PROJECTS_BASE_DIR"
            $env:VENV_BASE_DIR = "$tempDir\VENV_BASE_DIR"
            $env:VENV_ORGANIZATION_NAME = $mockInstalVal.Organization

            $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
            $mockInstalVal | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
            $mockInstalVal | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value (Join-Path -Path $mockInstalVal.OrganizationDir -ChildPath $env:PROJECT_NAME)

            New-Item -ItemType Directory -Path $env:PROJECTS_BASE_DIR | Out-Null
            New-Item -ItemType Directory -Path $mockInstalVal.ProjectDir | Out-Null
            New-Item -ItemType Directory -Path $env:VENV_BASE_DIR | Out-Null
        }

        It "Should install Python virtual environment" {
            Invoke-VirtualEnvironment -InstallationValues $mockInstalVal
            $PythonExePath = "$env:VENV_BASE_DIR\$env:PROJECT_NAME" + "_env\Scripts\python.exe"
            (Test-Path $PythonExePath) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }

    Context "New-ProjectInstallScript" {
        BeforeEach {
            Mock CreatePreCommitConfigYaml { return $true}
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $env:PROJECT_NAME = $mockInstalVal.ProjectName
            $env:PROJECTS_BASE_DIR = "$tempDir\PROJECTS_BASE_DIR"
            # $env:VENV_BASE_DIR = "$tempDir\VENV_BASE_DIR"
            $env:VENV_ORGANIZATION_NAME = $mockInstalVal.Organization

            $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
            $mockInstalVal | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
            $mockInstalVal | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value (Join-Path -Path $mockInstalVal.OrganizationDir -ChildPath $env:PROJECT_NAME)

            # $env:VENV_ORGANIZATION_NAME = $mockInstalVal.Organization
            New-Item -ItemType Directory -Path $env:PROJECTS_BASE_DIR | Out-Null
            New-Item -ItemType Directory -Path $mockInstalVal.ProjectDir | Out-Null
            # New-Item -ItemType Directory -Path $env:VENV_BASE_DIR | Out-Null
        }
        It "Should create project install.ps1" {
            New-ProjectInstallScript -InstallationValues $mockInstalVal
            $installScriptPath = (Join-Path -Path $mockInstalVal.ProjectDir -ChildPath "install.ps1")
            (Test-Path $installScriptPath) | Should -Be $true
            Assert-MockCalled -CommandName CreatePreCommitConfigYaml
        }

        AfterEach {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }

    Context "New-VirtualEnvironment" {
        # TODO
        # Test to be implemented
    }

    Context "Set-Environment" {
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $env:PROJECTS_BASE_DIR = "$tempDir\PROJECTS_BASE_DIR"
            $env:VENV_SECRETS_ORG_DIR = "$tempDir\VENV_SECRETS_ORG_DIR"
            $env:VENV_SECRETS_USER_DIR = "$tempDir\VENV_SECRETS_USER_DIR"
            $secretsContents = @"
            Write-Host 'This file contains secrets'
"@
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_ORG_DIR | Out-Null
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_USER_DIR | Out-Null
            Set-Content -Path (Join-Path -Path $env:VENV_SECRETS_ORG_DIR -ChildPath "dev_env_var.ps1") -Value $secretsContents
            Set-Content -Path (Join-Path -Path $env:VENV_SECRETS_USER_DIR -ChildPath "dev_env_var.ps1") -Value $secretsContents
        }

        It "Should confirm environment settings" {
            $installationValues = Set-Environment -InstallationValues $mockInstalVal
            $installationValues.ProjectDir | Should -Be "$tempDir\PROJECTS_BASE_DIR\MyOrg\MyProject"
            $installationValues.OrganizationDir | Should -Be "$tempDir\PROJECTS_BASE_DIR\MyOrg"
        }
        AfterEach {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }

    Context "Show-EnvironmentVariables" {
        # TODO
        # Test to be implemented
    }

    AfterAll {
        $env:PROJECT_NAME = $OrigPROJECT_NAME
        $env:PROJECTS_BASE_DIR = $OrigPROJECTS_BASE_DIR
        $env:VENV_BASE_DIR = $OrigVENV_BASE_DIR
        $env:VENV_CONFIG_ORG_DIR = $OrigVENV_CONFIG_ORG_DIR
        $env:VENV_CONFIG_USER_DIR = $OrigVENV_CONFIG_USER_DIR
        $env:VENV_ENVIRONMENT = $OrigVENV_ENVIRONMENT
        $env:VENV_ORGANIZATION_NAME = $OrigVENV_ORGANIZATION_NAME
        $env:VENV_PYTHON_BASE_DIR = $OrigVENV_PYTHON_BASE_DIR
        $env:VENV_SECRETS_ORG_DIR = $OrigVENV_SECRETS_ORG_DIR
        $env:VENV_SECRETS_USER_DIR = $OrigVENV_SECRETS_USER_DIR
        $env:VENVIT_DIR = $OrigVENVIT_DIR
    }
}

