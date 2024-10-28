# Pester test for vn.Tests.ps1

if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vi.ps1 -Pester
    }

    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }

    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\vi.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-VirtualEnvironment" -MockWith { Write-Host "Mock: Invoke-VirtualEnvironment called" }
            Mock -CommandName "Show-EnvironmentVariables" -MockWith { Write-Host "Mock: Show-EnvironmentVariables called" }
        }
        It "Should call Invoke-VirtualEnvironment function with ProjectName" {
            & $PSScriptRoot\..\src\vi.ps1 "Tes01"
            # Assert-MockCalled -CommandName "Invoke-MyScript" -Exactly 1 -ParameterFilter { $Var01 -eq 'TestValue' }
            Assert-MockCalled -CommandName "Invoke-VirtualEnvironment" -Exactly 1
            Assert-MockCalled -CommandName "Show-EnvironmentVariables" -Exactly 1
        }
    }

    Context "When Var01 is an empty string and Help is not passed" {
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\vi.ps1 -ProjectName $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\vi.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function testing" {
    BeforeAll {
        . $PSScriptRoot\..\src\vi.ps1 -Pester
        $OriginalValues = Set-BackupEnvironmentVariables
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }

    Context "Invoke-VirtualEnvironment" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
        }

        Context "With virtual environment activated" {
            It "Should invoke the virtual environment" {
                Mock Invoke-Script { return "Mock: Deactivated current VEnv"
                } -ParameterFilter { $Script -eq "deactivate" }
                Mock Invoke-Script { return "Mock: Activated VEnv"
                } -ParameterFilter { $Script -eq ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1") }
                Mock Invoke-Script { return "Mock: Default dev_env_var.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_SECRETS_DEFAULT_DIR\dev_env_var.ps1") }
                Mock Invoke-Script { return "Mock: User dev_env_var.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_SECRETS_USER_DIR\dev_env_var.ps1") }
                Mock Invoke-Script { return "Mock: Default EnvVar.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Prefix "EnvVar")) }
                Mock Invoke-Script { return "Mock: User EnvVar.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Prefix "EnvVar")) }
                Mock Invoke-Script { return "Mock: Default CustomSetup.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Prefix "CustomSetup")) }
                Mock Invoke-Script { return "Mock: User CustomSetup.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Prefix "CustomSetup")) }

                Invoke-VirtualEnvironment -ProjectName "MyProject"

                Assert-MockCalled -CommandName "Invoke-Script" -ParameterFilter { $Script -eq "deactivate" }
                # (Test-Path $tempDir) | Should -Be $true
            }
        }
        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Show-Help" {
        # TODO
        # Test to be implemented
    }
    AfterAll {
        Get-BackedupEnvironmentVariables -OriginalValues $originalValues
    }
}

