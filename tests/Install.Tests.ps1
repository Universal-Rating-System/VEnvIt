Describe "Install.ps1 script tests" {

    # Mock variables
    $tempDirPath = "C:\Temp\FakeTempDir"
    $sourceScriptPath = Join-Path -Path $tempDirPath -ChildPath "Conclude-Install.ps1"
    $mockTag = "v1.0.0"

    BeforeEach {
        # Mock the environment variables
        $env:VENVIT_DIR = "C:\VENVIT"
        $env:VENV_SECRETS_DIR = "C:\VENV_SECRETS"

        # Mock New-Item for creating the temporary directory
        Mock New-Item {
            return @{ FullName = $tempDirPath }
        } -Verifiable

        # Mock Invoke-WebRequest for fetching GitHub releases and downloading the Conclude-Install.ps1
        Mock Invoke-WebRequest {
            if ($args[0] -like "https://api.github.com/repos/*/releases") {
                return @{ Content = "[{""tag_name"": ""$mockTag""}]" }  # Simulate a JSON response with a tag
            }
            elseif ($args[0] -like "https://github.com/*/Conclude-Install.ps1") {
                return  # Simulate downloading the script
            }
        } -Verifiable

        # Mock Remove-Item to simulate the cleanup of the temp directory
        Mock Remove-Item -Verifiable

        # Mock Unblock-File for unblocking files
        Mock Unblock-File -Verifiable

        # Mock Get-Item for listing .ps1 files to unblock
        Mock Get-Item {
            return @(
                New-Object psobject -Property @{ FullName = "$env:VENVIT_DIR\vn.ps1" },
                New-Object psobject -Property @{ FullName = "$env:VENVIT_DIR\vi.ps1" }
            )
        } -Verifiable
    }

    It "Should create a temporary directory" {
        . "$PSScriptRoot\..\src\Install.ps1"
        Get-MockCall New-Item | Should -HaveReceived -Times 1
    }

    It "Should fetch the latest release tag from GitHub" {
        . "$PSScriptRoot\..\src\Install.ps1"
        Get-MockCall Invoke-WebRequest | Where-Object { $_.Arguments[0] -like "https://api.github.com/repos/*/releases" } | Should -HaveReceived -Times 1
    }

    It "Should download the Conclude-Install.ps1 script" {
        . "$PSScriptRoot\..\src\Install.ps1"
        Get-MockCall Invoke-WebRequest | Where-Object { $_.Arguments[0] -like "https://github.com/*/Conclude-Install.ps1" } | Should -HaveReceived -Times 1
    }

    It "Should invoke the Conclude-Install.ps1 script with the correct parameters" {
        Mock {
            param ($release, $sourceScriptDir)
            $release | Should -Be $mockTag
            $sourceScriptDir | Should -Be $tempDirPath
        }

        . "$PSScriptRoot\..\src\Install.ps1"

        # Verify that the Conclude-Install.ps1 script was called with the correct arguments
        Get-MockCall & | Should -HaveReceived -Times 1
    }

    It "Should clean up the temporary directory" {
        . "$PSScriptRoot\..\src\Install.ps1"
        Get-MockCall Remove-Item | Where-Object { $_.Arguments[0] -eq $tempDirPath } | Should -HaveReceived -Times 1
    }

    It "Should unblock the appropriate files in VENVIT_DIR and VENV_SECRETS_DIR" {
        . "$PSScriptRoot\..\src\Install.ps1"

        # Verify that Unblock-File was called for the appropriate files
        Get-MockCall Unblock-File | Should -HaveReceived -Times 2
        Get-MockCall Unblock-File | Where-Object { $_.Arguments[0] -like "$env:VENVIT_DIR\*.ps1" } | Should -HaveReceived -Times 1
        Get-MockCall Unblock-File | Where-Object { $_.Arguments[0] -like "$env:VENV_SECRETS_DIR\dev_env_var.ps1" } | Should -HaveReceived -Times 1
    }

    # Optional: Clean up any environment variables after the tests
    AfterAll {
        Remove-Variable -Name env:VENVIT_DIR -ErrorAction SilentlyContinue
        Remove-Variable -Name env:VENV_SECRETS_DIR -ErrorAction SilentlyContinue
    }
}
