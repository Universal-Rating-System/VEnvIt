# Uninstall.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
    }

    BeforeEach {
        # . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }

    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\Uninstall.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When BackupDir parameter is passed and Help is not passed" {
        BeforeAll {
        }
        BeforeEach {
            # . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
            Mock "Invoke-Uninstall" -MockWith { Write-Host "Mock: Invoke-Uninstall called with BackupDir = $BackupDir" }
        }
        It "Should call Invoke-BackupDir function with BackupDir" {
            & $PSScriptRoot\..\src\Uninstall.ps1 "c:\VEnvIt Backup"
            Assert-MockCalled -CommandName "Invoke-Uninstall" -Exactly 1
        }
    }

    Context "When BackupDir is an empty string and Help is not passed" {
        BeforeAll {
            # . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
        }
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\Uninstall.ps1 -BackupDir $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        BeforeAll {
            # . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
        }
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\Uninstall.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function Testing" {
    BeforeAll {
        . $PSScriptRoot\..\src\vi.ps1 -Pester
        $OriginalValues = Backup-SessionEnvironmentVariables
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }

    Context "Invoke-VirtualEnvironment" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
        }

        Context "With virtual environment activated" {
            It "Should invoke the virtual environment" {
                Mock Invoke-Script { return "Mock: Deactivated current VEnv"
                } -ParameterFilter { $Script -eq "deactivate" }
                Mock Invoke-Script { return "Mock: Activated VEnv"
                } -ParameterFilter { $Script -eq ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1") }
                Mock Invoke-Script { return "Mock: Default secrets.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_SECRETS_DEFAULT_DIR\secrets.ps1") }
                Mock Invoke-Script { return "Mock: User secrets.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_SECRETS_USER_DIR\secrets.ps1") }
                Mock Invoke-Script { return "Mock: Default EnvVar.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar")) }
                Mock Invoke-Script { return "Mock: User EnvVar.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar")) }
                Mock Invoke-Script { return "Mock: Default CustomSetup.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup")) }
                Mock Invoke-Script { return "Mock: User CustomSetup.ps1"
                } -ParameterFilter { $Script -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup")) }

                Invoke-VirtualEnvironment -ProjectName "MyProject"

                Assert-MockCalled -CommandName "Invoke-Script" -ParameterFilter { $Script -eq "deactivate" }
                # (Test-Path $tempDir) | Should -Be $true
            }
        }
        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Show-Help" {
        # TODO
        # Test to be implemented
    }
    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalValues
    }
}

