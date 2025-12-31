# Publish-TestResources.Tests.ps1

BeforeAll {
    if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
    Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1

    if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
    Import-Module $PSScriptRoot\Publish-TestResources.psm1

    if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
    Import-Module $PSScriptRoot\..\src\Utils.psm1
}

Describe "Uninstall.Tests.ps1: Function Tests" {
    BeforeAll {
        # if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
        # Import-Module $PSScriptRoot\Publish-TestResources.psm1
        $originalSessionValues = Backup-SessionEnvironmentVariables
        $originalSystemValues = Backup-SystemEnvironmentVariables
    }

    Context "Backup-SessionEnvironmentVariables" {
        # TODO
        # Test to be implemented
        BeforeEach {}
        It "TODO Backup-SessionEnvironmentVariables" {}
        AfterEach {}
    }

    Context "Backup-SystemEnvironmentVariables" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

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
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $defEnvVarSet_7_0_0["PROJECTS_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $defEnvVarSet_7_0_0["VENV_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $defEnvVarSet_7_0_0["VENV_CONFIG_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $defEnvVarSet_7_0_0["VENV_CONFIG_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ORGANIZATION_NAME", $mockInstalVal.Organization, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $defEnvVarSet_7_0_0["VENV_PYTHON_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
        }
        It "Should backup environment values" {
            $origValues = Backup-SystemEnvironmentVariables
            $origValues.PROJECT_NAME | Should -Be $mockInstalVal.ProjectName
            $origValues.PROJECTS_BASE_DIR | Should -Be $defEnvVarSet_7_0_0["PROJECTS_BASE_DIR"]["DefVal"]
            $origValues.RTE_ENVIRONMENT | Should -Be $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
            $origValues.SECRETS_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
            $origValues.SCRIPTS_DIR | Should -Be $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
            $origValues.VENV_BASE_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_BASE_DIR"]["DefVal"]
            $origValues.VENV_CONFIG_USER_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_CONFIG_USER_DIR"]["DefVal"]
            $origValues.VENV_CONFIG_DEFAULT_DIR = $defEnvVarSet_7_0_0["VENV_CONFIG_DEFAULT_DIR"]["DefVal"]
            $origValues.VENV_ENVIRONMENT | Should -Be $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
            $origValues.VENV_ORGANIZATION_NAME | Should -Be $mockInstalVal.Organization
            $origValues.VENV_PYTHON_BASE_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_PYTHON_BASE_DIR"]["DefVal"]
            $origValues.VENV_SECRETS_DEFAULT_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_DEFAULT_DIR"]["DefVal"]
            $origValues.VENV_SECRETS_USER_DIR | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
            $origValues.VENVIT_DIR | Should -Be $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
        }

        AfterEach {
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
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force }
    }

    Context "ConvertFrom-ProdToTestEnvVar" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            $tempDir = New-CustomTempDir -Prefix "VenvIt"
            $envVarSet = @{
                TEST_NULL         = @{DefVal = $null; IsDir = $true }
                TEST_TILDE        = @{DefVal = "~\Projects"; IsDir = $true }
                TEST_PROGRAMFILES = @{DefVal = "$env:ProgramFiles\VenvIt\Config"; IsDir = $true }
                TEST_DIR          = @{DefVal = "c:\Python"; IsDir = $true }
            }
            $compareVarSet = @{
                TEST_NULL         = @{DefVal = $tempDir; IsDir = $true }
                TEST_TILDE        = @{DefVal = "$tempDir\Projects"; IsDir = $true }
                TEST_PROGRAMFILES = @{DefVal = "$tempDir\Program Files\VenvIt\Config"; IsDir = $true }
                TEST_DIR          = @{DefVal = "$tempDir\Python"; IsDir = $true }
            }
        }
        It "Should convert to test values" {
            $newEnvVar = ConvertFrom-ProdToTestEnvVar -EnvVarSet $envVarSet -TempDir $tempDir

            $newEnvVar.Keys.Count | Should -Be $compareVarSet.Keys.Count
            foreach ($key in $newEnvVar.Keys) {
                $newEnvVar[$key].DefVal | Should -Be $compareVarSet[$key].DefVal
                $newEnvVar[$key].IsDir | Should -Be $compareVarSet[$key].IsDir
            }
        }
        AfterEach {
            Remove-Item -Path $tempDir -Recurse -Force
            Unpublish-EnvironmentVariables -EnvVarSet $envVarSet
        }
    }

    Context "Set-TestSetup_0_0_0" {
        BeforeEach {
            # $OriginalValues = Backup-SessionEnvironmentVariables
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Set-TestSetup_0_0_0

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
            # Restore-SessionEnvironmentVariables -OriginalValues $originalValues
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Set-TestSetup_6_0_0" {
        BeforeEach {
            # $OriginalValues = Backup-SessionEnvironmentVariables
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Set-TestSetup_6_0_0

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
            # Restore-SessionEnvironmentVariables -OriginalValues $originalValues
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Set-TestSetup_7_0_0" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

            # $originalSessionValues = Backup-SessionEnvironmentVariables
            # $originalSystemValues = Backup-SystemEnvironmentVariables
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Set-TestSetup_7_0_0

            $env:PROJECT_NAME | Should -Be $mockInstalVal.ProjectName
            $env:PROJECTS_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Projects")
            $env:VENV_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VEnv")
            $env:VENV_CONFIG_DEFAULT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Config")
            $env:VENV_CONFIG_USER_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VenvIt\Config")
            $env:VENV_ENVIRONMENT | Should -Be "loc_dev"
            # $env:VENV_PYTHON_BASE_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Python")
            $env:VENV_SECRETS_DEFAULT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Secrets")
            $env:VENV_SECRETS_USER_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VenvIt\Secrets")
            $env:VENVIT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Program Files\VenvIt")
            $env:PROJECT_DIR | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "Projects\MyOrg\MyProject")
            $env:VIRTUAL_ENV | Should -Be (Join-Path -Path $mockInstalVal.tempDir -ChildPath "VEnv\MyProject")

            Test-Path -Path "$env:VENV_BASE_DIR"  | Should -Be $true
            Test-Path -Path $env:VENV_CONFIG_DEFAULT_DIR | Should -Be $true
            Test-Path -Path $env:VENV_CONFIG_USER_DIR | Should -Be $true
            Test-Path -Path $env:VENV_PYTHON_BASE_DIR  | Should -Be $true
            Test-Path -Path $env:VENV_SECRETS_DEFAULT_DIR  | Should -Be $true
            Test-Path -Path $env:VENV_SECRETS_USER_DIR  | Should -Be $true
            Test-Path -Path $env:VENVIT_DIR  | Should -Be $true

            $fileName = "VEnv" + $mockInstalVal.ProjectName + "EnvVar.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName ) | Should -Be $true
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "VEnv" + $mockInstalVal.ProjectName + "Install.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName ) | Should -Be $true
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName ) | Should -Be $true
            $fileName = "VEnv" + $mockInstalVal.ProjectName + "CustomSetup.ps1"
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName ) | Should -Be $true
            Test-Path ( Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName ) | Should -Be $true

            Test-Path ( Join-Path -Path $env:VENV_SECRETS_DEFAULT_DIR -ChildPath "secrets.ps1" ) | Should -Be $true
            Test-Path ( Join-Path -Path $env:VENV_SECRETS_USER_DIR -ChildPath "secrets.ps1" ) | Should -Be $true
        }
        AfterEach {
            $newEnvVar = ConvertFrom-ProdToTestEnvVar -EnvVarSet $defEnvVarSet_7_0_0 -TempDir $mockInstalVal.TempDir
            $newEnvVar["PROJECT_NAME"]["DefVal"] = $mockInstalVal.ProjectName
            $newEnvVar["VENV_ORGANIZATION_NAME"]["DefVal"] = $mockInstalVal.Organization
            $newEnvVar["VIRTUAL_ENV"]["DefVal"] = ($newEnvVar["VENV_BASE_DIR"]["DefVal"] + "\" + $mockInstalVal.ProjectName)
            Unpublish-EnvironmentVariables -EnvVarSet $newEnvVar

            # Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
            # Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
            # Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Set-TestSetup_New" {
        BeforeEach {
        }
        It "Should create mock app scripts" {
            $mockInstalVal = Set-TestSetup_New

            $env:PROJECT_NAME | Should -Be $null
            $env:PROJECTS_BASE_DIR | Should -Be $null
            $env:VENV_BASE_DIR | Should -Be $null
            $env:VENV_CONFIG_DEFAULT_DIR | Should -Be $null
            $env:VENV_CONFIG_DIR | Should -Be $null
            $env:VENV_CONFIG_USER_DIR | Should -Be $null
            $env:VENV_ENVIRONMENT | Should -Be $null
            $env:VENV_ORGANIZATION_NAME | Should -Be $null
            $env:VENV_SECRETS_DEFAULT_DIR | Should -Be $null
            $env:VENV_PYTHON_BASE_DIR | Should -Be $null
            $env:VENV_SECRETS_USER_DIR | Should -Be $null
            $env:VENV_SECRETS_DIR | Should -Be $null
            $env:VENVIT_DIR | Should -Be $null
            $env:VIRTUAL_ENV | Should -Be $null

            Test-Path -Path $mockInstalVal.TempDir | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Set-TestSetup_InstallationFiles" {
        It "Should create instlaation source structure" {
            $upgradeDetail = Set-TestSetup_InstallationFiles

            foreach ( $fileName in $upgradeDetail["FileList"] ) {
                $filePath = Join-Path -Path $upgradeDetail["Dir"] -ChildPath $fileName
                Test-Path -Path $filePath
            }
        }
    }

    Context "New-CreateAppScripts" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

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

    Context "Restore-SessionEnvironmentVariables" {
        # TODO
        # Test to be implemented
        BeforeAll {}
        It "TODO Restore-SessionEnvironmentVariables" {}
        AfterAll {}
    }

    Context "Restore-SystemEnvironmentVariables" {
        BeforeEach {
            # if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            # Import-Module $PSScriptRoot\..\src\Utils.psm1

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
            [System.Environment]::SetEnvironmentVariable("PROJECTS_BASE_DIR", $defEnvVarSet_7_0_0["PROJECTS_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("RTE_ENVIRONMENT", $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SECRETS_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("SCRIPTS_DIR", $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_BASE_DIR", $defEnvVarSet_7_0_0["VENV_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", $defEnvVarSet_7_0_0["VENV_CONFIG_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_CONFIG_USER_DIR", $defEnvVarSet_7_0_0["VENV_CONFIG_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ENVIRONMENT", $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_ORGANIZATION_NAME", $mockInstalVal.Organization, [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_PYTHON_BASE_DIR", $defEnvVarSet_7_0_0["VENV_PYTHON_BASE_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_DEFAULT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENV_SECRETS_USER_DIR", $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
            [System.Environment]::SetEnvironmentVariable("VENVIT_DIR", $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"], [System.EnvironmentVariableTarget]::Machine)
        }
        It "Should restore the backedup environment variable values" {
            $origValues = @{
                PROJECT_NAME             = $mockInstalVal.ProjectName
                PROJECTS_BASE_DIR        = $defEnvVarSet_7_0_0["PROJECTS_BASE_DIR"]["DefVal"]
                RTE_ENVIRONMENT          = $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
                SECRETS_DIR              = $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
                SCRIPTS_DIR              = $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
                VENV_BASE_DIR            = $defEnvVarSet_7_0_0["VENV_BASE_DIR"]["DefVal"]
                VENV_CONFIG_USER_DIR     = $defEnvVarSet_7_0_0["VENV_CONFIG_USER_DIR"]["DefVal"]
                VENV_CONFIG_DEFAULT_DIR  = $defEnvVarSet_7_0_0["VENV_CONFIG_DEFAULT_DIR"]["DefVal"]
                VENV_ENVIRONMENT         = $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
                VENV_ORGANIZATION_NAME   = $mockInstalVal.Organization
                VENV_PYTHON_BASE_DIR     = $defEnvVarSet_7_0_0["VENV_PYTHON_BASE_DIR"]["DefVal"]
                VENV_SECRETS_DEFAULT_DIR = $defEnvVarSet_7_0_0["VENV_SECRETS_DEFAULT_DIR"]["DefVal"]
                VENV_SECRETS_USER_DIR    = $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
                VENVIT_DIR               = $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
            }
            Restore-SystemEnvironmentVariables -OriginalValues $origValues
            [System.Environment]::GetEnvironmentVariable("PROJECT_NAME", [System.EnvironmentVariableTarget]::Machine) | Should -Be $mockInstalVal.ProjectName
            [System.Environment]::GetEnvironmentVariable("PROJECTS_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["PROJECTS_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("RTE_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("SECRETS_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("SCRIPTS_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_CONFIG_DEFAULT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_CONFIG_USER_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_CONFIG_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_ENVIRONMENT", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_ENVIRONMENT"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_ORGANIZATION_NAME", [System.EnvironmentVariableTarget]::Machine) | Should -Be $mockInstalVal.Organization
            [System.Environment]::GetEnvironmentVariable("VENV_PYTHON_BASE_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_PYTHON_BASE_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_DEFAULT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_DEFAULT_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENV_SECRETS_USER_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENV_SECRETS_USER_DIR"]["DefVal"]
            [System.Environment]::GetEnvironmentVariable("VENVIT_DIR", [System.EnvironmentVariableTarget]::Machine) | Should -Be $defEnvVarSet_7_0_0["VENVIT_DIR"]["DefVal"]
        }
        AfterEach {
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
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }
    AfterAll {
        Restore-SessionEnvironmentVariables -OriginalValues $originalSessionValues
        Restore-SystemEnvironmentVariables -OriginalValues $originalSystemValues
    }
}
