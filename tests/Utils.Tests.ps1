# Utils.Test.ps1
BeforeAll {
    if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
    Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

    if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
    Import-Module $PSScriptRoot\..\src\Utils.psm1

    if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
    Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
}

Describe "Function Tests" {
    BeforeAll {
        # if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
        # Import-Module $PSScriptRoot\Publish-TestResources.psm1

        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
}

    Context "Backup-ArchiveOldVersion" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            # $OriginalValues = Backup-SessionEnvironmentVariables
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        }

        It "Should archive version 0.0.0" {
            $mockInstalVal = Set-TestSetup_0_0_0
            $installationDir = "$env:SCRIPTS_DIR"
            $archive = Backup-ArchiveOldVersion -InstallationDir $InstallationDir -TimeStamp $timeStamp

            (Test-Path -Path $archive) | Should -Be $true
        }

        It "Should archive version 6.0.0" {
            $mockInstalVal = Set-TestSetup_6_0_0
            $installationDir = "$env:VENVIT_DIR"
            $archive = Backup-ArchiveOldVersion -InstallationDir $InstallationDir -TimeStamp $timeStamp

            (Test-Path -Path $archive) | Should -Be $true
        }

        It "Should archive version 7.0.0" {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            $mockInstalVal = Set-TestSetup_7_0_0
            $installationDir = "$env:VENVIT_DIR"
            # $FileList = $env:VENVIT_DIR, $env:VENV_CONFIG_DEFAULT_DIR, $env:VENV_CONFIG_USER_DIR, $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR
            $archive = Backup-ArchiveOldVersion -InstallationDir $installationDir -TimeStamp $timeStamp

            (Test-Path -Path $archive) | Should -Be $true
        }

        It "Should archive version 7.0.0 to BackupDir" {
            $mockInstalVal = Set-TestSetup_7_0_0
            $installationDir = "$env:VENVIT_DIR"
            $backupDir = (Join-Path -Path $mockInstalVal.TempDir -ChildPath "VEnvIt Backup")
            # $FileList = $env:VENVIT_DIR, $env:VENV_CONFIG_DEFAULT_DIR, $env:VENV_CONFIG_USER_DIR, $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR
            $archive = Backup-ArchiveOldVersion -InstallationDir $InstallationDir -TimeStamp $timeStamp -DestinationDir $backupDir

            (Test-Path -Path $archive) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        #     Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        #     Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
        }
    }

    Context "Backup-ScriptToArchiveIfExists" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Backup-ScriptToArchiveIfExists" {}
        AfterAll {}
    }

    Context "Copy-Deep" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            $originalObject = [PSCustomObject]@{ Name = "Alice"; Details = @{ Age = 30; City = "New York" } }
        }

        It "Create deep copy" {
            $copyObject = Copy-Deep $originalObject
            $copyObject.Details["City"] = "Los Angeles"

            $($originalObject.Details["City"]) | Should -Be "New York"
            $($copyObject.Details["City"]) | Should -Be "Los Angeles"
        }
    }

    Context "Confirm-SystemEnvironmentVariablesExist" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            # $OriginalValues = Backup-SessionEnvironmentVariables

            $envVarSet = @{
                TEST_ONE = @{DefVal = "Test one"; IsDir = $true; SystemMandatory = $true }
                TEST_TWO = @{DefVal = "Test two"; IsDir = $true; SystemMandatory = $false }
            }
            Publish-EnvironmentVariables -EnvVarSet $envVarSet
        }

        It "Should all exist" {
            $result = Confirm-SystemEnvironmentVariablesExist $envVarSet
            $result | Should -Be @()
        }

        It "Non-mandatory is null" {
            $env:TEST_TWO = $null
            $result = Confirm-SystemEnvironmentVariablesExist $envVarSet
            $result | Should -Be @()
        }

        It "Should not find TEST_ONE" {
            $env:TEST_ONE = $null
            $result = Confirm-SystemEnvironmentVariablesExist $envVarSet
            $result | Should -Be @("TEST_ONE")
        }

        AfterEach {
            Unpublish-EnvironmentVariables $envVarSet
            # Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "Get-ConfigFileName" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Should return secrets filename" {
            Get-ConfigFileName -ProjectName "MyProject" -Postfix "Postfix" | Should -Be "VEnvMyProjectPostfix.ps1"
        }
        AfterAll {}
    }

    Context "Get-ManifestFileName" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Should return manifest filename" {
            Get-ManifestFileName | Should -Be "Manifest.psd1"
        }
        AfterAll {}
    }

    Context "Get-SecretsFileName" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Should return secrets filename" {
            Get-SecretsFileName | Should -Be "Secrets.ps1"
        }
        AfterAll {}
    }

    Context "Get-Version" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
            # if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
            # Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            # if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            # Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
        }

        BeforeEach {
            # if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
            # Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
            # $OriginalValues = Backup-SessionEnvironmentVariables
        }

        It "Should get 0.0.0" {
            $mockInstalVal = Set-TestSetup_0_0_0
            $Version = Get-Version -SourceDir $env:SCRIPTS_DIR
            $Version | Should -Be "0.0.0"
            # Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }

        It "Should get 6.0.0" {
            if (Test-Path "env:SCRIPTS_DIR") {
                Remove-Item -Path "Env:SCRIPTS_DIR"
            }
            $mockInstalVal = Set-TestSetup_6_0_0
            $Version = Get-Version -SourceDir $env:VENVIT_DIR
            $Version | Should -Be "6.0.0"
            # Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }

        It "Should get 7.0.0" {
            if (Test-Path "env:SCRIPTS_DIR") {
                Remove-Item -Path "Env:SCRIPTS_DIR"
            }
            $mockInstalVal = Set-TestSetup_7_0_0
            $Version = Get-Version -SourceDir $env:VENVIT_DIR
            $Version | Should -Be "7.0.0"
            # Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
            # Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "New-CustomTempDir Test" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Temporary dir with prefix" {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            Test-Path -Path $tempDir | Should -Be $true
        }
        AfterEach {
            # Cleanup: Remove the created directory if it exists
            if (Test-Path -Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    }

    Context "Get-ReadAndSetEnvironmentVariables" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1
            $envVarTestSet = @{
                TEST_ONE = @{DefVal = "Test one"; IsDir = $true; SystemMandatory = $true }
                TEST_TWO = @{DefVal = "Test two"; IsDir = $true; SystemMandatory = $true }
                TEST_THREE = @{DefVal = "Default value"; IsDir = $true; SystemMandatory = $true }
            }

            Mock -ModuleName Utils Read-Host { return "Mock: Has existing value" } -ParameterFilter { $Prompt -eq "TEST_ONE (Has existing value)" }
            Mock -ModuleName Utils Read-Host { return "Mock: Read from prompt" } -ParameterFilter { $Prompt -eq "TEST_TWO (Test two)" }
            Mock -ModuleName Utils Read-Host { return "" } -ParameterFilter { $Prompt -eq "TEST_THREE (Default value)" }
        }
        It "Should read existing value" {
            [System.Environment]::SetEnvironmentVariable("TEST_ONE", "Has existing value", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_TWO", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_THREE", $null, [System.EnvironmentVariableTarget]::Machine)
            Get-ReadAndSetEnvironmentVariables -EnvVarSet $envVarTestSet

            [System.Environment]::GetEnvironmentVariable("TEST_ONE", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Mock: Has existing value"
            $env:TEST_ONE | Should -Be "Mock: Has existing value"
            [System.Environment]::GetEnvironmentVariable("TEST_TWO", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Mock: Read from prompt"
            $env:TEST_TWO | Should -Be "Mock: Read from prompt"
            [System.Environment]::GetEnvironmentVariable("TEST_THREE", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Default value"
            $env:TEST_THREE | Should -Be "Default value"
        }
        AfterAll {
            [System.Environment]::SetEnvironmentVariable("TEST_ONE", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_TWO", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_THREE", $null, [System.EnvironmentVariableTarget]::Machine)
            $env:TEST_ONE = $null
            $env:TEST_TWO = $null
            $env:TEST_THREE = $null
        }
    }

    Context "Show-EnvironmentVariables" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Show-EnvironmentVariables" {}
        AfterAll {}
    }

    Context "Read-YesOrNo" {
        BeforeAll {
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Input is Y" {
            Mock -ModuleName "Utils" Read-Host {
                return "Y"
            }

            $Result = Read-YesOrNo "Continue"
            $Result  | Should -Be $true
        }
        It "Input is y" {
            Mock -ModuleName "Utils" Read-Host {
                return "y"
            }

            $Result = Read-YesOrNo "Continue"
            $Result  | Should -Be $true
        }
        It "Input is N" {
            Mock -ModuleName "Utils" Read-Host {
                return "N"
            }

            $Result = Read-YesOrNo "Continue"
            $Result  | Should -Be $false
        }
        It "Input is n" {
            Mock -ModuleName "Utils" Read-Host {
                return "n"
            }

            $Result = Read-YesOrNo "Continue"
            $Result  | Should -Be $false
        }
        It "Input is empty" {
            Mock -ModuleName "Utils" Read-Host {
                return ""
            }

            $Result = Read-YesOrNo "Continue"
            $Result  | Should -Be $true
        }
        It "Input is invalid" {
            Mock -ModuleName "Utils" Read-Host {
                return "x"
            } -ParameterFilter { $Prompt -eq "d as response (Y/n)" }
            Mock -ModuleName "Utils" Read-Host {
                return "Y"
            } -ParameterFilter { $Prompt -eq "Only Y or N (Y/n)" }

            $Result = Read-YesOrNo "d as response"
            $Result  | Should -Be $true
        }
    }

    Context "Publish-EnvironmentVariables" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            # $originalSessionValues = Backup-SessionEnvironmentVariables
            # $originalSystemValues = Backup-SystemEnvironmentVariables

            $testEnvVarSet = @{
                TEST_VAL = @{DefVal = "Test value"; IsDir = $false }
                TEST_DIR = @{DefVal = "$env:TEMP\Test_Dir"; IsDir = $True }
            }
        }
        It "Should set the system and environment variables" {
            Publish-EnvironmentVariables -EnvVarSet $testEnvVarSet

            foreach ($envVar in $testEnvVarSet.Keys) {
                [System.Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine) | Should -Be $testEnvVarSet[$envVar]["DefVal"]
                (Get-Item -Path env:$envVar).Value | Should -Be $testEnvVarSet[$envVar]["DefVal"]
            }
        }

        AfterEach {
            Unpublish-EnvironmentVariables -EnvVarSet $testEnvVarSet
        }
        AfterAll {
            # Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            # Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
        }
    }

    Context "Unpublish-EnvironmentVariables" {
        BeforeAll {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            $originalSessionValues = Backup-SessionEnvironmentVariables
            $originalSystemValues = Backup-SystemEnvironmentVariables

            $testEnvVarSet = @{
                TEST_VAL = @{DefVal = "Test value"; IsDir = $false }
                TEST_DIR = @{DefVal = "$env:TEMP\Test_Dir"; IsDir = $True }
            }
        }
        BeforeEach {
            Publish-EnvironmentVariables -EnvVarSet $testEnvVarSet
        }
        It "Should remove the system and environment variables" {
            Unpublish-EnvironmentVariables -EnvVarSet $testEnvVarSet

            foreach ($envVar in $testEnvVarSet.Keys) {
                [System.Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine) | Should -Be $null
                (Get-Item -Path env:$envVar -ErrorAction SilentlyContinue).Value | Should -Be $null
            }
            AfterEach {
            }
        }
        AfterAll {
            # Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            # Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
        }
    }
    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}
