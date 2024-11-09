if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1
function Convert-PyprojectToml {
    param (
        [string]$filePath
    )

    $content = Get-Content -Path $filePath

    $version = $null
    $authors = @()
    $description = $null
    $isAuthorsBlock = $false

    foreach ($line in $content) {
        # Extract version
        if ($line -match "^version\s*=\s*['""](.+?)['""]") {
            $version = $matches[1]
        }
        # Extract description
        elseif ($line -match "^description\s*=\s*['""](.+?)['""]") {
            $description = $matches[1]
        }
        # Start of authors block
        elseif ($line -match "^authors\s*=\s*\[") {
            $isAuthorsBlock = $true
        }
        # End of authors block
        elseif ($isAuthorsBlock -and $line -match "\]") {
            $isAuthorsBlock = $false
        }
        # Inside authors block, clean up and add authors
        elseif ($isAuthorsBlock) {
            $cleanedAuthor = $line.Trim().Trim("'", ' ', ',')  # Remove quotes and extra characters
            if ($cleanedAuthor -ne "") {
                $authors += $cleanedAuthor
            }
        }
    }

    # Combine authors into a single string with a comma and space
    $authorString = $authors -join ", "

    return @{
        Version     = $version
        Authors     = $authorString
        Description = $description
    }
}

function Invoke-UpdateManifest {
    param (
        [string]$ConfigBaseDir  # Root directory parameter
    )

    # Construct the paths for pyproject.toml and manifest.psd1 based on the provided directory
    $pyprojectPath = Join-Path -Path $ConfigBaseDir -ChildPath "pyproject.toml"
    $manifestPath = Join-Path -Path $ConfigBaseDir -ChildPath (Get-ManifestFileName)

    # Check if pyproject.toml exists
    if (Test-Path -Path $pyprojectPath) {
        # Extract data from pyproject.toml
        $pyprojectData = Convert-PyprojectToml -filePath $pyprojectPath

        # Check if all necessary data was extracted
        if ($pyprojectData.Version -and $pyprojectData.Authors -and $pyprojectData.Description) {
            # Create the manifest.psd1
            New-ManifestPsd1 -DestinationPath $manifestPath -data $pyprojectData
            Write-Host "Manifest.psd1 created successfully at $manifestPath"
        }
        else {
            Write-Host "Failed to extract required fields from pyproject.toml"
        }
    }
    else {
        Write-Host "pyproject.toml not found at $pyprojectPath"
    }
}

function New-ManifestPsd1 {
    param (
        [string]$DestinationPath,
        [hashtable]$Data
    )

    $content = @"
@{
    ModuleVersion = '$($Data.Version)'
    Author        = '$($Data.Authors)'
    Description   = '$($Data.Description)'
}
"@

    Set-Content -Path $DestinationPath -Value $content
}

Export-ModuleMember -Function Convert-PyprojectToml, Invoke-UpdateManifest, New-ManifestPsd1
