Import-Module $PSScriptRoot\..\src\Conclude-UpgradePrep.psm1

$envVarSet = @(
    [PSCustomObject]@{Name = "VENV_ENVIRONMENT"; DefVal = "loc_dev"; IsDir = $false},
    [PSCustomObject]@{Name = "PROJECTS_BASE_DIR"; DefVal = "~\Projects"; IsDir = $true },
    [PSCustomObject]@{Name = "VENVIT_DIR"; DefVal = "$env:ProgramFiles\VenvIt"; IsDir = $true },
    [PSCustomObject]@{Name = "VENVIT_SECRETS_ORG_DIR"; DefVal = "$env:VENVIT_DIR\Secrets"; IsDir = $true },
    [PSCustomObject]@{Name = "VENVIT_SECRETS_USER_DIR"; DefVal = "~\VenvIt\Secrets"; IsDir = $true },
    [PSCustomObject]@{Name = "VENV_BASE_DIR"; DefVal = "~\venv"; IsDir = $true },
    [PSCustomObject]@{Name = "VENV_PYTHON_BASE_DIR"; DefVal = "c:\Python"; IsDir = $true },
    [PSCustomObject]@{Name = "VENV_CONFIG_ORG_DIR"; DefVal = "$env:VENVIT_DIR\Config"; IsDir = $true },
    [PSCustomObject]@{Name = "VENV_CONFIG_USER_DIR"; DefVal = "~\VenvIt\Config"; IsDir = $true }
)
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

    # Invoke-ConcludeUpgradePrep $UpgradeScriptDir
    Update-PackagePrep $UpgradeScriptDir
    Write-Host $separator -ForegroundColor Cyan
    Set-EnvironmentVariables
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
        [string]$Release,
        [string]$UpgradeScriptDir
    )
    $url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$Release/Installation-Files.zip"
    $zipFilePath = Join-Path -Path $UpgradeScriptDir -ChildPath "Installation-Files.zip"

    # Download the zip file
    Write-Host "Downloading installation files from $url..."
    Invoke-WebRequest -Uri $url -OutFile $zipFilePath
    # Unzip the file in the VENVIT_DIR directory, overwriting any existing files
    Write-Host "Unzipping Installation-Files.zip to $env:VENVIT_DIR..."
    Expand-Archive -Path $zipFilePath -DestinationPath $env:VENVIT_DIR -Force
}

function Publish-Secrets {
    # Move the dev_env_var.ps1 file from VENVIT_DIR to VENV_SECRETS_DIR if it does not already exist in VENV_SECRETS_DIR
    $sourceFilePath = Join-Path -Path $env:VENVIT_DIR -ChildPath "dev_env_var.ps1"
    $destinationOrgFilePath = Join-Path -Path $env:VENVIT_SECRETS_ORG_DIR -ChildPath "dev_env_var.ps1"
    $destinationUserFilePath = Join-Path -Path $env:VENVIT_SECRETS_USER_DIR -ChildPath "dev_env_var.ps1"

    if (Test-Path -Path $sourceFilePath) {
        if (-not (Test-Path -Path $destinationOrgFilePath)) {
            Write-Host "Moving dev_env_var.ps1 to $env:VENVIT_SECRETS_ORG_DIR..."
            Copy-Item -Path $sourceFilePath -Destination $destinationOrgFilePath -Force
        }
        else {
            Write-Host "dev_env_var.ps1 already exists in $env:VENVIT_SECRETS_ORG_DIR. It will not be overwritten."
        }
        if (-not (Test-Path -Path $destinationUserFilePath)) {
            Write-Host "Moving dev_env_var.ps1 to $env:VENVIT_SECRETS_USER_DIR..."
            Move-Item -Path $sourceFilePath -Destination $destinationUserFilePath -Force
        }
        else {
            Write-Host "dev_env_var.ps1 already exists in $env:VENVIT_SECRETS_USER_DIR. It will not be overwritten."
        }
    }
    else {
        Write-Host "dev_env_var.ps1 not found in $env:VENVIT_DIR."
    }

}

function Set-EnvironmentVariables {
    foreach ($envVar in $envVarSet) {
        $existingValue = [System.Environment]::GetEnvironmentVariable($envVar.Name, [System.EnvironmentVariableTarget]::Machine)
        if ($existingValue) {
            $promptText = $envVar.Name + " ($existingValue)"
            $defaultValue = $existingValue
        }
        else {
            $promptText = $envVar.Name + " (" + $envVar.DefVal + ")"
            $defaultValue = $envVar.DefVal
        }
        $newValue = Read-Host -Prompt $promptText
        if ($newValue -eq "") {
            $newValue = $defaultValue
        }
        [System.Environment]::SetEnvironmentVariable($envVar.Name, $newValue, [System.EnvironmentVariableTarget]::Machine)
    }
}

function Set-Path {
    # Add VENVIT_DIR to the System Path variable
    $path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($path -notlike "*$env:VENVIT_DIR*") {
        $newPath = "$path;$env:VENVIT_DIR"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "VENVIT_DIR has been added to the System Path." -ForegroundColor Green
    }
    else {
        Write-Host "VENVIT_DIR is already in the System Path." -ForegroundColor Green
    }
}

function Test-Admin {

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return Invoke-IsInRole -Principal $Principal -Role $adminRole
}

Export-ModuleMember -Function Clear-InstallationFiles, Invoke-ConcludeInstall, Invoke-IsInRole, New-Directories
Export-ModuleMember -Function Publish-LatestVersion, Publish-Secrets, Remove-EnvVarIfExists, Set-EnvironmentVariables
Export-ModuleMember -Function Set-Path, Test-Admin
Export-ModuleMember -Variable envVarSet
