# Upgrade.Tests.ps1


Describe "Function testing" {
    BeforeAll {
        $ManifestData500 = @{
            Version     = "5.0.0"
            Authors     = "Ann Other <ann@other.com>"
            Description = "Description of 5.0.0"
        }
        $ManifestData600 = @{
            Version     = "6.0.0"
            Authors     = "Ann Other <ann@other.com>"
            Description = "Description of 6.0.0"
        }
        $ManifestData700 = @{
            Version     = "7.0.0"
            Authors     = "Ann Other <ann@other.com>"
            Description = "Description of 7.0.0"
        }
    }
    Context "Get-ManifestFileName" {
        # Test to be implemented
    }

    Context "Get-Version" {
        BeforeAll {
            if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
            if (Get-Module -Name "Update-Manifest") { Remove-Module -Name "Update-Manifest" }
            Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1

            function New-TestVersionStructure_0_0_0 {
                Import-Module $PSScriptRoot\..\src\Utils.psm1

                $TempDir = New-CustomTempDir -Prefix "VenvIt"
                Return $TempDir
            }

            function New-TestVersionStructure_6_0_0 {
                Import-Module $PSScriptRoot\..\src\Utils.psm1

                $TempDir = New-CustomTempDir -Prefix "VenvIt"
                $ManifestPath = Join-Path -Path $TempDir -ChildPath (Get-ManifestFileName)
                New-ManifestPsd1 -FilePath $ManifestPath $ManifestData600
                Return $TempDir
            }
        }
        It "Should get 0.0.0" {
            $ScriptDir = New-TestVersionStructure_0_0_0
            $Version = Get-Version -ScriptDir $ScriptDir
            $Version | Should -Be "0.0.0"
            Remove-Item -Path $ScriptDir -Force
        }

        It "Should get 6.0.0" {
            $ScriptDir = New-TestVersionStructure_6_0_0
            $Version = Get-Version -ScriptDir $ScriptDir
            $Version | Should -Be "6.0.0"
            Remove-Item -Path $ScriptDir -Force -Recurse
        }

    }

    Context "Invoke-Upgrade_0_0_0" {
        # Test to be implemented
    }

    Context "Invoke-Upgrade_6_0_0" {
        # Test to be implemented
    }

    Context "Invoke-Upgrade_7_0_0" {
        # Test to be implemented
    }

    Context "Update-PackagePrep" {
        BeforeAll {
            Import-Module $PSScriptRoot\..\src\Update-Manifest.psm1
            # Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
            Import-Module $PSScriptRoot\..\src\Utils.psm1

            # $ManifestData500 = @{
            #     Version     = "5.0.0"
            #     Authors        = "Ann Other <ann@other.com>"
            #     Description   = "Description of 5.0.0"
            # }
            # $ManifestData600 = @{
            #     Version     = "6.0.0"
            #     Authors        = "Ann Other <ann@other.com>"
            #     Description   = "Description of 6.0.0"
            # }
            # $ManifestData700 = @{
            #     Version = "7.0.0"
            #     Authors        = "Ann Other <ann@other.com>"
            #     Description   = "Description of 7.0.0"
            # }
            $OrigVENVIT_DIR = $env:VENVIT_DIR

        }
        BeforeEach {
            $TempDir = New-CustomTempDir -Prefix "venvit"
            $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $TempDir -ChildPath "TempUpgradeDir")
            $env:VENVIT_DIR = Join-Path -Path $TempDir -ChildPath "venvit"
            New-Item -ItemType Directory -Path $env:VENVIT_DIR
        }

        It 'Should apply 6.0.0 and 7.0.0' {
            Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1

            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_6_0_0 { return $true }
            Mock -ModuleName Conclude-UpgradePrep -CommandName Invoke-Upgrade_7_0_0 { return $true }
            # Mock -CommandName Invoke-Upgrade_7_0_0
            $CurrentManifestPath = Join-Path -Path $env:VENVIT_DIR -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -FilePath $CurrentManifestPath -Data $ManifestData500
            $UpgradeManifestPath = Join-Path -Path $UpgradeScriptDir -ChildPath (Get-ManifestFileName)
            New-ManifestPsd1 -FilePath $UpgradeManifestPath -data $ManifestData700
            Update-PackagePrep -UpgradeScriptDir $UpgradeScriptDir

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
