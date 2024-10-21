Describe "Function testing" {
    Context "Invoke-Install Function Tests" {
        BeforeAll {
            . $PSScriptRoot\..\src\Install.ps1 -Pester
            if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }

            Import-Module "$PSScriptRoot\..\src\Utils.psm1"
            Import-Module "$PSScriptRoot\..\src\Install-Conclude.psm1"

            $MockTag = "1.0.0"
            $TempBaseDir = New-CustomTempDir -Prefix "venvit"
            $OrigVenvIiDir = $env:VENVIT_DIR
            $OrigVenvSecretsDir = $env:VENV_SECRETS_DIR
            $env:VENVIT_DIR = "$TempBaseDir\VENVIT_DIR"
            $env:VENV_SECRETS_DIR = "$TempBaseDir\VENV_SECRETS_DIR"
            New-Item -ItemType Directory -Path $env:VENVIT_DIR -Force -ErrorAction SilentlyContinue
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_DIR -Force -ErrorAction SilentlyContinue
        }

        It "Should Invoke-ConcludeInstall" {
            Write-Host "*** Checkpoint 1 ***"
            Mock Set-ExecutionPolicy {}
            Write-Host "*** Checkpoint 2 ***"
            Mock Invoke-WebRequest {
                return @"
                    [{"tag_name": "$MockTag"}]
"@
            } -ParameterFilter { $Uri -eq "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" }
            Write-Host "*** Checkpoint 3 ***"
            Mock Invoke-WebRequest {
                Copy-Item -Path $PSScriptRoot\..\src\Install-Conclude.psm1 -Destination $OutFile -Verbose
            } -ParameterFilter { $Uri -eq "https://github.com/BrightEdgeeServices/venvit/releases/download/$MockTag/Install-Conclude.psm1" }
            Write-Host "*** Checkpoint 4 ***"
            Mock Import-Module {
                Import-Module "$PSScriptRoot\..\src\Install-Conclude.psm1" -Verbose
            } -ParameterFilter { $Name.StartsWith($env:TEMP) }
            # Mock -ModuleName Install-Conclude -CommandName Invoke-ConcludeInstall {
            Write-Host "*** Checkpoint 5 ***"
            Mock Invoke-ConcludeInstall {
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vn.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vi.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vr.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENV_SECRETS_DIR\dev_env_var.ps1" -Force
            }

            Write-Host "*** Checkpoint 6 ***"
            Invoke-Install

            Write-Host "*** Checkpoint 7 ***"
            Assert-MockCalled -CommandName "Invoke-WebRequest" -Exactly 2
            Assert-MockCalled -CommandName "Invoke-ConcludeInstall" -Exactly 1
        }

        AfterAll {
            $env:VENVIT_DIR = $OrigVenvItDir
            $env:VENV_SECRETS_DIR = $OrigVenvSecretsDir
            Remove-Item -Path $TempBaseDir -Recurse -Force
        }
    }
    Context "Show-Help Function Tests" {
        # Test to be implemented
    }
}

Describe "Install.ps1 testing" {
    # Test to be implemented
}

