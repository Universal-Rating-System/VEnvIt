# Function to convert the pyproject.toml file and extract version, author(s), and description
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

# Function to create a manifest.psd1
function New-ManifestPsd1 {
    param (
        [string]$filePath,
        [hashtable]$data
    )

    $content = @"
@{
    ModuleVersion = '$($data.Version)'
    Author        = '$($data.Authors)'
    Description   = '$($data.Description)'
}
"@

    Set-Content -Path $filePath -Value $content
}

# Main function that accepts a directory parameter and constructs the paths
function Update-Manifest {
    param (
        [string]$directory  # Root directory parameter
    )

    # Construct the paths for pyproject.toml and manifest.psd1 based on the provided directory
    $pyprojectPath = Join-Path -Path $directory -ChildPath "pyproject.toml"
    $manifestPath = Join-Path -Path $directory -ChildPath "manifest.psd1"

    # Check if pyproject.toml exists
    if (Test-Path -Path $pyprojectPath) {
        # Extract data from pyproject.toml
        $pyprojectData = Convert-PyprojectToml -filePath $pyprojectPath

        # Check if all necessary data was extracted
        if ($pyprojectData.Version -and $pyprojectData.Authors -and $pyprojectData.Description) {
            # Create the manifest.psd1
            New-ManifestPsd1 -filePath $manifestPath -data $pyprojectData
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

# Script execution starts here
# This block is ONLY executed if the script is run directly, not dot-sourced i.e. by Pester
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    param (
        [string]$base_dir
    )
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]=========================[ Update-Manifest.ps1 ]=" -ForegroundColor Blue
    Write-Host "Update manifest" -ForegroundColor Blue

    if (-not $base_dir) {
        throw "The parameter -base_dir is required."
    }
    Update-Manifest -directory $base_dir
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
    Write-Host ''
    Write-Host ''
}
