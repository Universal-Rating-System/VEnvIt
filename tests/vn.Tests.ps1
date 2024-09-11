Describe 'VenvNew' {
    Context CreateDirIfNotExist {
        BeforeEach {
            . $PSScriptRoot\..\src\vn.ps1 -h
            $originalLocation = Get-Location

            # Navigate to a test directory
            $testPath = Join-Path -Path $env:TEMP -ChildPath "PesterTestDir"
            New-Item -ItemType Directory -Path $testPath -Force | Out-Null
            Set-Location -Path $testPath
        }

        AfterEach {
            # Cleanup and return to original location
            Set-Location -Path $originalLocation
            Remove-Item -Path $testPath -Recurse -Force
        }

        It "Creates a directory if it does not exist" {
            $newDir = Join-Path -Path $testPath -ChildPath "NewTestDir"
            CreateDirIfNotExist -_dir $newDir
            Test-Path -Path $newDir | Should -Be $true
        }

        It "Does not create a directory if it already exists" {
            $existingDir = Join-Path -Path $testPath -ChildPath "ExistingDir"
            New-Item -ItemType Directory -Path $existingDir | Out-Null
            Mock New-Item -MockWith {}
            CreateDirIfNotExist -_dir $existingDir
            Assert-MockCalled -CommandName New-Item -Times 0 -Exactly
        }
    }
}
