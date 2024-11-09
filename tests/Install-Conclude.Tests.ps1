# Pester test for Install-Conclude.Tests.ps1

Describe "Function testing" {
    BeforeAll {
        # if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
        if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
        Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module $PSScriptRoot\..\src\Utils.psm1

        # This test must be run with administrator rights.
        if (-not (Test-Admin)) {
            Throw "Tests must be run as an Administrator. Aborting..."
        }
        $OrigVENV_ENVIRONMENT = $env:VENV_ENVIRONMENT
        $OrigPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
        $OrigVENVIT_DIR = $env:VENVIT_DIR
        $OrigVENV_SECRETS_DEFAULT_DIR = $env:VENV_SECRETS_DEFAULT_DIR
        $OrigVENV_SECRETS_USER_DIR = $env:VENVIT_SECRETS_USER_DIR
        $OrigVENV_BASE_DIR = $env:VENV_BASE_DIR
        $OrigVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
        $OrigVENV_CONFIG_DEFAULT_DIR = $env:VENV_CONFIG_DEFAULT_DIR
        $OrigVENV_CONFIG_USER_DIR = $env:VENV_CONFIG_USER_DIR
    }

    Context "Clear-InstallationFiles" {
        BeforeEach {
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
        }
    }

    Context "Invoke-ConcludeInstall" {
        # TODO
        # Test to be implemented
    }

    Context "New-Directories" {
        BeforeAll {
            $originalSessionValues = Backup-SessionEnvironmentVariables
            $originalSystemValues = Backup-SystemEnvironmentVariables

        }
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", "loc_dev", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", "~\Projects", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", "$env:ProgramFiles\VenvIt", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", "$env:VENVIT_DIR\Secrets", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", "~\VenvIt\Secrets", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", "~\venv", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", "c:\Python", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", "$env:VENVIT_DIR\Config", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", "~\VenvIt\Config", [System.EnvironmentVariableTarget]::Machine)

            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            foreach ($envVar in $envVarSet) {
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
        BeforeEach {
            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $webMockDir = "$tempDir\WebMock"
            $upgadeScriptDir = "$tempDir\UpgradeScript"
            $env:VENVIT_DIR = "$tempDir\VenvIt"

            New-Item -ItemType Directory -Path $env:VENVIT_DIR | Out-Null
            New-Item -ItemType Directory -Path $webMockDir | Out-Null
            New-Item -ItemType Directory -Path $upgadeScriptDir | Out-Null
        }

        It "Should copy all installation files" {
            $latestVersion = "7.0.0"
            Compress-Archive -Path $PSScriptRoot\..\README.md, $PSScriptRoot\..\LICENSE, $PSScriptRoot\..\ReleaseNotes.md -DestinationPath $webMockDir\Installation-Files.zip -Update
            Compress-Archive -Path $PSScriptRoot\..\src\*.ps1, $PSScriptRoot\..\src\*.ps?1 -DestinationPath $webMockDir\Installation-Files.zip -Update


            Mock -ModuleName Install-Conclude Invoke-WebRequest {
                Copy-Item -Path $webMockDir\Installation-Files.zip -Destination $OutFile
            }

            Publish-LatestVersion -Release $latestVersion -UpgradeScriptDir $upgadeScriptDir

            (Test-Path -Path $env:VENVIT_DIR\Conclude-UpgradePrep.psm1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\secrets.ps1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\Install.ps1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\Install-Conclude.psm1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\LICENSE) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\README.md) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\ReleaseNotes.md) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\Update-Manifest.psm1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\Utils.psm1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\vi.ps1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\vn.ps1) | Should -Be $true
            (Test-Path -Path $env:VENVIT_DIR\vr.ps1) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
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

    Context "Remove-EnvVarIfExists" {
        # TODO
        # Test to be implemented
    }

    Context "Set-EnvironmentVariables" {
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", "venv_environment", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", "projects_base_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", "venvit_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", "VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", "venvit_secrets_user_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", "venv_base_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", "venv_python_base_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", "venv_config_org_dir", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", "venv_config_user_dir", [System.EnvironmentVariableTarget]::Machine)
        }
        It "All environment variables have values" {
            Mock -ModuleName Install-Conclude Read-Host { return "venv_environment" } -ParameterFilter { $Prompt -eq "VENV_ENVIRONMENT (venv_environment)" }
            Mock -ModuleName Install-Conclude Read-Host { return "projects_base_dir" } -ParameterFilter { $Prompt -eq "PROJECTS_BASE_DIR (projects_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venvit_dir" } -ParameterFilter { $Prompt -eq "VENVIT_DIR (venvit_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "VENV_SECRETS_DEFAULT_DIR" } -ParameterFilter { $Prompt -eq "VENV_SECRETS_DEFAULT_DIR (VENV_SECRETS_DEFAULT_DIR)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venvit_secrets_user_dir" } -ParameterFilter { $Prompt -eq "VENV_SECRETS_USER_DIR (venvit_secrets_user_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_base_dir" } -ParameterFilter { $Prompt -eq "VENV_BASE_DIR (venv_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_python_base_dir" } -ParameterFilter { $Prompt -eq "VENV_PYTHON_BASE_DIR (venv_python_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_config_org_dir" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_DEFAULT_DIR (venv_config_org_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_config_user_dir" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_USER_DIR (venv_config_user_dir)" }
            Set-EnvironmentVariables

            $venvEnvironment = [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
            $venvEnvironment | Should -Be "venv_environment"
            $projectsBaseDir = [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $projectsBaseDir | Should -Be "projects_base_dir"
            $venvitDir = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitDir | Should -Be "venvit_dir"
            $venvitSecretsDefaultDir = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitSecretsDefaultDir | Should -Be "VENV_SECRETS_DEFAULT_DIR"
            $venvitSecretsUserDir = [System.Environment]::GetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitSecretsUserDir | Should -Be "venvit_secrets_user_dir"
            $venvBaseDir = [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvBaseDir | Should -Be "venv_base_dir"
            $venvPythonBaseDir = [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvPythonBaseDir | Should -Be "venv_python_base_dir"
            $venvConfigDefaultDir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvConfigDefaultDir | Should -Be "venv_config_org_dir"
            $venvConfigUserDir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvConfigUserDir | Should -Be "venv_config_user_dir"

        }
        # Bit of a useless test due to "IsInRole" not being able to be mocked.
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
