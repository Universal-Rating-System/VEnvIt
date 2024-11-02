Describe "Function Tests" {
    BeforeAll {
        if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
        Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
    }


    # Create temporary directory and pyproject.toml file before each test
    BeforeEach {
        # Sample TOML data
        $sampleToml = @"
version = '1.0.0'
description = 'Test project'
authors = [
    'John Doe <john.doe@example.com>',
    'Jane Doe <jane.doe@example.com>',
]
"@

        # Expected manifest content for verification
        $expectedManifestContent = @"
@{
    ModuleVersion = '1.0.0'
    Author        = 'John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>'
    Description   = 'Test project'
}
"@

        # Create a temporary directory
        $tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
        $tempFilePath = Join-Path -Path $tempDir.FullName -ChildPath "pyproject.toml"
        Set-Content -Path $tempFilePath -Value $sampleToml -NoNewline
    }

    # Cleanup the temporary directory after each test
    AfterEach {
        Remove-Item -Recurse -Force -Path $tempDir.FullName
    }

    # Test for Convert-PyprojectToml function
    Describe "Convert-PyprojectToml function" {
        It "Should parse pyproject.toml and extract version, authors, and description" {
            # Call the function with the path to the temporary pyproject.toml file
            $result = Convert-PyprojectToml -filePath $tempFilePath

            # Ensure that all extracted fields match the expected values
            $result.Version | Should -Be "1.0.0"
            $result.Authors | Should -Be "John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>"
            $result.Description | Should -Be "Test project"
        }
    }

    # Test for Invoke-UpdateManifest function
    Describe "Invoke-UpdateManifest function" {
        It "Should create manifest.psd1 if pyproject.toml exists and is valid" {
            # Call the function with the path to the temporary directory
            Invoke-UpdateManifest -ConfigBaseDir $tempDir.FullName

            # Verify that the manifest.psd1 was created
            $manifestPath = Join-Path -Path $tempDir.FullName -ChildPath "manifest.psd1"
            Test-Path $manifestPath | Should -BeTrue
            # Verify the content of manifest.psd1
            $actualContent = Get-Content -Path $manifestPath -Raw
            # Compare actual content to the expected content (less strict comparison)
            $actualContent.Trim() | Should -Be ($expectedManifestContent.Trim())
        }
    }

    # Test for New-ManifestPsd1 function
    Describe "New-ManifestPsd1 function" {
        It "Should create manifest.psd1 with correct data" {
            $data = @{
                Version     = '1.0.0'
                Authors     = 'John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>'
                Description = 'Test project'
            }

            $manifestPath = Join-Path -Path $tempDir.FullName -ChildPath "manifest.psd1"
            New-ManifestPsd1 -filePath $manifestPath -data $data

            # Verify that the file was created and contains the expected content
            $actualContent = Get-Content -Path $manifestPath -Raw
            # Compare actual content to the expected content (less strict comparison)
            $actualContent.Trim() | Should -Be ($expectedManifestContent.Trim())
        }
    }

}
