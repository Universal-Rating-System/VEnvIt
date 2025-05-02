# Upgrade.Tests.ps1
BeforeAll {

    if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
    Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1

    if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
    Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

}

Describe "Upgrade.Tests.ps1: Function Tests" {
    BeforeAll {
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module $PSScriptRoot\..\src\Utils.psm1

        if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
        Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1

        if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
        Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1

        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
    }

    Context "Get-ManifestFileName" {
        BeforeEach {
            $OriginalValues = Backup-SessionEnvironmentVariables
        }

        It "TODO Get-ManifestFileName" {
        }
        AfterEach {
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "Invoke-PrepForUpgrade_6_0_0" {
        BeforeAll {
            # This test must be run with administrator rights.
            if (-not (Test-Admin)) { Throw "Tests must be run as an Administrator. Aborting..." }
        }

        BeforeEach {
            $mockInstalVal = Set-TestSetup_0_0_0
            [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $env:SECRETS_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $env:SCRIPTS_DIR, [System.EnvironmentVariableTarget]::Machine)
        }

        It "Should prepare for 6.0.0" {
            Invoke-PrepForUpgrade_6_0_0
            $rte_environment = [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
            $secrets_dir = [System.Environment]::GetEnvironmentVariable("SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine)
            $scripts_dir = [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine)
            $rte_environment | Should -Be $null
            $secrets_dir | Should -Be $null
            $scripts_dir | Should -Be $null
        }

        AfterEach {
            Remove-EnvVarIfExists -EnvVarName "RTE_ENVIRONMENT"
            Remove-EnvVarIfExists -EnvVarName "SECRETS_DIR"
            Remove-EnvVarIfExists -EnvVarName "SCRIPTS_DIR"
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }

        AfterAll {
        }
    }

    Context "Invoke-PrepForUpgrade_7_0_0" {
        BeforeAll {
            # This test must be run with administrator rights.
            if (-not (Test-Admin)) {
                Throw "Tests must be run as an Administrator. Aborting..."
            }
        }

        BeforeEach {
            $mockInstalVal = Set-TestSetup_6_0_0
        }

        It "Should prepare for 7.0.0" {
            Invoke-PrepForUpgrade_7_0_0

            $config_dir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DIR", [System.EnvironmentVariableTarget]::Machine)
            $config_dir | Should -Be $null
            $secrets_dir = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine)
            $secrets_dir | Should -Be $null

            $config_user_dir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $config_user_dir | Should -Be $env:VENV_CONFIG_USER_DIR
            $secrets_user_dir = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $secrets_user_dir | Should -Be $env:VENV_SECRETS_USER_DIR
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }

        AfterAll {

        }
    }

    Context "Remove-EnvVarIfExists" {
        BeforeEach {
            $OriginalValues = Backup-SessionEnvironmentVariables
            if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
            Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1

            $origVENV_TEST = $env:VENV_TEST
            $env:VENV_TEST = "testVENV_TEST"
            [System.Environment]::SetEnvironmentVariable("VENV_TEST", $env:VENV_TEST, [System.EnvironmentVariableTarget]::Machine)

        }

        It "Values exist" {
            Remove-EnvVarIfExists -EnvVarName "VENV_TEST"

            [System.Environment]::GetEnvironmentVariable("VENV_TEST", [System.EnvironmentVariableTarget]::Machine) | Should -Be $null
            $env:VENV_TEST | Should -Be $null
        }

        AfterEach {
            [System.Environment]::SetEnvironmentVariable("VENV_TEST", $origVENV_TEST, [System.EnvironmentVariableTarget]::Machine)
            $env:VENV_TEST = $origVENV_TEST
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "Update-PackagePrep" {
        BeforeAll {
            if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
        }
        BeforeEach {
            $OriginalValues = Backup-SessionEnvironmentVariables
            if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
            Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1

            $TempDir = New-CustomTempDir -Prefix "VenvIt"
            $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $TempDir -ChildPath "TempUpgradeDir")
        }

        It "Should bypass for new installation" {
            $mockInstalVal = Set-TestSetup_New
            $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -DestinationPath $UpgradeManifestPath -data $ManifestData700
            $CurrentVersion = Update-PackagePrep -UpgradeScriptDir $UpgradeScriptDir

            $CurrentVersion | Should -Be $null
            # Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }

        It "Should apply 6.0.0 and 7.0.0 for 0.0.0 installation" {
            $mockInstalVal = Set-TestSetup_0_0_0
            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-PrepForUpgrade_6_0_0 {
                return $true
            }
            # Mock -CommandName Invoke-PrepForUpgrade_6_0_0 { return $true }
            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-PrepForUpgrade_7_0_0 {
                return $true
            }
            # Mock -CommandName Invoke-PrepForUpgrade_7_0_0
            $CurrentManifestPath = Join-Path -Path $env:SCRIPTS_DIR -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -DestinationPath $CurrentManifestPath -Data $ManifestData000
            $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -DestinationPath $UpgradeManifestPath -data $ManifestData700
            $CurrentVersion = Update-PackagePrep -UpgradeScriptDir $UpgradeScriptDir

            # Assert that the correct upgrade functions were called in order
            $CurrentVersion | Should -Be "0.0.0"
            Assert-MockCalled -Scope It -ModuleName Conclude-UpgradePrep -CommandName Invoke-PrepForUpgrade_6_0_0 -Times 1 -Exactly
            Assert-MockCalled -Scope It -ModuleName Conclude-UpgradePrep -CommandName Invoke-PrepForUpgrade_7_0_0 -Times 1 -Exactly
        }
        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}
