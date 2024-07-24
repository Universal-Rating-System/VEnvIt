# Create a temporary directory
$tempDir = New-Item -ItemType Directory -Path (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName()))
Write-Host "Created temporary directory: $tempDir"
$tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name

# Download the install.ps1 file to the temporary directory
$installScriptPath = Join-Path -Path $tempDir.FullName -ChildPath "install.ps1"
Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1" -OutFile $installScriptPath
Write-Host "Downloaded install.ps1 to $tempDir"

# Execute the install.ps1 script
& $installScriptPath -release $tag -installScriptDir $tempDir
Remove-Item -Path $tempDir.FullName -Recurse -Force
Write-Host "Temporary directory removed."
