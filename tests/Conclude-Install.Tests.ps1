# Pester test for Conclude-Install.Tests.ps1

Describe "Function testing" {

    Context "Get-OrPromptEnvVar" {
        # Test to be implemented
    }

    Context "Invoke-ConcludeInstall" {
        # Test to be implemented
    }

    Context "Remove-EnvVarIfExists" {
        # Test to be implemented
    }

    # Bit of a useless test due to "IsInRole" not being able to be mocked.
    Describe "Test-Admin Function" {
        BeforeAll {
            if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-Install" }
            Import-Module $PSScriptRoot\..\src\Conclude-Install.psm1
        }
        It "Returns true if an administrator" {
            Mock -ModuleName Conclude-Install -CommandName Invoke-IsInRole { return $true }

            Test-Admin | Should -Be $true
        }

        It "Returns false if not an administrator" {
            Mock -ModuleName Conclude-Install -CommandName Invoke-IsInRole { return $false }

            Test-Admin | Should -Be $false
        }
    }
}
