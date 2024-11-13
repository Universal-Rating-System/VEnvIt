# Install-Conclude.psm1

if (Get-Module -Name "Conclude-UpgradePrep") { Remove-Module -Name "Conclude-UpgradePrep" }
Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1
if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\..\src\Utils.psm1

$separator = "-" * 80

function Clear-InstallationFiles {
    param (
        [string]$upgradeScriptDir
    )
    Remove-Item -Path $upgradeScriptDir -Force -Recurse
    Write-Host "Installation files has been deleted." -ForegroundColor Green
}

function Invoke-ConcludeInstall {
    param (
        [string]$Release,
        [string]$UpgradeScriptDir
    )

    # Check for administrative privileges
    if (-not (Test-Admin)) {
        Write-Host "This script needs to be run as an administrator. Please run it in an elevated PowerShell session." -ForegroundColor Red
        Invoke-CleanUp
        exit
    }

    Update-PackagePrep $UpgradeScriptDir
    Write-Host $separator -ForegroundColor Cyan
    Get-ReadAndSetEnvironmentVariables -EnvVarSet $defEnvVarSet
    Set-Path
    Write-Host "Environment variables have been set successfully." -ForegroundColor Green
    New-Directories
    Publish-LatestVersion -Release $Release -UpgradeScriptDir $UpgradeScriptDir
    Publish-Secrets -UpgradeScriptDir $UpgradeScriptDir
    Write-Host $separator -ForegroundColor Cyan
    Get-Item "$env:VENVIT_DIR\*.ps1" | ForEach-Object { Unblock-File $_.FullName }
    Get-Item "$env:VENV_SECRETS_DEFAULT_DIR\secrets.ps1" | ForEach-Object { Unblock-File $_.FullName }
    Get-Item "$env:VENV_SECRETS_USER_DIR\secrets.ps1" | ForEach-Object { Unblock-File $_.FullName }
    Clear-InstallationFiles -UpgradeScriptDir $UpgradeScriptDir
    Write-Host "Installation and configuration are complete." -ForegroundColor Green
}

function Invoke-IsInRole {
    param (
        [Security.Principal.WindowsPrincipal]$Principal,
        [Security.Principal.WindowsBuiltInRole]$Role
    )
    return $Principal.IsInRole($Role)
}

function New-Directories {
    # Ensure the directories exist
    foreach ($envVar in $envVarSet) {
        if ( $envVar.IsDir ) {
            $dirName = [System.Environment]::GetEnvironmentVariable($envVar.Name, [System.EnvironmentVariableTarget]::Machine)
            if (-not (Test-Path -Path $dirName)) {
                New-Item -ItemType Directory -Path $dirName | Out-Null
            }
        }
    }
}

function Publish-LatestVersion {
    param (
        # [string]$Release,
        [string]$UpgradeScriptDir
    )
    # $url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$Release/Installation-Files.zip"
    # $zipFilePath = Join-Path -Path $UpgradeScriptDir -ChildPath "Installation-Files.zip"

    # Download the zip file
    # Write-Host "Downloading installation files from $url..."
    # Invoke-WebRequest -Uri $url -OutFile $zipFilePath
    # Unzip the file in the VENVIT_DIR directory, overwriting any existing files
    Write-Host "Copy source files to to $env:VENVIT_DIR..."
    # Expand-Archive -Path $zipFilePath -DestinationPath $env:VENVIT_DIR -Force
    Copy-Item -Path "$UpgradeScriptDir\LICENSE" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\Manifest.psd1" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\README.md" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\ReleaseNotes.md" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\src\vi.ps1" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\src\vn.ps1" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\src\vr.ps1" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\src\utils.psm1" -Destination $env:VENVIT_DIR | Out-Null
    Copy-Item -Path "$UpgradeScriptDir\src\utils.psm1" -Destination $env:VENVIT_DIR | Out-Null
}

function Publish-Secrets {
    param(
        [string]$UpgradeScriptDir
    )
    # Move the secrets.ps1 file from VENVIT_DIR to VENV_SECRETS_DIR if it does not already exist in VENV_SECRETS_DIR
    $copiedFiles = @()
    $directories = @( $env:VENV_SECRETS_DEFAULT_DIR, $env:VENV_SECRETS_USER_DIR )
    foreach ($directory in $directories) {
        $secretsPath = Join-Path -Path $directory -ChildPath (Get-SecretsFileName)
        if ( -not(Test-Path -Path $secretsPath)) {
            Copy-Item -Path $UpgradeScriptDir -Destination $secretsPath -Force
            $copiedFiles += $secretsPath
        }
    }
    return $copiedFiles
}

function Set-Path {
    # Add VENVIT_DIR to the System Path variable
    $path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($path -notlike "*$env:VENVIT_DIR*") {
        $newPath = "$path;$env:VENVIT_DIR"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "VENVIT_DIR has been added to the System Path." -ForegroundColor Yellow
    }
    else {
        Write-Host "VENVIT_DIR is already in the System Path." -ForegroundColor Yellow
    }
}

function Test-Admin {

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return Invoke-IsInRole -Principal $Principal -Role $adminRole
}

Export-ModuleMember -Function Clear-InstallationFiles, Invoke-ConcludeInstall, Invoke-IsInRole, New-Directories
Export-ModuleMember -Function Publish-LatestVersion, Publish-Secrets, Set-Path, Test-Admin
# Export-ModuleMember -Variable envVarSet
# Export-ModuleMember -Variable envVarSet
