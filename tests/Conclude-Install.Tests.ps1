# Pester test for Conclude-Install.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\Conclude-Install.ps1 -Pester
    }
    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }
    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\Conclude-Install.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When Release & SourceScriptDir is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-ConcludeInstall" -MockWith { Write-Host "Mock: Invoke-ConcludeInstall called" }
        }
        It "Should call Invoke-ConcludeInstall function with ProjectName" {
            . $PSScriptRoot\..\src\Conclude-Install.ps1 1.0.0 2.0.0
            # Assert-MockCalled -CommandName "Invoke-MyScript" -Exactly 1 -ParameterFilter { $Var01 -eq 'TestValue' }
            Assert-MockCalled -CommandName "Invoke-ConcludeInstall" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\Conclude-Install.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

