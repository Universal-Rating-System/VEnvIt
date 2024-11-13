# Uninstall.Tests.ps1
if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
# if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
# Import-Module $PSScriptRoot\..\src\Utils.psm1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
    }

    BeforeEach {
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
            Mock "Invoke-Uninstall" -MockWith { Write-Host "Mock: Invoke-Uninstall called with BackupDir = $BackupDir" }
        }
        It "Should call Invoke-BackupDir function with BackupDir" {
            & $PSScriptRoot\..\src\Uninstall.ps1 "c:\VEnvIt Backup"
            Assert-MockCalled -CommandName "Invoke-Uninstall" -Exactly 1
        }
    }

    Context "When BackupDir is an empty string and Help is not passed" {
        BeforeAll {
        }
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\Uninstall.ps1 -BackupDir $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        BeforeAll {
        }
        It "Should call Show-Help function" {
            & $PSScriptRoot\..\src\Uninstall.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function Testing" {
    BeforeAll {
        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
        . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
    }

    Context "Uninstall" {
        BeforeEach {
            $mockInstalVal = Set-TestSetup_7_0_0
            # $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        }

        It "Should archive v7.0.0. to default" {
            Invoke-Uninstall -BackupDir (Join-Path -Path $mockInstalVal.TempDir -ChildPath "VEnvIt Backup")
        }

        AfterEach {
            Unpublish-EnvironmentVariables -EnvVarSet $defEnvVarSet_7_0_0
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Show-Help" {
        BeforeEach {
        }

        It "TODO Should Show-Help" {
        }

        AfterEach {
        }
    }

    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}

