# $currentManifestPath = "$env:VENVIT_DIR\\manifest.psd1"
$tempDir = New-Item -ItemType Directory -Path (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName()))
$tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
$sourceScriptPath = Join-Path -Path $tempDir.FullName -ChildPath "Conclude-Install.ps1"
# $latestManifestPath = Join-Path -Path $tempDir.FullName -ChildPath "Manifest.psd1"
Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/Conclude-Install.ps1" -OutFile $sourceScriptPath
# Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/Manifest.psd1" -OutFile $latestManifestScriptPath
# & "$env:VENVIT_DIR\\Conclude-UpgradePrep.ps1" -currentManifestPath $currentManifestPath -latestManifestPath $latestManifestPath
& $sourceScriptPath -release $tag -sourceScriptDir $tempDir
# & "D:\Dropbox\Projects\BEE\venvit\src\Install.ps1" -release $tag -sourceScriptDir "D:\Dropbox\Projects\BEE\venvit\"
Remove-Item -Path $tempDir.FullName -Recurse -Force
# Unblock-File "$env:VENVIT_DIR\vn.ps1"
# Unblock-File "$env:VENVIT_DIR\vi.ps1"
# Unblock-File "$env:VENVIT_DIR\vr.ps1"
# Unblock-File "$env:VENV_SECRETS_DIR\dev_env_var.ps1"
Get-Item "$env:VENVIT_DIR\*.ps1" | Unblock-File
Get-Item "$env:VENV_SECRETS_DIR\dev_env_var.ps1" | Unblock-File
