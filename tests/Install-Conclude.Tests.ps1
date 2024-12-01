# Install-Conclude.Tests.ps1
BeforeAll {
    if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
    Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

    if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
    Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1
}

Describe "Function Tests" {
    BeforeAll {
        # This test must be run with administrator rights.
        if (-not (Test-Admin)) {
            Throw "Tests must be run as an Administrator. Aborting..."
        }
    }

    Context "Clear-InstallationFiles" {
        BeforeAll {
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }

        BeforeEach {
            $OriginalValues = Backup-SessionEnvironmentVariables
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $upgradeScriptDir = "$tempDir\UpgradeScript"
            New-Item -ItemType Directory -Path $upgradeScriptDir | Out-Null
        }

        It "Ensure installation files removed" {
            Clear-InstallationFiles -upgradeScriptDir $upgradeScriptDir
            (Test-Path -Path $upgradeScriptDir) | Should -Be $false
        }

        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "Invoke-ConcludeInstall" {
        BeforeEach {
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1

            $upgradeDetail = Set-TestSetup_InstallationFiles
            $TempDir = Join-Path -Path $env:TEMP -ChildPath ($Prefix + "_" + [Guid]::NewGuid().ToString())
            Unpublish-EnvironmentVariables -EnvVarSet $defEnvVarSet_7_0_0

            Mock Read-Host { return "" } -ParameterFilter { $Prompt -eq "VENVIT_DIR (C:\Program Files\VenvIt)" }
            Mock -ModuleName Install-Conclude Get-ReadAndSetEnvironmentVariables {
                $env:VENVIT_DIR = "$TempDir\VEnvIt"
                [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $env:VENVIT_DIR,[System.EnvironmentVariableTarget]::Machine)
                $env:PROJECTS_BASE_DIR = "$TempDir\Projects"
                [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $env:PROJECTS_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_BASE_DIR = "$TempDir\VEnv"
                [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $env:VENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_CONFIG_DEFAULT_DIR = "$env:VENVIT_DIR\Config"
                [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $env:VENV_CONFIG_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_CONFIG_USER_DIR = "$TempDir\User\VEnvIt\Config"
                [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $env:VENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_ENVIRONMENT = "loc_dev"
                [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_PYTHON_BASE_DIR = "$TempDir\Python"
                [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $env:VENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_SECRETS_DEFAULT_DIR = "$env:VENVIT_DIR\Secrets"
                [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $env:VENV_SECRETS_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
                $env:VENV_SECRETS_USER_DIR = "$TempDir\User\VEnvIt\Secrets"
                [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $env:VENV_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
            }
        }
        It "Should do new installation" {
            Invoke-ConcludeInstall -UpgradeScriptDir $upgradeDetail.Dir

            Test-Path -Path $env:VENVIT_DIR | Should -Be $true
            Get-Item -Path $env:VENVIT_DIR | Should -Be "$TempDir\VEnvIt"
            [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be "$TempDir\VEnvIt"

        }
        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
            Remove-Item -Path ($upgradeDetail.Dir + "\..") -Recurse -Force
        }
    }

    Context "Invoke-IsInRole" {
        # TODO
        # Test to be implemented
    }

    Context "New-Directories" {
        BeforeAll {
            $originalSessionValues = Backup-SessionEnvironmentVariables
            $originalSystemValues = Backup-SystemEnvironmentVariables
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        BeforeEach {
            $tempDir = "$env:TEMP\Test_Dir"
            $testEnvVarSet = @{
                TEST_VAL = @{DefVal = "Test value"; IsDir = $false }
                TEST_DIR = @{DefVal = $tempDir; IsDir = $True }
            }
            foreach ($envVar in $testEnvVarSet.Keys) {
                [System.Environment]::SetEnvironmentVariable($envVar, $testEnvVarSet[$envVar]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
                Set-Item -Path "env:$envVar" -Value $testEnvVarSet[$envVar]["DefVal"]
            }
        }

        It "Should create all the directories" {
            New-Directories -EnvVarSet $testEnvVarSet

            Test-Path -Path $env:TEST_VAL | Should -Be $false
            Test-Path -Path $env:TEST_DIR | Should -Be $true
        }
        AfterEach {
            Unpublish-EnvironmentVariables -EnvVarSet $testEnvVarSet
            Remove-Item -Path $tempDir -Recurse -Force
        }
        AfterAll {
            Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
        }
    }

    Context "Publish-LatestVersion" {
        BeforeAll {
            if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1

            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        BeforeEach {
            $originalSessionValues = Backup-SessionEnvironmentVariables
            $mockInstalVal = Set-TestSetup_6_0_0

            $upgradeDetail = Set-TestSetup_InstallationFiles
        }

        It "Should copy all installation files" {
            Publish-LatestVersion -UpgradeSourceDir $upgradeDetail.Dir

            foreach ($fileName in $upgradeDetail.FileList) {
                $barefilename = Split-Path -Path $filename -Leaf
                # Write-Host $barefilename
                (Test-Path -Path "$env:VENVIT_DIR\$barefilename") | Should -Be $true
            }
        }

        AfterEach {
            Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            Remove-Item -Path ($upgradeDetail.Dir + "\..") -Recurse -Force
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
        AfterAll {
        }
    }

    Context "Publish-Secrets" {
        BeforeAll {
            if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1

            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        BeforeEach {
            $originalSessionValues = Backup-SessionEnvironmentVariables
            $mockInstalVal = Set-TestSetup_7_0_0

            $upgradeDetail = Set-TestSetup_InstallationFiles
        }

        It "Should copy all secrets files" {
            $secretsPath = Join-Path -Path $env:VENV_SECRETS_DEFAULT_DIR -ChildPath (Get-SecretsFileName)
            Remove-Item -Path $secretsPath -Recurse -Force
            $secretsPath = Join-Path -Path $env:VENV_SECRETS_USER_DIR -ChildPath (Get-SecretsFileName)
            Remove-Item -Path $secretsPath -Recurse -Force
            $secretsDirList = Publish-Secrets -UpgradeScriptDir $upgradeDetail.Dir

            $secretsDirList | Should -Be @("$env:VENV_SECRETS_DEFAULT_DIR\Secrets.ps1", "$env:VENV_SECRETS_USER_DIR\Secrets.ps1")
        }

        It "Should only copy VENV_SECRETS_DEFAULT_DIR secrets files" {
            $secretsPath = Join-Path -Path $env:VENV_SECRETS_DEFAULT_DIR -ChildPath (Get-SecretsFileName)
            Remove-Item -Path $secretsPath -Recurse -Force | Out-Null

            $secretsDirList = Publish-Secrets -UpgradeScriptDir $upgradeDetail.Dir

            $secretsDirList | Should -Be @("$env:VENV_SECRETS_DEFAULT_DIR\Secrets.ps1")
        }

        AfterEach {
            Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            Remove-Item -Path $upgradeDetail.Dir -Recurse -Force | Out-Null
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force | Out-Null
        }
    }

    Context "Set-Path" {
        BeforeEach {
            $orgigPATH = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        }

        It "VenvIt not in path" {
            [System.Environment]::SetEnvironmentVariable("Path", "C:\;D:\", [System.EnvironmentVariableTarget]::Machine)
            Set-Path
            $newPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
            $newPath | Should -Be "C:\;D:\;$env:VENVIT_DIR"
        }

        It "VenvIt already in path" {
            [System.Environment]::SetEnvironmentVariable("Path", "C:\; D:\; $env:VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
            Set-Path
            $newPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
            $newPath | Should -Be "C:\; D:\; $env:VENVIT_DIR"
        }

        AfterEach {
            [System.Environment]::SetEnvironmentVariable("Path", $orgigPATH, [System.EnvironmentVariableTarget]::Machine)
        }
    }

    Context "Test-Admin" {
        BeforeAll {
            if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
            Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1
        }
        It "Returns true if an administrator" {
            Mock -ModuleName Install-Conclude -CommandName Invoke-IsInRole { return $true }

            Test-Admin | Should -Be $true
        }

        It "Returns false if not an administrator" {
            Mock -ModuleName Install-Conclude -CommandName Invoke-IsInRole { return $false }

            Test-Admin | Should -Be $false
        }
    }

    AfterAll {
        [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $OrigVENV_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $OrigPROJECTS_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $OrigVENVIT_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $OrigVENV_SECRETS_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $OrigVENV_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $OrigVENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $OrigVENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $OrigVENV_CONFIG_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $OrigVENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    }

}
