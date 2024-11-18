# vi.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vi.ps1 -Pester
    }

    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { return "Mock: Show-Help called" }
    }

    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\vi.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-VirtualEnvironment" -MockWith { return "Mock: Invoke-VirtualEnvironment called" }
            Mock -CommandName "Show-EnvironmentVariables" -MockWith { return "Mock: Show-EnvironmentVariables called" }
        }
        It "Should call Invoke-VirtualEnvironment function with ProjectName" {
            & $PSScriptRoot\..\src\vi.ps1 "Tes01"
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

Describe "Function Tests" {
    BeforeAll {
        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
    }

    Context "Invoke-VirtualEnvironment" {
        BeforeEach {
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }

        Context "With virtual environment activated" {
            BeforeAll {
                . $PSScriptRoot\..\src\vi.ps1 -Pester

                if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
                Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

                $mockInstalVal = Set-TestSetup_7_0_0
                $timeStamp = Get-Date -Format "yyyyMMddHHmm"
                # New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
            }
            It "Should invoke the virtual environment" {
                # . $PSScriptRoot\..\src\vi.ps1 -Pester

                Mock Invoke-Script { return "Mock: Deactivated current VEnv"
                } -ParameterFilter { $ScriptPath -eq "deactivate" }
                Mock Invoke-Script { return "Mock: Activated VEnv"
                } -ParameterFilter { $ScriptPath -eq ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1") }
                Mock Invoke-Script { return "Mock: Default secrets.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_SECRETS_DEFAULT_DIR\secrets.ps1") }
                Mock Invoke-Script { return "Mock: User secrets.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_SECRETS_USER_DIR\secrets.ps1") }
                Mock Invoke-Script { return "Mock: Default EnvVar.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar")) }
                Mock Invoke-Script { return "Mock: User EnvVar.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "EnvVar")) }
                Mock Invoke-Script { return "Mock: Default CustomSetup.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_CONFIG_DEFAULT_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup")) }
                Mock Invoke-Script { return "Mock: User CustomSetup.ps1"
                } -ParameterFilter { $ScriptPath -eq ("$env:VENV_CONFIG_USER_DIR\" + (Get-ConfigFileName -ProjectName $ProjectName -Postfix "CustomSetup")) }

                Invoke-VirtualEnvironment -ProjectName "MyProject"

                Assert-MockCalled -CommandName "Invoke-Script" -ParameterFilter { $ScriptPath -eq "deactivate" }
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

