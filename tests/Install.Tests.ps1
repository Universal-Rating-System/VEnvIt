Describe "Function testing" {
    Context "Invoke-Install" {
        BeforeAll {
            . $PSScriptRoot\..\src\Install.ps1 -Pester
            if (Get-Module -Name "Install-Conclude") { Remove-Module -Name "Install-Conclude" }
            Import-Module $PSScriptRoot\..\src\Install-Conclude.psm1
            if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1

            $MockTag = "1.0.0"
            $TempBaseDir = New-CustomTempDir -Prefix "VenvIt"
            $OrigVenvIiDir = $env:VENVIT_DIR
            $OrigVenvSecretsDir = $env:VENV_SECRETS_DIR
            $env:VENVIT_DIR = "$TempBaseDir\VENVIT_DIR"
            $env:VENV_SECRETS_DIR = "$TempBaseDir\VENV_SECRETS_DIR"
            New-Item -ItemType Directory -Path $env:VENVIT_DIR -Force -ErrorAction SilentlyContinue
            New-Item -ItemType Directory -Path $env:VENV_SECRETS_DIR -Force -ErrorAction SilentlyContinue
        }

        It "Should Invoke-ConcludeInstall" {
            Mock Set-ExecutionPolicy {}
            Mock Invoke-WebRequest {
                return @"
            [ { "tag_name": "$MockTag" }]
"@
            } -ParameterFilter { $Uri -eq "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" }
            Mock Invoke-WebRequest {
                New-ManifestPsd1 -DestinationPath (Join-Path -Path "$PSScriptRoot\.." -ChildPath (Get-ManifestFileName)) -data $ManifestData700
                $compress = @{
                    Path             = "$PSScriptRoot\..\*.md", "$PSScriptRoot\..\LICENSE", "$PSScriptRoot\..\Manifest.psd1", "$PSScriptRoot\..\src"
                    CompressionLevel = "Fastest"
                    DestinationPath  = $OutFile
                }
                Compress-Archive @compress | Out-Null
            } -ParameterFilter { $Uri -eq "https://github.com/BrightEdgeeServices/venvit/releases/download/$MockTag/Installation-Files.zip" }
            Mock Import-Module {
                $NormalizedModulePath = (Get-Item -Path $PSScriptRoot\..\src\Install-Conclude.psm1).FullName
                Import-Module $NormalizedModulePath
            } -ParameterFilter {
                # Normalize both $Name and $env:TEMP to ensure they are compared in the same format
                $NormalizedTempPath = (Get-Item -Path $env:TEMP).FullName
                $NormalizedInputPath = (Get-Item -Path $Name).FullName
                $NormalizedInputPath.StartsWith($NormalizedTempPath)
            }
            # Mock -ModuleName Install-Conclude -CommandName Invoke-ConcludeInstall {
            Mock Invoke-ConcludeInstall {
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vn.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vi.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENVIT_DIR\vr.ps1" -Force
                "exit" | Out-File -FilePath "$env:VENV_SECRETS_DIR\secrets.ps1" -Force
            }

            Invoke-Install

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

