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

            $mockInstalVal = Set-TestSetup_7_0_0
            $installationDir = "$env:VENVIT_DIR"
            $archive = Backup-ArchiveOldVersion -InstallationDir $installationDir -TimeStamp $timeStamp

            (Test-Path -Path $archive) | Should -Be $true
        }

        It "Should archive version 7.0.0 to BackupDir" {
            $mockInstalVal = Set-TestSetup_7_0_0
            $installationDir = "$env:VENVIT_DIR"
            $backupDir = (Join-Path -Path $mockInstalVal.TempDir -ChildPath "VEnvIt Backup")
            $archive = Backup-ArchiveOldVersion -InstallationDir $InstallationDir -TimeStamp $timeStamp -DestinationDir $backupDir

            (Test-Path -Path $archive) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Backup-ScriptToArchiveIfExists" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Backup-ScriptToArchiveIfExists" {}
        AfterAll {}
    }

    Context "Clear-NonSystemMandatoryEnvironmentVariables" {
        BeforeEach {

            $envVarSet = @{
                TEST_ONE = @{DefVal = "Test one"; IsDir = $true; SystemMandatory = $true }
                TEST_TWO = @{DefVal = "Test two"; IsDir = $true; SystemMandatory = $false }
            }
            Publish-EnvironmentVariables -EnvVarSet $envVarSet
        }

        It "Should clear non mandatory variables" {
            (Get-Item -Path ("env:TEST_ONE")).Value | Should -Be "Test one"
            (Get-Item -Path ("env:TEST_TWO")).Value | Should -Be "Test two"
            Clear-NonSystemMandatoryEnvironmentVariables $envVarSet
            (Get-Item -Path ("env:TEST_ONE")).Value | Should -Be "Test one"
            Test-Path env:TEST_TWO | Should -Be $false
        }

        AfterEach {
            Unpublish-EnvironmentVariables $envVarSet
        }
    }

    Context "Confirm-SystemEnvironmentVariablesExist" {
        BeforeEach {

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
        }
    }

    Context "Copy-Deep" {
        BeforeEach {
            $originalObject = [PSCustomObject]@{ Name = "Alice"; Details = @{ Age = 30; City = "New York" } }
        }

        It "Create deep copy" {
            $copyObject = Copy-Deep $originalObject
            $copyObject.Details["City"] = "Los Angeles"

            $($originalObject.Details["City"]) | Should -Be "New York"
            $($copyObject.Details["City"]) | Should -Be "Los Angeles"
        }
    }

    Context "Get-ConfigFileName" {
        BeforeAll {
        }
        It "Should return secrets filename" {
            Get-ConfigFileName -ProjectName "MyProject" -Postfix "Postfix" | Should -Be "VEnvMyProjectPostfix.ps1"
        }
        AfterAll {}
    }

    Context "Get-ManifestFileName" {
        BeforeAll {
        }
        It "Should return manifest filename" {
            Get-ManifestFileName | Should -Be "Manifest.psd1"
        }
        AfterAll {}
    }

    Context "Get-ReadAndSetEnvironmentVariables" {
        BeforeAll {
            $envVarTestSet = @{
                TEST_ONE   = @{DefVal = "Test one"; IsDir = $true; SystemMandatory = $true; ReadOrder = 2; Prefix = $false }
                TEST_TWO   = @{DefVal = "Test two"; IsDir = $true; SystemMandatory = $true; ReadOrder = 1; Prefix = $false }
                TEST_THREE = @{DefVal = "Default value"; IsDir = $true; SystemMandatory = $true; ReadOrder = 3; Prefix = "TEST_TWO" }
                TEST_FOUR  = @{DefVal = "Test Four"; IsDir = $false; SystemMandatory = $False; ReadOrder = 4; Prefix = $false }
            }

            Mock -ModuleName Utils Read-Host { return "Mock: Has existing value" } -ParameterFilter { $Prompt -eq "TEST_ONE (Has existing value)" }
            Mock -ModuleName Utils Read-Host { return "Mock\Read\from\prompt" } -ParameterFilter { $Prompt -eq "TEST_TWO (Test two)" }
            Mock -ModuleName Utils Read-Host { return "" } -ParameterFilter { $Prompt -eq "TEST_THREE (Mock\Read\from\prompt\Default value)" }
        }
        It "Should read 3 different values" {
            [System.Environment]::SetEnvironmentVariable("TEST_ONE", "Has existing value", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_TWO", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_THREE", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_FOUR", $null, [System.EnvironmentVariableTarget]::Machine)
            Get-ReadAndSetEnvironmentVariables -EnvVarSet $envVarTestSet

            [System.Environment]::GetEnvironmentVariable("TEST_ONE", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Mock: Has existing value"
            $env:TEST_ONE | Should -Be "Mock: Has existing value"
            [System.Environment]::GetEnvironmentVariable("TEST_TWO", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Mock\Read\from\prompt"
            $env:TEST_TWO | Should -Be "Mock\Read\from\prompt"
            [System.Environment]::GetEnvironmentVariable("TEST_THREE", [System.EnvironmentVariableTarget]::Machine) | Should -Be "Mock\Read\from\prompt\Default value"
            $env:TEST_THREE | Should -Be "Mock\Read\from\prompt\Default value"
            [System.Environment]::GetEnvironmentVariable("TEST_FOUR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $null
            $env:TEST_FOUR | Should -Be $null
        }
        AfterAll {
            [System.Environment]::SetEnvironmentVariable("TEST_ONE", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_TWO", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_THREE", $null, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("TEST_FOUR", $null, [System.EnvironmentVariableTarget]::Machine)
            $env:TEST_ONE = $null
            $env:TEST_TWO = $null
            $env:TEST_THREE = $null
        }
    }

    Context "Get-SecretsFileName" {
        BeforeAll {
        }
        It "Should return secrets filename" {
            Get-SecretsFileName | Should -Be "Secrets.ps1"
        }
        AfterAll {}
    }

    Context "Get-Version" {
        BeforeAll {
        }

        BeforeEach {
        }

        It "Should get 0.0.0" {
            $mockInstalVal = Set-TestSetup_0_0_0
            $Version = Get-Version -SourceDir $env:SCRIPTS_DIR
            $Version | Should -Be "0.0.0"
        }

        It "Should get 6.0.0" {
            if (Test-Path "env:SCRIPTS_DIR") {
                Remove-Item -Path "Env:SCRIPTS_DIR"
            }
            $mockInstalVal = Set-TestSetup_6_0_0
            $Version = Get-Version -SourceDir $env:VENVIT_DIR
            $Version | Should -Be "6.0.0"
        }

        It "Should get 7.0.0" {
            if (Test-Path "env:SCRIPTS_DIR") {
                Remove-Item -Path "Env:SCRIPTS_DIR"
            }
            $mockInstalVal = Set-TestSetup_7_0_0
            $Version = Get-Version -SourceDir $env:VENVIT_DIR
            $Version | Should -Be "7.0.0"
        }
        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Invoke-Script" {
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $content = @"
Write-Host "This is a test."
"@
            $destinationPath = "$tempDir\TestScript.ps1"
            Set-Content -Path "$destinationPath" -Value $content
        }

        It "Script without arguments" {
            (Invoke-Script -ScriptPath $destinationPath) | Should -Be $true
        }

        It "With arguments" {
            (Invoke-Script -ScriptPath $destinationPath -Arguments "Some argument") | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $tempDir -Recurse -Force
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
            $testEnvVarSet = @{
                TEST_VAL = @{DefVal = "Test value"; IsDir = $false; SystemMandatory = $true }
                TEST_DIR = @{DefVal = "$env:TEMP\Test_Dir"; IsDir = $True; SystemMandatory = $true }
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
        }
    }

    Context "Unpublish-EnvironmentVariables" {
        BeforeAll {
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
        AfterEach {
            Unpublish-EnvironmentVariables -EnvVarSet $testEnvVarSet
        }
    }
    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}
