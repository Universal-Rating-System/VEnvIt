function Invoke-Install {
    param (
        [string]$run  # Fake parameter to get past Pester tests in production
    )
    # -- Start copy for readme.md------------------------------------------------------------
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
    Get-Item "$env:VENVIT_DIR\*.ps1" | ForEach-Object { Unblock-File $_.FullName }
    Get-Item "$env:VENV_SECRETS_DIR\dev_env_var.ps1" | ForEach-Object { Unblock-File $_.FullName }
    # -- End copy for readme.md------------------------------------------------------------
}

function Show-Help {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

    # Introduction
    @"
Update the manifest for the project from the pyproject.toml files.
"@ | Write-Host
    Write-Host $separator -ForegroundColor Cyan
    @"
    Usage:
    ------
    Install.ps1 config_base_dir
    Install.ps1 -h | --help

    where:
      config_base_dir:  Location of the pyproject.toml configuration file.
"@ | Write-Host
}

# Script execution starts here
Write-Host ''
Write-Host ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "=[ START $dateTime ]============================================[ Install.ps1 ]=" -ForegroundColor Blue
Write-Host "Install" -ForegroundColor Blue
# The script should not run if it is invoked by Pester
if ($args.Count -eq 0 -or $args[0] -eq "-h" -or $args[0] -eq "--help") {
    Show-Help
}
else {
    Invoke-Install -config_base_dir $args[0]
}
Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host ''
