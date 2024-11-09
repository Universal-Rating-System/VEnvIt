$defEnvVarSet = @{
    PROJECTS_BASE_DIR        = @{DefVal = "~\Projects"; IsDir = $true }
    VENV_BASE_DIR            = @{DefVal = "~\venv"; IsDir = $true }
    VENV_CONFIG_DEFAULT_DIR  = @{DefVal = "$env:ProgramFiles\VenvIt\Config"; IsDir = $true }
    VENV_CONFIG_USER_DIR     = @{DefVal = "~\VenvIt\Config"; IsDir = $true }
    VENV_ENVIRONMENT         = @{DefVal = "loc_dev"; IsDir = $false }
    VENV_PYTHON_BASE_DIR     = @{DefVal = "c:\Python"; IsDir = $true }
    VENV_SECRETS_DEFAULT_DIR = @{DefVal = "$env:ProgramFiles\VenvIt\Secrets"; IsDir = $true }
    VENV_SECRETS_USER_DIR    = @{DefVal = "~\VenvIt\Secrets"; IsDir = $true }
    VENVIT_DIR               = @{DefVal = "$env:ProgramFiles\VenvIt"; IsDir = $true }
}

$separator = "-" * 80

function Backup-ScriptToArchiveIfExists {
    param (
        [string]$ScriptPath,
        [string]$ArchiveDir,
        [string]$TimeStamp
    )

    # Check if the file exists
    if (Test-Path $scriptPath) {
        # Ensure the archive directory exists
        if (-not (Test-Path $archiveDir)) {
            New-Item -Path $archiveDir -ItemType Directory
        }
        $archivePath = Join-Path -Path $ArchiveDir -ChildPath ($env:PROJECT_NAME + "_" + $TimeStamp + ".zip")
        if (Test-Path $archivePath) {
            Compress-Archive -Path $ScriptPath -Update -DestinationPath $archivePath
        }
        else {
            Compress-Archive -Path $ScriptPath -DestinationPath $archivePath
        }
        # Write-Host "Zipped $ScriptPath."
    }
    return $archivePath
}

function Confirm-EnvironmentVariables {
    # Check for required environment variables and display help if they're missing
    $Result = $true
    if (
        -not $env:VENV_ENVIRONMENT -or
        -not $env:VENVIT_DIR -or
        -not $env:VENV_SECRETS_DEFAULT_DIR -or
        -not $env:VENV_SECRETS_USER_DIR -or
        -not $env:VENV_CONFIG_DEFAULT_DIR -or
        -not $env:VENV_CONFIG_USER_DIR -or
        -not $env:PROJECTS_BASE_DIR -or
        -not $env:VENV_BASE_DIR -or
        -not $env:VENV_PYTHON_BASE_DIR) {
        $Result = $false
    }
    return $Result
}

function Get-ConfigFileName {
    param(
        [string]$ProjectName,
        [string]$Postfix
    )
    return ("VEnv" + $ProjectName + "$Postfix.ps1")
}

function Get-ManifestFileName {
    return "Manifest.psd1"
}

function Get-SecretsFileName {
    return "Secrets.ps1"
}
function New-CustomTempDir {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Prefix
    )
    $TempDir = Join-Path -Path $env:TEMP -ChildPath ($Prefix + "_" + [Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $TempDir | Out-Null
    return $TempDir
}

function Invoke-Script {
    param (
        [string]$Script
    )
    Write-Host $Script
    & $Script
}

function Set-EnvironmentVariables {
    param(
        $EnvVarSet
    )

    foreach ($envVar in $EnvVarSet.Keys) {
        $existingValue = [System.Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine)
        if ($existingValue) {
            $promptText = $envVar + " ($existingValue)"
            $defaultValue = $existingValue
        }
        else {
            $promptText = $envVar + " (" + $EnvVarSet[$envVar]["DefVal"] + ")"
            $defaultValue = $EnvVarSet[$envVar]["DefVal"]
        }
        $newValue = Read-Host -Prompt $promptText
        if ($newValue -eq "") {
            $newValue = $defaultValue
        }
        Set-Item -Path env:$envVar -Value $newValue
        [System.Environment]::SetEnvironmentVariable($envVar, $newValue, [System.EnvironmentVariableTarget]::Machine)
    }
}

function Show-EnvironmentVariables {
    Write-Host ""
    Write-Host "System Environment Variables" -ForegroundColor Green
    Write-Host "VENV_ENVIRONMENT:         $env:VENV_ENVIRONMENT"
    Write-Host "PROJECTS_BASE_DIR:        $env:PROJECTS_BASE_DIR"
    Write-Host "PROJECT_DIR:              $env:PROJECT_DIR"
    Write-Host "VENVIT_DIR:               $env:VENVIT_DIR"
    Write-Host "VENV_SECRETS_DEFAULT_DIR: $env:VENV_SECRETS_DIR"
    Write-Host "VENV_SECRETS_USER_DIR:    $env:VENV_SECRETS_DIR"
    Write-Host "VENV_CONFIG_DIR:          $env:VENV_CONFIG_DIR"
    Write-Host "VENV_BASE_DIR:            $env:VENV_BASE_DIR"
    Write-Host "VENV_PYTHON_BASE_DIR:     $env:VENV_PYTHON_BASE_DIR"
    Write-Host ""
    Write-Host "Project Environment Variables" -ForegroundColor Green
    Write-Host "PROJECT_NAME:             $env:PROJECT_NAME"
    Write-Host "VENV_ORGANIZATION_NAME:   $env:VENV_ORGANIZATION_NAME"
    Write-Host "INSTALLER_PWD:            $env:INSTALLER_PWD"
    Write-Host "INSTALLER_USERID:         $env:INSTALLER_USERID"
    Write-Host "MYSQL_DATABASE:           $env:MYSQL_DATABASE"
    Write-Host "MYSQL_HOST:               $env:MYSQL_HOST"
    Write-Host "MYSQL_ROOT_PASSWORD:      $env:MYSQL_ROOT_PASSWORD"
    Write-Host "MYSQL_TCP_PORT:           $env:MYSQL_TCP_PORT"
    Write-Host ""
    Write-Host "Git Information" -ForegroundColor Green
    git branch --all
}

function Read-YesOrNo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PromptText
    )
    do {
        $inputValue = Read-Host "$PromptText (Y/n)"
        $inputValue = $inputValue.ToUpper()
        if (-not $inputValue) {
            $inputValue = "Y"
        }
        $PromptText = "Only Y or N"
    } while ($inputValue -ne 'Y' -and $inputValue -ne 'N')
    if ($inputValue -eq "Y") {
        $Result = $true
    }
    else {
        $Result = $false
    }

    return $Result
}


Export-ModuleMember -Function Backup-ScriptToArchiveIfExists, New-CustomTempDir, Confirm-EnvironmentVariables
Export-ModuleMember -Function Get-ConfigFileName, Get-ManifestFileName, Get-SecretsFileName, Invoke-Script, Read-YesOrNo
Export-ModuleMember -Function Set-EnvironmentVariables, Show-EnvironmentVariables
Export-ModuleMember -Variable defEnvVarSet, separator
