# $tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
# Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1" -OutFile "install.ps1"
# .\install.ps1 -release $tag


$tempDir = New-Item -ItemType Directory -Path (Join-Path -Path [System.IO.Path]::GetTempPath() -ChildPath ([System.IO.Path]::GetRandomFileName()))
Write-Host "Created temporary directory: $tempDir"
$tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
# $installScriptPath = Join-Path -Path $tempDir -ChildPath "install.ps1"

# Download the install.ps1 file to the temporary directory
Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1" -OutFile Join-Path -Path $tempDir -ChildPath "install.ps1"
Write-Host "Downloaded install.ps1 to $installScriptPath"
& $installScriptPath -release $tag

Remove-Item -Path $tempDir -Recurse -Force
Write-Host "Temporary directory removed."
