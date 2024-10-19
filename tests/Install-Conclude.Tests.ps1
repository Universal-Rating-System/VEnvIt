# Pester test for Install-Conclude.Tests.ps1

Describe "Function testing" {
    BeforeAll {
        if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
        if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
        Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1

        # This test must be run with administrator rights.
        if (-not (Test-Admin)) {
            Throw "Tests must be run as an Administrator. Aborting..."
        }
        $OrigVENV_ENVIRONMENT = $env:VENV_ENVIRONMENT
        $OrigPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
        $OrigVENVIT_DIR = $env:VENVIT_DIR
        $OrigVENVIT_SECRETS_ORG_DIR = $env:VENVIT_SECRETS_ORG_DIR
        $OrigVENVIT_SECRETS_USER_DIR = $env:VENVIT_SECRETS_USER_DIR
        $OrigVENV_BASE_DIR = $env:VENV_BASE_DIR
        $OrigVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
        $OrigVENV_CONFIG_ORG_DIR = $env:VENV_CONFIG_ORG_DIR
        $OrigVENV_CONFIG_USER_DIR = $env:VENV_CONFIG_USER_DIR
    }

    Context "Invoke-ConcludeInstall" {
        # TODO
        # Test to be implemented
    }

    Context "Invoke-CleanUp" {
        # TODO
        # Test to be implemented
    }

    Context "Remove-EnvVarIfExists" {
        # TODO
        # Test to be implemented
    }

    Context "New-Directories" {
        BeforeAll {
            # if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", "loc_dev", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", "~\Projects", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", "$env:ProgramFiles\VenvIt", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_ORG_DIR", "$env:VENVIT_DIR\Secrets", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", "~\VenvIt\Secrets", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", "~\venv", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", "c:\Python", [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_ORG_DIR", "$env:VENVIT_DIR\Config", [System.EnvironmentVariableTarget]::Machine)
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
                    [System.Environment]::SetEnvironmentVariable($envVar.Name, $envVar.DefVal,[System.EnvironmentVariableTarget]::Machine)
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
    }

    Context "Set-EnvironmentVariables tests" {
        It "All environment variables have values" {
            Mock -ModuleName Install-Conclude Read-Host { return "venv_environment" } -ParameterFilter { $Prompt -eq "VENV_ENVIRONMENT (venv_environment)" }
            Mock -ModuleName Install-Conclude Read-Host { return "projects_base_dir" } -ParameterFilter { $Prompt -eq "PROJECTS_BASE_DIR (projects_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venvit_dir" } -ParameterFilter { $Prompt -eq "VENVIT_DIR (venvit_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venvit_secrets_org_dir" } -ParameterFilter { $Prompt -eq "VENVIT_SECRETS_ORG_DIR (venvit_secrets_org_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venvit_secrets_user_dir" } -ParameterFilter { $Prompt -eq "VENVIT_SECRETS_USER_DIR (venvit_secrets_user_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_base_dir" } -ParameterFilter { $Prompt -eq "VENV_BASE_DIR (venv_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_python_base_dir" } -ParameterFilter { $Prompt -eq "VENV_PYTHON_BASE_DIR (venv_python_base_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_config_org_dir" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_ORG_DIR (venv_config_org_dir)" }
            Mock -ModuleName Install-Conclude Read-Host { return "venv_config_user_dir" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_USER_DIR (venv_config_user_dir)" }
            Set-EnvironmentVariables

            $venvEnvironment = [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
            $venvEnvironment | Should -Be "venv_environment"
            $projectsBaseDir = [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $projectsBaseDir | Should -Be "projects_base_dir"
            $venvitDir = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitDir | Should -Be "venvit_dir"
            $venvitSecretsOrgDir = [System.Environment]::GetEnvironmentVariable("VENVIT_SECRETS_ORG_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitSecretsOrgDir | Should -Be "venvit_secrets_org_dir"
            $venvitSecretsUserDir = [System.Environment]::GetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvitSecretsUserDir | Should -Be "venvit_secrets_user_dir"
            $venvBaseDir = [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvBaseDir | Should -Be "venv_base_dir"
            $venvPythonBaseDir = [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvPythonBaseDir | Should -Be "venv_python_base_dir"
            $venvConfigOrgDir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_ORG_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvConfigOrgDir | Should -Be "venv_config_org_dir"
            $venvConfigUserDir = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $venvConfigUserDir | Should -Be "venv_config_user_dir"

        }
    # Bit of a useless test due to "IsInRole" not being able to be mocked.
    }

    Context "Test-Admin Function" {
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
        [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_ORG_DIR", $OrigVENVIT_SECRETS_ORG_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENVIT_SECRETS_USER_DIR", $OrigVENVIT_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $OrigVENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $OrigVENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_ORG_DIR", $OrigVENV_CONFIG_ORG_DIR, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $OrigVENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
    }

}
