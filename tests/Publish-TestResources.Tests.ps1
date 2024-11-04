if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

Describe "Function testing" {

    Context "Invoke-TestSetup_0_0_0" {
        BeforeEach {
            $origENVIRONMENT = $env:ENVIRONMENT
            $origPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
            $origRTE_ENVIRONMENT = $env:RTE_ENVIRONMENT
            $origSCRITPS_DIR = $env:SCRIPTS_DIR
            $origVENV_BASE_DIR = $env:VENV_BASE_DIR
            $origVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Invoke-TestSetup_0_0_0

            $env:ENVIRONMENT | Should -Be "loc_dev"
            $env:RTE_ENVIRONMENT | Should -Be "loc_dev"
            $env:PROJECTS_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Projects")
            $env:SCRIPTS_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Batch")
            $env:VENV_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "venv")
            $env:VENV_PYTHON_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Python")

            Test-Path -Path $env:PROJECTS_BASE_DIR | Should -Be $true
            Test-Path -Path $env:SCRIPTS_DIR  | Should -Be $true
            Test-Path -Path $env:VENV_BASE_DIR | Should -Be $true
            Test-Path -Path $env:VENV_PYTHON_BASE_DIR  | Should -Be $true

            $fileName = "venv_" + $mockInstalVal.ProjectName + "_setup_mandatory.ps1"
            Test-Path ( Join-Path -Path $env:SCRIPTS_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "venv_" + $mockInstalVal.ProjectName + "_setup_custom.ps1"
            Test-Path ( Join-Path -Path $env:SCRIPTS_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "venv_" + $mockInstalVal.ProjectName + "_install.ps1"
            Test-Path ( Join-Path -Path $env:SCRIPTS_DIR -ChildPath $fileName ) | Should -Be $true

            Test-Path ( Join-Path -Path $env:SCRIPTS_DIR -ChildPath "env_var_loc_dev.bat" ) | Should -Be $true
        }
        AfterEach {
            $env:ENVIRONMENT = $origENVIRONMENT
            $env:PROJECTS_BASE_DIR = $origPROJECTS_BASE_DIR
            $env:RTE_ENVIRONMENT = $origRTE_ENVIRONMENT
            $env:SCRIPTS_DIR = $origSCRITPS_DIR
            $env:VENV_BASE_DIR = $origVENV_BASE_DIR
            $env:VENV_PYTHON_BASE_DIR = $origVENV_PYTHON_BASE_DIR
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Invoke-TestSetup_6_0_0" {
        BeforeEach {
            $origPROJECT_NAME = $env:PROJECT_NAME
            $origPROJECTS_BASE_DIR = $env:PROJECTS_BASE_DIR
            $origVENV_BASE_DIR = $env:VENV_BASE_DIR
            $origVENV_CONFIG_DIR = $env:VENV_CONFIG_DIR
            $origVENV_ENVIRONMENT = $env:VENV_ENVIRONMENT
            $origVENV_PYTHON_BASE_DIR = $env:VENV_PYTHON_BASE_DIR
            $origVENV_SECRETS_DIR = $env:VENV_SECRETS_DIR
            $origVENVIT_DIR = $env:VENVIT_DIR
            $origPROJECT_DIR = $env:origPROJECT_DIR
            $origVIRTUAL_ENV = $env:VIRTUAL_ENV
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Invoke-TestSetup_6_0_0

            $env:PROJECT_NAME | Should -Be $mockInstalVal.ProjectName
            $env:PROJECTS_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Projects")
            $env:VENV_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VEnv")
            $env:VENV_CONFIG_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VENV_CONFIG_DIR")
            $env:VENV_ENVIRONMENT | Should -Be "loc_dev"
            $env:VENV_PYTHON_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Python")
            $env:VENV_SECRETS_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VENV_SECRETS_DIR")
            $env:VENVIT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VEnvIt")
            $env:PROJECT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Projects\MyOrg\MyProject")
            $env:VIRTUAL_ENV | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VEnv\MyProject")

            Test-Path -Path $env:PROJECT_DIR | Should -Be $true
            Test-Path -Path "$env:VENV_BASE_DIR\${env:PROJECT_NAME}_env\Scripts"  | Should -Be $true
            Test-Path -Path $env:VENV_CONFIG_DIR | Should -Be $true
            Test-Path -Path $env:VENV_PYTHON_BASE_DIR  | Should -Be $true
            Test-Path -Path $env:VENV_SECRETS_DIR  | Should -Be $true
            Test-Path -Path $env:VENVIT_DIR  | Should -Be $true

            $fileName = "venv_" + $mockInstalVal.ProjectName + "_setup_mandatory.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "venv_" + $mockInstalVal.ProjectName + "_setup_custom.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "venv_" + $mockInstalVal.ProjectName + "_install.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $fileName ) | Should -Be $true

            Test-Path ( Join-Path -Path $env:VENV_SECRETS_DIR -ChildPath "dev_env_var.ps1" ) | Should -Be $true
        }
        AfterEach {
            $env:PROJECT_NAME = $origPROJECT_NAME
            $env:PROJECTS_BASE_DIR = $origPROJECTS_BASE_DIR
            $env:VENV_BASE_DIR = $origVENV_BASE_DIR
            $env:VENV_CONFIG_DIR = $origVENV_CONFIG_DIR
            $env:VENV_ENVIRONMENT = $origVENV_ENVIRONMENT
            $env:VENV_PYTHON_BASE_DIR = $origVENV_PYTHON_BASE_DIR
            $env:VENV_SECRETS_DIR = $origVENV_SECRETS_DIR
            $env:VENVIT_DIR = $origVENVIT_DIR
            $env:origPROJECT_DIR = $origPROJECT_DIR
            $env:VIRTUAL_ENV = $origVIRTUAL_ENV

            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-CreateAppScripts" {
        BeforeEach {
            $TempDir = New-CustomTempDir -Prefix "VenvIt"
        }
        It "Should create mock app scripts" {
            New-CreateAppScripts -BaseDirectory $TempDir

            Test-Path (Join-Path -Path $TempDir -ChildPath "vi.ps1") | Should -Be $true
            Test-Path (Join-Path -Path $TempDir -ChildPath "vn.ps1") | Should -Be $true
            Test-Path (Join-Path -Path $TempDir -ChildPath "vr.ps1") | Should -Be $true
        }
        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
        }
    }
}
