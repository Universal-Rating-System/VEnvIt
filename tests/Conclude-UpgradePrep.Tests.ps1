# Upgrade.Tests.ps1

BeforeAll {
    # . $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
    # Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
}

# Describe "Upgrade Scenario's" {
#     BeforeAll {
#         # Mock current Manifest
#         $currentManifestContent = @"
# @{
#     ModuleVersion = '6.0.0'
#     Author        = 'Author Name'
#     Description   = 'Mock Manifest for current version.'
# }
# "@

#         # Mock latest Manifest
#         $latestManifestContent = @"
# @{
#     ModuleVersion = '7.0.0'
#     Author        = 'Author Name'
#     Description   = 'Mock Manifest for latest version.'
# }
# "@

#         # Create a temporary directory
#         $tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
#         $CurrentManifestPath = Join-Path -Path $tempDir.FullName -ChildPath 'current_Manifest.psd1'
#         $LatestManifestPath = Join-Path -Path $tempDir.FullName -ChildPath 'latest_Manifest.psd1'

#         # Write mock manifest files to the TEMP directory
#         Set-Content -Path $CurrentManifestPath -Value $currentManifestContent
#         Set-Content -Path $LatestManifestPath -Value $latestManifestContent
#     }

#     BeforeEach {
#         Mock -CommandName Upgrade_6_0_1
#         Mock -CommandName Upgrade_6_1_0
#         Mock -CommandName Upgrade_7_0_0
#     }

#     # It 'Should correctly import current and latest manifest files' {
#     #     # Act
#     #     Update-Package -CurrentManifestPath $CurrentManifestPath -LatestManifestPath $LatestManifestPath

#     #     # Assert
#     #     $currentManifest = Import-PowerShellDataFile -Path $CurrentManifestPath
#     #     $latestManifest = Import-PowerShellDataFile -Path $LatestManifestPath

#     #     $currentManifest.ModuleVersion | Should -BeExactly '6.0.0'
#     #     $latestManifest.ModuleVersion | Should -BeExactly '7.0.0'
#     # }

#     It 'Should throw an error if manifest paths are not provided' {
#         # Act & Assert
#         { Update-Package -CurrentManifestPath $null -LatestManifestPath $LatestManifestPath } | Should -Throw
#         { Update-Package -CurrentManifestPath $CurrentManifestPath -LatestManifestPath $null } | Should -Throw
#     }

#     It 'Should not call upgrade functions if current version equals latest version' {
#         # Arrange - Modify current manifest to be the same as the latest version
#         Set-Content -Path $CurrentManifestPath -Value @"
# @{
#     ModuleVersion = '7.0.0'
#     Author        = 'Author Name'
#     Description   = 'Mock Manifest for current version.'
# }
# "@

#         # Act
#         Update-Package -CurrentManifestPath $CurrentManifestPath -LatestManifestPath $LatestManifestPath

#         # Assert that no upgrade functions were called
#         Assert-MockCalled -CommandName Upgrade_6_0_1 -Times 0
#         Assert-MockCalled -CommandName Upgrade_6_1_0 -Times 0
#         Assert-MockCalled -CommandName Upgrade_7_0_0 -Times 0
#     }

#     AfterAll {
#         # Clean up temporary files
#         Remove-Item -Path $CurrentManifestPath -Force
#         Remove-Item -Path $LatestManifestPath -Force
#         Remove-Item -Path $tempDir.FullName -Force
#     }
# }

Describe "Function testing" {
    Context "Update-Package" {
        BeforeAll {
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
            # Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            Import-Module $PSScriptRoot\..\src\Utils.psm1

            $ManifestData500 = @{
                Version     = "5.0.0"
                Authors        = "Ann Other <ann@other.com>"
                Description   = "Description of 5.0.0"
            }
            $ManifestData600 = @{
                Version     = "6.0.0"
                Authors        = "Ann Other <ann@other.com>"
                Description   = "Description of 6.0.0"
            }
            $ManifestData700 = @{
                Version = "7.0.0"
                Authors        = "Ann Other <ann@other.com>"
                Description   = "Description of 7.0.0"
            }
            $OrigVENVIT_DIR = $env:VENVIT_DIR

        }
        BeforeEach {
            # . $PSScriptRoot\..\src\Update-Manifest.ps1 -Pester
            $TempDir = New-CustomTempDir -Prefix "venvit"
            $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $TempDir -ChildPath "TempUpgradeDir")
            $env:VENVIT_DIR = Join-Path -Path $TempDir -ChildPath "venvit"
            New-Item -ItemType Directory -Path $env:VENVIT_DIR
        }
        # It "Should perform upgrade tasks" {
        #     # Next Step:
        #     # Create the manifest.psd1 in temp dir using Update-Manifest.ps1/New-ManifestPsd1
        #     $Result = Update-Package -UpgradeManifestDir $UpgradeScriptDir
        # }
        # It 'Should import current and upgrade manifest files' {
        #     # Act
        #     Update-Package -UpgradeManifestDir $UpgradeScriptDir

        #     # Assert
        #     $currentManifest = Import-PowerShellDataFile -Path $CurrentManifestPath
        #     $latestManifest = Import-PowerShellDataFile -Path $LatestManifestPath

        #     $currentManifest.ModuleVersion | Should -BeExactly '6.0.0'
        #     $latestManifest.ModuleVersion | Should -BeExactly '7.0.0'
        # }
        It 'Should apply 6.0.0 and 7.0.0' {
            Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_6_0_0 { return $true }
            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_7_0_0 { return $true }
            # Mock -CommandName Invoke-Upgrade_7_0_0
            $CurrentManifestPath = Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -FilePath $CurrentManifestPath -Data $ManifestData500
            $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -FilePath $UpgradeManifestPath -data $ManifestData700
            Update-Package -UpgradeScriptDir $UpgradeScriptDir

            # Assert that the correct upgrade functions were called in order
            Assert-MockCalled -Scope It -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_6_0_0 -Times 1 -Exactly
            Assert-MockCalled -Scope It -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_7_0_0 -Times 1 -Exactly
        }
        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
        }
    }

    AfterAll {
        $env:VENVIT_DIR = $OrigVENVIT_DIR
    }
}
