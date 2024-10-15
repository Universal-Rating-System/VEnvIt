# Pester test for vn.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vn.ps1 -Pester
    }
    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }
    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-Vn" -MockWith { Write-Host "Mock: Invoke-Vn called" }
        }
        It "Should call Invoke-Vn function with ProjectName" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName "Tes01"
            # Assert-MockCalled -CommandName "Invoke-MyScript" -Exactly 1 -ParameterFilter { $Var01 -eq 'TestValue' }
            Assert-MockCalled -CommandName "Invoke-Vn" -Exactly 1
        }
    }

    Context "When Var01 is an empty string and Help is not passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

Describe "Function testing" {
    BeforeAll {
        . $PSScriptRoot\..\src\vn.ps1 -Pester
    }
    Context "Confirm-EnvironmentVariables" {
        BeforeEach {
            $OrigVENV_ENVIRONMENT = $env:VENV_ENVIRONMENT
            $env:VENV_ENVIRONMENT = "venv_environment"

            $OrigVENVIT_DIR = $env:VENVIT_DIR
            $env:VENVIT_DIR = "venvit_dir"

            $OrigVENV_SECRETS_DIR = $env:VENV_SECRETS_DIR
            $env:VENV_SECRETS_DIR = "venv_secrets_dir"

            $OrigVENV_CONFIG_DIR = $env:VENV_CONFIG_DIR
            $env:VENV_CONFIG_DIR = "venv_config_dir"

            $OrigPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
            $env:PROJECTS_BASE_DIR = "projects_base_dir"

            $OrigVENV_BASE_DIR = $env:VENV_BASE_DIR
            $env:VENV_BASE_DIR = "venv_base_dir"

            $OrigVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
            $env:VENV_PYTHON_BASE_DIR = "venv_python_base_dir"
        }
        It "Should be true" {
            Confirm-EnvironmentVariables | Should -Be $true
        }
        It "Should be false" {
            $env:VENV_ENVIRONMENT = ""
            Confirm-EnvironmentVariables | Should -Be $false
        }
        AfterEach {
            $env:VENV_ENVIRONMENT = $OrigVENV_ENVIRONMENT
            $env:VENVIT_DIR = $OrigVENVIT_DIR
            $env:VENV_SECRETS_DIR = $OrigVENV_SECRETS_DIR
            $env:VENV_CONFIG_DIR = $OrigVENV_CONFIG_DIR
            $env:PROJECTS_BASE_DIR = $OrigPROJECTS_BASE_DIR
            $env:VENV_BASE_DIR = $OrigVENV_BASE_DIR
            $env:VENV_PYTHON_BASE_DIR = $OrigVENV_PYTHON_BASE_DIR
        }
}
    Context "New-VirtualEnvironment" {

    }
}

