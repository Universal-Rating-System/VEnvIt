# vr.Tests.ps1

if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

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
            Mock -CommandName "Invoke-CreateNewVirtualEnvironment" -MockWith { Write-Host "Mock: Invoke-Vn called" }
        }
        It "Should call Invoke-CreateNewVirtualEnvironment function with ProjectName" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName "Tes01"
            Assert-MockCalled -CommandName "Invoke-CreateNewVirtualEnvironment" -Exactly 1
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

Describe "Function Testing" {
    BeforeAll {
        . $PSScriptRoot\..\src\vr.ps1 -Pester
        $OriginalValues = Backup-SessionEnvironmentVariables
    }

    Context "New-ProjectArchive" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
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

    Context "Unregister-VirtualEnvironmen" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            Mock Invoke-Script { return "Mock: Deactivated current VEnv"
            } -ParameterFilter { $Script -eq "deactivate" }
        }

        It "Should remove the virtual environment" {
            Unregister-VirtualEnvironment -ProjectName $mockInstalVal.ProjectName

            (Test-Path -Path "${env:VENV_BASE_DIR}\${ProjectName}_env") | Should -Be $false
        }

        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalValues
    }
}

