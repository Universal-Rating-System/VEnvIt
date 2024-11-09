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
    Set-EnvironmentVariables -EnvVarSet $defEnvVarSet
    Set-Path
    Write-Host "Environment variables have been set successfully." -ForegroundColor Green
    New-Directories
    Publish-LatestVersion -Release $Release -UpgradeScriptDir $UpgradeScriptDir
    Publish-Secrets
    Write-Host $separator -ForegroundColor Cyan
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
    # Move the secrets.ps1 file from VENVIT_DIR to VENV_SECRETS_DIR if it does not already exist in VENV_SECRETS_DIR
    $sourceFilePath = Join-Path -Path $env:VENVIT_DIR -ChildPath "secrets.ps1"
    $destinationDefaultFilePath = Join-Path -Path $env:VENV_SECRETS_DEFAULT_DIR -ChildPath "secrets.ps1"
    $destinationUserFilePath = Join-Path -Path $env:VENV_SECRETS_USER_DIR -ChildPath "secrets.ps1"

    if (Test-Path -Path $sourceFilePath) {
        if (-not (Test-Path -Path $destinationDefaultFilePath)) {
            Write-Host "Moving secrets.ps1 to $env:VENV_SECRETS_DEFAULT_DIR..."
            Copy-Item -Path $sourceFilePath -Destination $destinationDefaultFilePath -Force
        }
        else {
            Write-Host "secrets.ps1 already exists in $env:VENV_SECRETS_DEFAULT_DIR. It will not be overwritten."
        }
        if (-not (Test-Path -Path $destinationUserFilePath)) {
            Write-Host "Moving secrets.ps1 to $env:VENVIT_SECRETS_USER_DIR..."
            Move-Item -Path $sourceFilePath -Destination $destinationUserFilePath -Force
        }
        else {
            Write-Host "secrets.ps1 already exists in $env:VENVIT_SECRETS_USER_DIR. It will not be overwritten."
        }
    }
    else {
        Write-Host "secrets.ps1 not found in $env:VENVIT_DIR."
    }

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
Export-ModuleMember -Variable envVarSet
