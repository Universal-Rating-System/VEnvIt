# Uninstall.Tests.ps1
BeforeAll {
    # if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
    # Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

    if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
    Import-Module $PSScriptRoot\..\src\Utils.psm1
}

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
    }

    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { return "Mock: Show-Help called" }
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
            Mock "Invoke-Uninstall" -MockWith { return "Mock: Invoke-Uninstall called with BackupDir = $BackupDir" }
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

Describe "Function Tests" {
    BeforeAll {
        . $PSScriptRoot\..\src\Uninstall.ps1 -Pester
        if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
        Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module $PSScriptRoot\..\src\Utils.psm1

        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables

    }

    Context "Backup-EnvironmentVariables" {
        BeforeEach {
            $mockInstalVal = Set-TestSetup_7_0_0
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        }

        It "Should backup environment variables to file" {
            $BackupFileName = "VEnvIt_7.0.0" + "_" + "$TimeStamp.zip"
            $BackupDir = Join-Path -Path $mockInstalVal.TempDir -ChildPath "VEnvIt Backup"
            $BackupPath = Join-Path -Path $BackupDir -ChildPath $BackupFileName

            if ( -not( Test-Path $BackupDir)) {
                New-Item -Path $BackupDir -ItemType Directory -Force
            }
            Backup-EnvironmentVariables -DestinationPath $BackupPath

            Test-Path $BackupPath | Should -Be $true
        }

        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Remove-InstallationFiles" {
        BeforeEach {
            $mockInstalVal = Set-TestSetup_7_0_0
        }

        It "Should remove all source files" {
            Remove-InstallationFiles -InstallationDir $env:VENVIT_DIR

            $fileList = $env:VENVIT_DIR, $env:VENV_CONFIG_DEFAULT_DIR, $env:VENV_CONFIG_USER_DIR, $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR, $env:VENV_BASE_DIR
            foreach ( $dir in $fileList) {
                Test-Path $dir | Should -Be $false
            }
        }

        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Invoke-Uninstall" {
        BeforeEach {
        }

        It "Should archive v7.0.0. to default" {
            $mockInstalVal = Set-TestSetup_7_0_0
            $BackupDir = Join-Path -Path $mockInstalVal.TempDir -ChildPath "VEnvIt Backup"
            $BackupPath = Invoke-Uninstall -BackupDir $BackupDir

            Test-Path $BackupPath | Should -Be $true

            Unpublish-EnvironmentVariables -EnvVarSet $defEnvVarSet_7_0_0
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }

        It "Installation does not exist" {
            $BackupPath = Invoke-Uninstall -BackupDir $null

            $BackupPath | Should -Be $false
        }

        AfterEach {
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

