
# Describe "Top level script execution" {
#     BeforeAll {
#         . $PSScriptRoot\..\src\Install.ps1 -Pester
#     }

#     BeforeEach {
#         Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
#     }

#     Context "When Help parameter is passed" {
#         It "Should call Show-Help function" {
#             . $PSScriptRoot\..\src\Conclude-Install.ps1 -Help
#             Assert-MockCalled -CommandName "Show-Help" -Exactly 1
#         }
#     }

#     Context "When no parameters are passed" {
#         It "Should call Show-Help function" {
#             Import-Module "$PSScriptRoot\..\src\Conclude-Install.psm1"
#             Assert-MockCalled -CommandName "Show-Help" -Exactly 1
#         }
#     }
# }

Describe "Install.ps1 script tests" {
    BeforeAll {
        . $PSScriptRoot\..\src\Install.ps1 -Pester
        Import-Module "$PSScriptRoot\..\src\Utils.psm1"
        # Import-Module "$PSScriptRoot\..\src\Conclude-Install.psm1"
        $MockTag = "1.0.0"
        $TempBaseDir = New-CustomTempDir -Prefix "venvit"
        $OrigVenvIiDir = $env:VENVIT_DIR
        $OrigVenvSecretsDir = $env:VENV_SECRETS_DIR
        $env:VENVIT_DIR = "$TempBaseDir\VENVIT_DIR"
        $env:VENV_SECRETS_DIR = "$TempBaseDir\VENV_SECRETS_DIR"
        New-Item -ItemType Directory -Path $env:VENVIT_DIR -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $env:VENV_SECRETS_DIR -Force -ErrorAction SilentlyContinue
    }

    It "Invoke-Install Function Tests" {
        Mock Invoke-WebRequest {
                return @"
                [{"tag_name": "$MockTag"}]
"@
        } -ParameterFilter { $Uri -eq "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" }
        Mock Invoke-WebRequest {
            Copy-Item -Path $PSScriptRoot\..\src\Conclude-Install.psm1 -Destination $OutFile -Verbose
        } -ParameterFilter { $Uri -eq "https://github.com/BrightEdgeeServices/venvit/releases/download/$MockTag/Conclude-Install.psm1" }
        Mock Invoke-ConcludeInstall {
            "exit" | Out-File -FilePath "$env:VENVIT_DIR\vn.ps1" -Force
            "exit" | Out-File -FilePath "$env:VENVIT_DIR\vi.ps1" -Force
            "exit" | Out-File -FilePath "$env:VENVIT_DIR\vr.ps1" -Force
            "exit" | Out-File -FilePath "$env:VENV_SECRETS_DIR\dev_env_var.ps1" -Force
        }

        Invoke-Install

        Assert-MockCalled -CommandName "Invoke-WebRequest" -Exactly 2
        Assert-MockCalled -CommandName "Invoke-ConcludeInstall" -Exactly 1
    }

    AfterAll {
        if (Test-Path -Path $env:VENVIT_DIR) {
            Remove-Item -Path $env:VENVIT_DIR -Force -Recurse
        }
        if (Test-Path -Path $env:VENV_SECRETS_DIR) {
            Remove-Item -Path $env:VENV_SECRETS_DIR -Force -Recurse
        }
        if (Test-Path -Path $TempBaseDir) {
            Remove-Item -Path $TempBaseDir -Force -Recurse
        }
        $env:VENVIT_DIR = $OrigVenvItDir
        $env:VENV_SECRETS_DIR = $OrigVenvSecretsDir
    }
}

