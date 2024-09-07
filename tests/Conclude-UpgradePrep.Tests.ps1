# Upgrade.Tests.ps1

BeforeAll {
    . "$PSScriptRoot\..\src\Conclude-UpgradePrep.ps1"
}

Describe 'Upgrade.ps1 Tests' {

    # Create the mock Manifest.psd1 files in a temporary directory
    BeforeAll {
        # Mock current Manifest
        $currentManifestContent = @"
@{
    ModuleVersion = '6.0.0'
    Author        = 'Author Name'
    Description   = 'Mock Manifest for current version.'
}
"@

        # Mock latest Manifest
        $latestManifestContent = @"
@{
    ModuleVersion = '7.0.0'
    Author        = 'Author Name'
    Description   = 'Mock Manifest for latest version.'
}
"@

        # Create a temporary directory
        $tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
        $currentManifestPath = Join-Path -Path $tempDir.FullName -ChildPath 'current_Manifest.psd1'
        $latestManifestPath = Join-Path -Path $tempDir.FullName -ChildPath 'latest_Manifest.psd1'

        # Write mock manifest files to the TEMP directory
        Set-Content -Path $currentManifestPath -Value $currentManifestContent
        Set-Content -Path $latestManifestPath -Value $latestManifestContent
    }

    AfterAll {
        # Clean up temporary files
        Remove-Item -Path $currentManifestPath -Force
        Remove-Item -Path $latestManifestPath -Force
        Remove-Item -Path $tempDir.FullName -Force
    }

    # Mock version upgrade functions
    BeforeEach {
        Mock -CommandName Upgrade_6_0_1
        Mock -CommandName Upgrade_6_1_0
        Mock -CommandName Upgrade_7_0_0
    }

    It 'Should correctly import current and latest manifest files' {
        # Act
        Update-Package -currentManifestPath $currentManifestPath -latestManifestPath $latestManifestPath

        # Assert
        $currentManifest = Import-PowerShellDataFile -Path $currentManifestPath
        $latestManifest = Import-PowerShellDataFile -Path $latestManifestPath

        $currentManifest.ModuleVersion | Should -BeExactly '6.0.0'
        $latestManifest.ModuleVersion | Should -BeExactly '7.0.0'
    }

    It 'Should apply all necessary upgrades from 6.0.0 to 7.0.0' {
        # Act
        Update-Package -currentManifestPath $currentManifestPath -latestManifestPath $latestManifestPath

        # Assert that the correct upgrade functions were called in order
        Assert-MockCalled -CommandName Upgrade_6_0_1 -Exactly 1
        Assert-MockCalled -CommandName Upgrade_6_1_0 -Exactly 1
        Assert-MockCalled -CommandName Upgrade_7_0_0 -Exactly 1
    }

    It 'Should throw an error if manifest paths are not provided' {
        # Act & Assert
        { Update-Package -currentManifestPath $null -latestManifestPath $latestManifestPath } | Should -Throw
        { Update-Package -currentManifestPath $currentManifestPath -latestManifestPath $null } | Should -Throw
    }

    It 'Should not call upgrade functions if current version equals latest version' {
        # Arrange - Modify current manifest to be the same as the latest version
        Set-Content -Path $currentManifestPath -Value @"
@{
    ModuleVersion = '7.0.0'
    Author        = 'Author Name'
    Description   = 'Mock Manifest for current version.'
}
"@

        # Act
        Update-Package -currentManifestPath $currentManifestPath -latestManifestPath $latestManifestPath

        # Assert that no upgrade functions were called
        Assert-MockCalled -CommandName Upgrade_6_0_1 -Times 0
        Assert-MockCalled -CommandName Upgrade_6_1_0 -Times 0
        Assert-MockCalled -CommandName Upgrade_7_0_0 -Times 0
    }
}
