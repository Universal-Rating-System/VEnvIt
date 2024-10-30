# Pester test for vn.Tests.ps1

if (Get-Module -Name "Publish-TestResources") { Remove-Module -Name "Publish-TestResources" }
Import-Module $PSScriptRoot\..\tests\Publish-TestResources.psm1
if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

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
            Mock -CommandName "Invoke-CreateNewVirtualEnvironment" -MockWith { Write-Host "Mock: Invoke-Vn called" }
        }
        It "Should call Invoke-CreateNewVirtualEnvironment function with ProjectName" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName "Tes01"
            Assert-MockCalled -CommandName "Invoke-CreateNewVirtualEnvironment" -Exactly 1
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
        $OriginalValues = Set-BackupEnvironmentVariables
    }

    Context "Get-InstallationValues" {
        It "All parameters set" {
            $InstallValues = Get-InstallationValues -ProjectName "MyProject" -PythonVer "311" -Organization "MyOrg" -DevMode "Y" -ResetScripts "Y"
            $InstallValues.PythonVer | Should -Be "311"
            $InstallValues.Organization | Should -Be "MyOrg"
            $InstallValues.DevMode | Should -Be "Y"
            $InstallValues.ResetScripts | Should -Be "Y"
        }
    }

    Context "Get-Value" {
        It "With set values" {
            $Value = Get-Value -CurrValue "311" -Prompt "Python version" -DefValue "312"
            $Value | Should -Be "311"
        }
        It "Read from console" {
            Mock Read-Host { "314" } -ParameterFilter { $Prompt -eq "Python version (default: 310)" }
            $Value = Get-Value -Prompt "Python version" -DefValue "310"
            $Value | Should -Be "314"
        }
        It "Get default value" {
            Mock Read-Host { "" } -ParameterFilter { $Prompt -eq "Python version (default: 39)" }
            $Value = Get-Value -Prompt "Python version" -DefValue "39"
            $Value | Should -Be "39"
        }
    }

    Context "Invoke-VirtualEnvironment" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
        }

        It "Should install Python virtual environment" {
            Mock Invoke-Script { return "Mock: Activated VEnv"
            } -ParameterFilter { $Script -eq $env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1" }
            Mock Invoke-Script { return "Mock: Deactivated current VEnv"
            } -ParameterFilter { $Script -eq "deactivate" }
            Mock Invoke-Script { return "Mock: Install VEnv"
            } -ParameterFilter { $Script -eq "$env:VENV_PYTHON_BASE_DIR\Python" + $InstallationValues.PythonVer + "\python -m venv --clear $env:VENV_BASE_DIR\$env:PROJECT_NAME" + "_env" }
            Mock Invoke-Script { return "Mock: Upgrade pip"
            } -ParameterFilter { $Script -eq "python.exe -m pip install --upgrade pip" }

            Mock Invoke-Script {
                return "Mock: Default VEnvMyProjectInstall.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectInstall.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectInstall.ps1")).FullName
            }
            Mock Invoke-Script {
                return "Mock: User VEnvMyProjectInstall.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectInstall.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectInstall.ps1")).FullName
            }
            Mock Invoke-Script {
                return "Mock: Default VEnvMyProjectEnvVar.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectEnvVar.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectEnvVar.ps1")).FullName
            }
            Mock Invoke-Script {
                return "Mock: User VEnvMyProjectEnvVar.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectEnvVar.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectEnvVar.ps1")).FullName
            }
            Mock Invoke-Script {
                return "Mock: Default VEnvMyProjectEnvVar.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectCustomSetup.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectCustomSetup.ps1")).FullName
            }
            Mock Invoke-Script {
                return "Mock: Default VEnvMyProjectEnvVar.ps1"
            } -ParameterFilter {
                Write-Host $Script
                Write-Host (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectCustomSetup.ps1")).FullName
                $Script -eq (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectCustomSetup.ps1")).FullName
            }

            Mock Read-YesOrNo { return $true }

            Invoke-CreateNewVirtualEnvironment -ProjectName $mockInstalVal.ProjectName -PythonVer $mockInstalVal.PythonVer -Organization $mockInstalVal.Organization -ResetScripts $mockInstalVal.ResetScripts -DevMode $mockInstalVal.DevMode

            # (Test-Path $PythonExePath) | Should -Be $true
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { ("$env:VENV_PYTHON_BASE_DIR\Python" + $InstallationValues.PythonVer + "\python -m venv --clear $env:VENV_BASE_DIR\$env:PROJECT_NAME" + "_env") }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1") }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { ("python.exe -m pip install --upgrade pip") }

            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectInstall.ps1")).FullName }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectInstall.ps1")).FullName }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectEnvVar.ps1")).FullName }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectEnvVar.ps1")).FullName }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_DEFAULT_DIR\VEnvMyProjectCustomSetup.ps1")).FullName }
            Assert-MockCalled -CommandName Invoke-Script -ParameterFilter { (Get-Item -Path ("$env:VENV_CONFIG_USER_DIR\VEnvMyProjectCustomSetup.ps1")).FullName }
            Get-Location | Should -Be $mockInstalVal.ProjectDir
        }

        AfterEach {
            Set-Location -Path $env:TEMP
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-ProjectInstallScript" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            Mock CreatePreCommitConfigYaml { return $true }
        }
        It "Should create project install.ps1" {
            New-ProjectInstallScript -InstallationValues $mockInstalVal
            $installScriptPath = (Join-Path -Path $mockInstalVal.ProjectDir -ChildPath "install.ps1")
            (Test-Path $installScriptPath) | Should -Be $true
            Assert-MockCalled -CommandName CreatePreCommitConfigYaml
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-SupportScript" {
        # TODO
        # Test to be implemented
    }

    Context "New-VEnvCustomSetupScripts" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            # New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
        }

        It "Should create zip archives" {
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            $scriptPath = Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "CustomSetup.ps1")
            (Test-Path $scriptPath) | Should -Be $true
            $scriptPath = Join-Path -Path "$env:VENV_CONFIG_USER_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "CustomSetup.ps1")
            (Test-Path $scriptPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_USER_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-VEnvEnvVarScripts" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

        }

        It "Should chreate zip archives" {
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvEnvVarScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            $scriptPath = Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "EnvVar.ps1")
            (Test-Path $scriptPath) | Should -Be $true
            $scriptPath = Join-Path -Path "$env:VENV_CONFIG_USER_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "EnvVar.ps1")
            (Test-Path $scriptPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_USER_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-VEnvInstallScripts" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp
        }
        It "Should chreate zip archives" {
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvInstallScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            $configPath = Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "Install.ps1")
            (Test-Path $configPath) | Should -Be $true
            $configPath = Join-Path -Path "$env:VENV_CONFIG_USER_DIR" -ChildPath ("VEnv" + $mockInstalVal.ProjectName + "Install.ps1")
            (Test-Path $configPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_DEFAULT_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
            $zipPath = (Join-Path -Path "$env:VENV_CONFIG_USER_DIR\Archive" -ChildPath ($env:PROJECT_NAME + "_" + $timeStamp + ".zip"))
            (Test-Path $zipPath) | Should -Be $true
        }

        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "New-VirtualEnvironment" {
        # TODO
        # Test to be implemented
    }

    Context "Set-Environment" {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -Pester
            $mockInstalVal = Invoke-TestSetup
            $timeStamp = Get-Date -Format "yyyyMMddHHmm"
            New-VEnvCustomSetupScripts -InstallationValues $mockInstalVal -TimeStamp $timeStamp

            # Reset necessary values that are populated in Invoke-TestSetup
            $env:PROJECT_NAME = $null
            $env:VENV_ORGANIZATION_NAME = $null
            # $mockInstalVal | Remove-Member -MemberType NoteProperty -Name "OrganizationDir"
            # $mockInstalVal | Remove-Member -MemberType NoteProperty -Name "ProjectDir"
            if (Test-Path $mockInstalVal.OrganizationDir) {
                Remove-Item -Path $mockInstalVal.OrganizationDir -Recurse -Force | Out-Null
            }
            # if (-not (Test-Path $mockInstalVal.ProjectDir)) {
            #     Remove-Item -Path $mockInstalVal.ProjectDir -Recurse -Force  | Out-Null
            # }
            $mockInstalVal.psobject.properties.remove('OrganizationDir')
            $mockInstalVal.psobject.properties.remove('ProjectDir')
        }

        It "Should confirm environment settings" {
            $installationValues = Set-Environment -InstallationValues $mockInstalVal

            $env:PROJECT_NAME | Should -Be $mockInstalVal.ProjectName
            $env:VENV_ORGANIZATION_NAME | Should -Be $mockInstalVal.Organization
            $installationValues.OrganizationDir | Should -Be ($mockInstalVal.TempDir + "\Projects\MyOrg")
            $installationValues.ProjectDir | Should -Be ($mockInstalVal.TempDir + "\Projects\MyOrg\MyProject")
            (Test-Path $mockInstalVal.OrganizationDir) | Should -Be $true
            (Test-Path $mockInstalVal.ProjectDir) | Should -Be $true
        }
        AfterEach {
            Remove-Item -Path $mockInstalVal.TempDir -Recurse -Force
        }
    }

    Context "Show-EnvironmentVariables" {
        # TODO
        # Test to be implemented
    }

    AfterAll {
        Get-BackedupEnvironmentVariables -OriginalValues $originalValues
    }
}

