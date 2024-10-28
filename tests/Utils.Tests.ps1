Describe "Function Tests" {
    BeforeAll {
        if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
        Import-Module "$PSScriptRoot\..\src\Utils.psm1"
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

    Context "New-CustomTempDir Test" {
        It "Temporary dir with prefix" {
            $Prefix = "venvit"
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
