Describe "Function Tests" {
    BeforeAll {
        # "$PSScriptRoot\..\src\Utils.psm1"
        Import-Module "$PSScriptRoot\..\src\Utils.psm1"
    }
    Context "New-CustomTempDir Test" {
        It "Temporary dir with prefix" {
            $Prefix = "venvit"
            $TempDir = New-CustomTempDir -Prefix $Prefix
            Test-Path -Path $tempDir | Should -Be $true
        }
        AfterEach {
            # Cleanup: Remove the created directory if it exists
            if (Test-Path -Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    }
    AfterEach {
        if (Test-Path -Path $TempDir) {
            Remove-Item -Path $TempDir -Recurse -Force
        }
    }
}
