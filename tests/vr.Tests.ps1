# vr.Tests.ps1

if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vr.ps1 -Pester
    }
    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { return "Mock: Show-Help called" }
    }
    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vr.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Unregister-VirtualEnvironment" -MockWith { Write-Host "Mock: Unregister-VirtualEnvironment called" }
        }
        It "Should call Unregister-VirtualEnvironment function with ProjectName" {
            . $PSScriptRoot\..\src\vr.ps1 -ProjectName "Tes01"
            Assert-MockCalled -CommandName "Unregister-VirtualEnvironment" -Exactly 1
        }
    }

    Context "When Var01 is an empty string and Help is not passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vr.ps1 -ProjectName $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vr.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function Tests" {
    BeforeAll {
        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
    }

    BeforeEach {
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module $PSScriptRoot\..\src\Utils.psm1
    }

    Context "New-ProjectArchive" {
        BeforeAll {
            . $PSScriptRoot\..\src\vr.ps1 -Pester
            if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
            Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        }

        It "Should create archive and clean directory" {
            $archivePath = New-ProjectArchive -ProjectName $mockInstalVal.ProjectName

            $archivePath | Should -Be (
                Join-Path -Path (
                    Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath "Archive"
                ) -ChildPath ($env:PROJECT_NAME + "_" + $TimeStamp + ".zip")
            )
            $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar")
            (Test-Path -Path $scriptPath) | Should -Be $false
            $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath (Get-ConfigFileName -ProjectName $ProjectName -Postfix "Install")
            (Test-Path -Path $scriptPath) | Should -Be $false
            $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup")
            (Test-Path -Path $scriptPath) | Should -Be $false
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Unregister-VirtualEnvironment" {
        BeforeAll {
            . $PSScriptRoot\..\src\vr.ps1 -Pester
            if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
            Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
        }

        BeforeEach {
            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        }

        It "Should remove the virtual environment" {
            Mock Invoke-Script { return "Mock: Deactivated current VEnv"
            } -ParameterFilter { $ScriptPath -eq "deactivate" }

            Unregister-VirtualEnvironment -ProjectName $mockInstalVal.ProjectName

            (Test-Path -Path "${env:VENV_BASE_DIR}\${ProjectName}_env") | Should -Be $false
            Test-Path env:PROJECT_NAME | Should -Be $false
            (Get-Item -Path ("env:PROJECTS_BASE_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\Projects")
            (Get-Item -Path ("env:VENV_BASE_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\venv")
            (Get-Item -Path ("env:VENV_CONFIG_DEFAULT_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\Config")
            (Get-Item -Path ("env:VENV_CONFIG_USER_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\VenvIt\Config")
            (Get-Item -Path ("env:VENV_ENVIRONMENT")).Value | Should -Be "loc_dev"
            Test-Path env:VENV_ORGANIZATION_NAME | Should -Be $false
            (Get-Item -Path ("env:VENV_PYTHON_BASE_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\Python")
            (Get-Item -Path ("env:VENV_SECRETS_DEFAULT_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\Secrets")
            (Get-Item -Path ("env:VENV_SECRETS_USER_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\VenvIt\Secrets")
            (Get-Item -Path ("env:VENVIT_DIR")).Value | Should -Be ($mockInstalVal.TempDir + "\Program Files\VenvIt")
            Test-Path env:VIRTUAL_ENV | Should -Be $false
        }

        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}

