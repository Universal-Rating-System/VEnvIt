# Update-Manifest.Tests.ps1

Describe "Function Tests" {
    BeforeAll {
        if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
        Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
    }


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

        $expectedManifestContent = @"
@{
    ModuleVersion = '1.0.0'
    Author        = 'John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>'
    Description   = 'Test project'
}
"@

        $tempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName())
        $tempFilePath = Join-Path -Path $tempDir.FullName -ChildPath "pyproject.toml"
        Set-Content -Path $tempFilePath -Value $sampleToml -NoNewline
    }

    AfterEach {
        Remove-Item -Recurse -Force -Path $tempDir.FullName
    }

    Describe "Convert-PyprojectToml function" {
        It "Should parse pyproject.toml and extract version, authors, and description" {
            $result = Convert-PyprojectToml -filePath $tempFilePath

            $result.Version | Should -Be "1.0.0"
            $result.Authors | Should -Be "John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>"
            $result.Description | Should -Be "Test project"
        }
    }

    Describe "Invoke-UpdateManifest function" {
        It "Should create manifest.psd1 if pyproject.toml exists and is valid" {
            Invoke-UpdateManifest -ConfigBaseDir $tempDir.FullName

            $manifestPath = Join-Path -Path $tempDir.FullName -ChildPath "manifest.psd1"
            Test-Path $manifestPath | Should -BeTrue
            $actualContent = Get-Content -Path $manifestPath -Raw
            $actualContent.Trim() | Should -Be ($expectedManifestContent.Trim())
        }
    }

    # Test for New-ManifestPsd1 function
    Describe "New-ManifestPsd1 function" {
        BeforeAll {
            if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
            Import-Module $PSScriptRoot\..\src\Utils.psm1
        }
        It "Should create manifest.psd1 with correct data" {
            $data = @{
                Version     = '1.0.0'
                Authors     = 'John Doe <john.doe@example.com>, Jane Doe <jane.doe@example.com>'
                Description = 'Test project'
            }

            $manifestPath = Join-Path -Path $tempDir.FullName -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -DestinationPath $manifestPath -data $data

            # Verify that the file was created and contains the expected content
            $actualContent = Get-Content -Path $manifestPath -Raw
            # Compare actual content to the expected content (less strict comparison)
            $actualContent.Trim() | Should -Be ($expectedManifestContent.Trim())
        }
    }

}
