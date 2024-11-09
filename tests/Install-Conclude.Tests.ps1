# Pester test for Install-Conclude.Tests.ps1
if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

Describe "Function testing" {
    BeforeAll {
        # if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
        if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
        Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1

        # This test must be run with administrator rights.
        if (-not (Test-Admin)) {
            Throw "Tests must be run as an Administrator. Aborting..."
        }
    }

    Context "Clear-InstallationFiles" {
        BeforeEach {
            $OriginalValues = Backup-SessionEnvironmentVariables
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $upgradeScriptDir = "$tempDir\UpgradeScript"
            New-Item -ItemType Directory -Path $upgradeScriptDir | Out-Null
        }

        It "Unsure instqallation files removed" {
            Clear-InstallationFiles -upgradeScriptDir $upgradeScriptDir
            (Test-Path -Path $upgradeScriptDir) | Should -Be $false
        }

        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
        }
    }

    Context "Invoke-ConcludeInstall" {
        # TODO
        # Test to be implemented
    }

    Context "Invoke-IsInRole" {
        # TODO
        # Test to be implemented
    }

    Context "New-Directories" {
        BeforeAll {
            $originalSessionValues = Backup-SessionEnvironmentVariables
            $originalSystemValues = Backup-SystemEnvironmentVariables

        }
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            foreach ($envVar in $defEnvVarSet) {
                if ($envVar.IsDir) {
                    if ($envVar.DefVal -like "~*") {
                        $envVar.DefVal = $envVar.DefVal -replace "^~", $tempDir
                    }
                    else {
                        $lastChild = Split-Path -Path $envVar.DefVal -Leaf
                        $envVar.DefVal = Join-Path -Path $tempDir -ChildPath $lastChild
                    }
                    [System.Environment]::SetEnvironmentVariable($envVar.Name, $envVar.DefVal, [System.EnvironmentVariableTarget]::Machine)
                }
            }
        }
        It "Should create all the directories" {
            New-Directories
            foreach ($envVar in $envVarSet) {
                if ( $envVar.IsDir ) {
                    Test-Path -Path $envVar.DefVal | Should -Be $true
                }
            }
        }
        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
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
            # Remove-Item -Path (Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)) -Recurse -Force

            $TempDir = New-CustomTempDir -Prefix "VenvIt"
            $upgradeScriptDir = Join-Path -Path $TempDir -ChildPath "TempUpgradeDir"
            New-Item -ItemType Directory -Path "$upgradeScriptDir\src"
            Copy-Item -Path "$PSScriptRoot\..\README.md" -Destination $upgradeScriptDir
            Copy-Item -Path "$PSScriptRoot\..\LICENSE" -Destination $upgradeScriptDir
            Copy-Item -Path "$PSScriptRoot\..\ReleaseNotes.md" -Destination $upgradeScriptDir
            Copy-Item -Path "$PSScriptRoot\..\src\vi.ps1" -Destination "$upgradeScriptDir\src"
            Copy-Item -Path "$PSScriptRoot\..\src\vn.ps1" -Destination "$upgradeScriptDir\src"
            Copy-Item -Path "$PSScriptRoot\..\src\vr.ps1" -Destination "$upgradeScriptDir\src"
            Copy-Item -Path "$PSScriptRoot\..\src\utils.psm1" -Destination "$upgradeScriptDir\src"
            $manifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -DestinationPath $manifestPath -data $ManifestData700
        }

        It "Should copy all installation files" {
            Publish-LatestVersion -UpgradeScriptDir $upgradeScriptDir

            (Test-Path -Path "$env:VENVIT_DIR\README.md") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\LICENSE") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\Manifest.psd1") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\ReleaseNotes.md") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\vi.ps1") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\vn.ps1") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\vr.ps1") | Should -Be $true
            (Test-Path -Path "$env:VENVIT_DIR\Utils.psm1") | Should -Be $true
        }

        AfterEach {
            Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            Remove-Item -Path $TempDir -Recurse -Force
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
        AfterAll {
        }
    }

    Context "Publish-Secrets" {
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $env:VENV_SECRETS_DEFAULT_DIR = "$tempDir\DefaultSecrets"
            $env:VENV_SECRETS_USER_DIR = "$tempDir\UserSecrets"
            $env:VENVIT_DIR = "$tempDir\VenvIt"

            New-Item -ItemType Directory -Path $env:VENVIT_DIR | Out-Null
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_DEFAULT_DIR | Out-Null
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_USER_DIR | Out-Null

            Copy-Item -Path $PSScriptRoot\..\src\secrets.ps1 -Destination $env:VENVIT_DIR
        }

        It "Should copy all secrets files" {
            Publish-Secrets

            (Test-Path -Path $env:VENV_SECRETS_DEFAULT_DIR\secrets.ps1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_SECRETS_USER_DIR\secrets.ps1) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
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
        [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", $OrigVENVIT_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $OrigVENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $OrigVENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $OrigVENV_CONFIG_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $OrigVENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    }

}
