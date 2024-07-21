# # Define variables
# $zipUrl = "https://github.com/BrightEdgeeServices/venvit/releases/download/5.3.2/installation_files.zip"
# $zipFile = "installation_files.zip"
# $extractPath = "installation_files"

# # Function to download a file from a URL
# function Download-File {
#     param (
#         [string]$url,
#         [string]$output
#     )

#     try {
#         Write-Host "Downloading $url..."
#         Invoke-WebRequest -Uri $url -OutFile $output
#         Write-Host "Download complete."
#     } catch {
#         Write-Host "Error downloading file: $_"
#         exit 1
#     }
# }

# # Function to unzip a file
# function Unzip-File {
#     param (
#         [string]$zipFilePath,
#         [string]$destinationPath
#     )

#     try {
#         Write-Host "Unzipping $zipFilePath..."
#         Expand-Archive -Path $zipFilePath -DestinationPath $destinationPath -Force
#         Write-Host "Unzip complete."
#     } catch {
#         Write-Host "Error unzipping file: $_"
#         exit 1
#     }
# }

# # Function to execute a PowerShell script
# function Execute-Script {
#     param (
#         [string]$scriptPath
#     )

#     try {
#         Write-Host "Executing $scriptPath..."
#         & $scriptPath
#         Write-Host "Execution complete."
#     } catch {
#         Write-Host "Error executing script: $_"
#         exit 1
#     }
# }

# # Main script
# Download-File -url $zipUrl -output $zipFile
# Unzip-File -zipFilePath $zipFile -destinationPath $extractPath
# Execute-Script -scriptPath "$extractPath\install.ps1"


# Define variables
$repoOwner = "BrightEdgeServices"
$repoName = "venvit"
$zipFileName = "installation_files.zip"
$zipFilePath = "installation_files.zip"
$extractPath = "installation_files"

# Function to get the latest release URL
function Get-LatestReleaseUrl {
    param (
        [string]$owner,
        [string]$repo,
        [string]$fileName
    )

    # $releases = "https://api.github.com/repos/$owner/$repo/releases"
    $releases = "https://api.github.com/repos/BrightEdgeeServices/venvit/releases"
    try {
        Write-Host "Fetching latest release information..."
        # $releases = "https://api.github.com/repos/$repo/releases"
        # $tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
        $tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
        # $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
        # foreach ($asset in $releaseInfo.assets) {
        #     if ($asset.name -eq $fileName) {
        #         return $asset.browser_download_url
        #     }
        # }
        return "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/installation_files.zip"
        # throw "File $fileName not found in the latest release."
    } catch {
        Write-Host "Error fetching latest release information: $_"
        exit 1
    }
}

# Function to download a file from a URL
function Download-File {
    param (
        [string]$url,
        [string]$output
    )

    try {
        Write-Host "Downloading $url..."
        Invoke-WebRequest -Uri $url -OutFile $output
        Write-Host "Download complete."
    } catch {
        Write-Host "Error downloading file: $_"
        exit 1
    }
}

# Function to unzip a file
function Unzip-File {
    param (
        [string]$zipFilePath,
        [string]$destinationPath
    )

    try {
        Write-Host "Unzipping $zipFilePath..."
        Expand-Archive -Path $zipFilePath -DestinationPath $destinationPath -Force
        Write-Host "Unzip complete."
    } catch {
        Write-Host "Error unzipping file: $_"
        exit 1
    }
}

# Function to execute a PowerShell script
function Execute-Script {
    param (
        [string]$scriptPath
    )

    try {
        Write-Host "Executing $scriptPath..."
        & $scriptPath
        Write-Host "Execution complete."
    } catch {
        Write-Host "Error executing script: $_"
        exit 1
    }
}

# Main script
$zipUrl = Get-LatestReleaseUrl -owner $repoOwner -repo $repoName -fileName $zipFileName
Download-File -url $zipUrl -output $zipFilePath
Unzip-File -zipFilePath $zipFilePath -destinationPath $extractPath
Execute-Script -scriptPath "$extractPath\install.ps1"
