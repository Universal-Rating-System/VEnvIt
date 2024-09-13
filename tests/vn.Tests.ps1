# Pester test for vn.Tests.ps1

Describe "Top level script execution" {
    BeforeAll {
        . $PSScriptRoot\..\src\vn.ps1 -Pester
    }
    BeforeEach {
        Mock -CommandName "Show-Help" -MockWith { Write-Host "Mock: Show-Help called" }
    }
    Context "When Help parameter is passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -Help
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When ProjectName is passed and Help is not passed" {
        BeforeEach {
            Mock -CommandName "Invoke-Vn" -MockWith { Write-Host "Mock: Invoke-Vn called" }
        }
        It "Should call Invoke-Vn function with ProjectName" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName "Tes01"
            # Assert-MockCalled -CommandName "Invoke-MyScript" -Exactly 1 -ParameterFilter { $Var01 -eq 'TestValue' }
            Assert-MockCalled -CommandName "Invoke-Vn" -Exactly 1
        }
    }

    Context "When Var01 is an empty string and Help is not passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1 -ProjectName $null
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }

    Context "When no parameters are passed" {
        It "Should call Show-Help function" {
            . $PSScriptRoot\..\src\vn.ps1
            Assert-MockCalled -CommandName "Show-Help" -Exactly 1
        }
    }
}

