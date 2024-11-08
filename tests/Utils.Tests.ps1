if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1

Describe "Function Tests" {
    BeforeAll {
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module "$PSScriptRoot\..\src\Utils.psm1"
    }

    Context "Backup-ScriptToArchiveIfExists" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Backup-ScriptToArchiveIfExists" {}
        AfterAll {}
    }

    Context "Confirm-EnvironmentVariables" {
        BeforeEach {
            $env:PROJECTS_BASE_DIR = "projects_base_dir"
            $env:VENV_BASE_DIR = "venv_base_dir"
            $env:VENV_ENVIRONMENT = "venv_environment"
            $env:VENV_CONFIG_DEFAULT_DIR = "venv_config_dir"
            $env:VENV_CONFIG_USER_DIR = "venv_config_dir"
            $env:VENV_PYTHON_BASE_DIR = "venv_python_base_dir"
            $env:VENV_SECRETS_DEFAULT_DIR = "venv_secrets_org_dir"
            $env:VENV_SECRETS_USER_DIR = "venv_secrets_user_dir"
            $env:VENVIT_DIR = "venvit_dir"
        }

        It "Should be true" {
            Confirm-EnvironmentVariables | Should -Be $true
        }

        It "Should be false" {
            $env:VENV_ENVIRONMENT = ""
            Confirm-EnvironmentVariables | Should -Be $false
        }

        AfterEach {
        }
    }

    Context "Get-ConfigFileName" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Get-ConfigFileName" {}
        AfterAll {}
    }

    Context "Get-ManifestFileName" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Get-ManifestFileName" {}
        AfterAll {}
    }

    Context "New-CustomTempDir Test" {
        It "Temporary dir with prefix" {
            $Prefix = "VenvIt"
            $TempDir = New-CustomTempDir -Prefix $Prefix
            Test-Path -Path $tempDir | Should -Be $true
        }
        AfterEach {
            # Cleanup: Remove the created directory if it exists
            if (Test-Path -Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    }

    Context "Get-ConfigFileName" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Get-ConfigFileName" {}
        AfterAll {}
    }

    Context "Set-EnvironmentVariables" {
        BeforeAll {
            $origPROJECT_NAME = [System.Environment]::GetEnvironmentVariable("PROJECT_NAME", [System.EnvironmentVariableTarget]::Machine)
            $origPROJECTS_BASE_DIR = [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origRTE_ENVIRONMENT = [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
            $origSECRETS_DIR = [System.Environment]::GetEnvironmentVariable("SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origSCRIPTS_DIR = [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_BASE_DIR = [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_CONFIG_DEFAULT_DIR = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_CONFIG_USER_DIR = [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_ENVIRONMENT = [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_ORGANIZATION_NAME = [System.Environment]::GetEnvironmentVariable("VENV_ORGANIZATION_NAME", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_PYTHON_BASE_DIR = [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_SECRETS_DEFAULT_DIR = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENV_SECRETS_USER_DIR = [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine)
            $origVENVIT_DIR = [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine)

            $mockInstalVal = Set-TestSetup_7_0_0
            [System.Environment]::SetEnvironmentVariable("PROJECT_NAME", $mockInstalVal.ProjectName, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $defEnvVarSet["PROJECTS_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $defEnvVarSet["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $defEnvVarSet["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $defEnvVarSet["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $defEnvVarSet["VENV_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $defEnvVarSet["VENV_CONFIG_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $defEnvVarSet["VENV_CONFIG_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $defEnvVarSet["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ORGANIZATION_NAME", $mockInstalVal.Organization, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $defEnvVarSet["VENV_PYTHON_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $defEnvVarSet["VENV_SECRETS_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $defEnvVarSet["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $defEnvVarSet["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)

            Mock -ModuleName Utils Read-Host { return "~\Projects" } -ParameterFilter { $Prompt -eq "PROJECTS_BASE_DIR (~\Projects)" }
            Mock -ModuleName Utils Read-Host { return "~\venv" } -ParameterFilter { $Prompt -eq "VENV_BASE_DIR (~\venv)" }
            Mock -ModuleName Utils Read-Host { return "C:\Program Files\VenvIt\Config" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_DEFAULT_DIR (C:\Program Files\VenvIt\Config)" }
            Mock -ModuleName Utils Read-Host { return "~\VenvIt\Config" } -ParameterFilter { $Prompt -eq "VENV_CONFIG_USER_DIR (~\VenvIt\Config)" }
            Mock -ModuleName Utils Read-Host { return "loc_dev" } -ParameterFilter { $Prompt -eq "VENV_ENVIRONMENT (loc_dev)" }
            Mock -ModuleName Utils Read-Host { return "c:\Python" } -ParameterFilter { $Prompt -eq "VENV_PYTHON_BASE_DIR (c:\Python)" }
            Mock -ModuleName Utils Read-Host { return "C:\Program Files\VenvIt\Secrets" } -ParameterFilter { $Prompt -eq "VENV_SECRETS_DEFAULT_DIR (C:\Program Files\VenvIt\Secrets)" }
            Mock -ModuleName Utils Read-Host { return "~\VenvIt\Secrets" } -ParameterFilter { $Prompt -eq "VENV_SECRETS_USER_DIR (~\VenvIt\Secrets)" }
            Mock -ModuleName Utils Read-Host { return "C:\Program Files\VenvIt" } -ParameterFilter { $Prompt -eq "VENVIT_DIR (C:\Program Files\VenvIt)" }
        }
        It "Should read and set environment variables" {
            Set-EnvironmentVariables -EnvVarSet $defEnvVarSet
            [System.Environment]::GetEnvironmentVariable("PROJECT_NAME", [System.EnvironmentVariableTarget]::Machine) | Should -Be $mockInstalVal.ProjectName
            [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["PROJECTS_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_ENVIRONMENT"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_SECRETS_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENVIT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_CONFIG_DEFAULT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_CONFIG_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_ENVIRONMENT"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_ORGANIZATION_NAME", [System.EnvironmentVariableTarget]::Machine) | Should -Be $mockInstalVal.Organization
            [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_PYTHON_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_SECRETS_DEFAULT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENV_SECRETS_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet["VENVIT_DIR"]["DefVal"]
        }
        AfterAll {
            [System.Environment]::SetEnvironmentVariable("PROJECT_NAME", $origPROJECT_NAME, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $origPROJECTS_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $origRTE_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $origSECRETS_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $origSCRIPTS_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $origVENV_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $origVENV_CONFIG_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $origVENV_CONFIG_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $origVENV_ENVIRONMENT, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ORGANIZATION_NAME", $origVENV_ORGANIZATION_NAME, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $origVENV_PYTHON_BASE_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $origVENV_SECRETS_DEFAULT_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $origVENV_SECRETS_USER_DIR, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $origVENVIT_DIR, [System.EnvironmentVariableTarget]::Machine)

            Restore-SessionEnvironmentVariables -OriginalValues $originalValues
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
            } -ParameterFilter { $Prompt -eq "d as response (Y/n)"}
            Mock -ModuleName "Utils" Read-Host {
                return "Y"
            } -ParameterFilter { $Prompt -eq "Only Y or N (Y/n)" }

            $Result = Read-YesOrNo "d as response"
            $Result  | Should -Be $true
        }
    }
}
