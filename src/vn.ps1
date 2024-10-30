param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateSet("305", "306", "307", "308", "309", "310", "311", "312", "313")]
    [string]$PythonVer,

    [Parameter(Mandatory = $false, Position = 2)]
    [string]$Organization,

    [Parameter(Mandatory = $false, Position = 3)]
    [ValidateSet("y", "n", "Y", "N")]
    [String]$ResetScripts,

    [Parameter(Mandatory = $false)]
    [ValidateSet("y", "n", "Y", "N")]
    [String]$DevMode = "Y",

    # [Parameter(Mandatory = $false)]
    # [ValidateSet("y", "n", "Y", "N")]
    # [String]$MultiUser = "Y",

    [Parameter(Mandatory = $false)]
    [Switch]$Help,

    # Used to indicate that the code is called by Pester to avoid unwanted code execution during Pester testing.
    [Parameter(Mandatory = $false)]
    [Switch]$Pester
)

if (Get-Module -Name "Utils") { Remove-Module -Name "Utils" }
Import-Module $PSScriptRoot\Utils.psm1

# function Backup-ConfigScripts {
#     param (
#         [PSCustomObject]$InstallationValues,
#         [string]$TimeStamp
#     )
#
#     # $configScripts = @(
#     #     "VEnv${ProjectName}Install.ps1",
#     #     "VEnv${ProjectName}CustomSetup.ps1"
#     # )
#     if ($InstallationValues.ResetScripts -eq "Y") {
#         $OrgArchiveDir = Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath "Archive"
#         $fileName = ("VEnv" + $InstallationValues.ProjectName + "Install.ps1")
#         $scriptPath = Join-Path -Path $env:VENV_CONFIG_DEFAULT_DIR -ChildPath $fileName
#         Backup-ScriptToArchiveIfExists -ScriptPath $scriptPath -ArchiveDir $OrgArchiveDir -TimeStamp $TimeStamp
#
#         # $UserArchiveDir = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath "Archive"
#         # $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath "$VEnv${InstallationValues.ProjectName}CustomSetup.ps1"
#
#         $UserArchiveDir = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath "Archive"
#         $fileName = ("VEnv" + $InstallationValues.ProjectName + "CustomSetup.ps1")
#         $scriptPath = Join-Path -Path $env:VENV_CONFIG_USER_DIR -ChildPath $fileName
#         Backup-ScriptToArchiveIfExists -ScriptPath $scriptPath -ArchiveDir $UserArchiveDir -TimeStamp $TimeStamp
#     }
# }

function CreateDirIfNotExist {
    param (
        [string]$_dir
    )
    if (-not (Test-Path -Path $_dir)) {
        New-Item -ItemType Directory -Path $_dir | Out-Null
    }

}

function CreatePreCommitConfigYaml {
    $preCommitPath = Join-Path -Path $env:PROJECT_DIR -ChildPath ".pre-commit-config.yaml"
    $content = @"
repos:
  - repo: https://github.com/psf/black
    rev: stable
    hooks:
    - id: black
      language_version: python3
  - repo: https://github.com/pycqa/flake8
    rev: stable
    hooks:
    - id: flake8
      language_version: python3
"@
    Set-Content -Path $preCommitPath -Value $content
}

function CreateProjectDir {
    if (-not (Test-Path $_project_dir)) {
        mkdir $_project_dir | Out-Null
        mkdir "$_project_dir\docs" | Out-Null
        return $false
    }
    return $true
}

function CreateProjectStructure {
    Set-Location -Path $requirements_dir
    CreateProjectDir
    InitGit
    $requirements_dir = "$_project_dir\docs\requirements_docs.txt"
    if (-not (Test-Path requirements_dir)) {
        New-Item -ItemType File -Path $requirements_dir -Force | Out-Null
    }
}

function Get-InstallationValues {
    param (
        [string]$ProjectName,
        [string]$PythonVer,
        [string]$Organization,
        [string]$DevMode,
        [string]$ResetScripts
    )
    # Set local variables from environment variables
    $PythonVer = Get-Value -CurrValue $PythonVer -Prompt "Python version" -DefValue "312"
    $Organization = Get-Value -CurrValue $Organization -Prompt "Organization" -DefValue "MyOrg"
    if (-not $DevMode -eq "Y" -or -not $DevMode -eq "N" -or [string]::IsNullOrWhiteSpace($DevMode)) {
        $DevMode = ReadYesOrNo -promptText "Dev mode"
    }
    if (-not $ResetScripts -eq "Y" -or -not $ResetScripts -eq "N" -or [string]::IsNullOrWhiteSpace($ResetScripts)) {
        $ResetScripts = ReadYesOrNo -promptText "Reset scripts"
    }
    $InstallationValues = [PSCustomObject]@{ ProjectName = $ProjectName; PythonVer = $PythonVer; Organization = $Organization; DevMode = $DevMode; ResetScripts = $ResetScripts }
    return $InstallationValues
}

function Get-Value {
    param (
        [string]$CurrValue,
        [string]$Prompt,
        [string]$DefValue
    )
    $Value = if (-not $CurrValue) { Read-Host "$Prompt (default: $DefValue)" } else { $CurrValue }
    if (-not $Value) {
        $Value = $DefValue
    }
    return $Value
}

# TODO
# I stopped here because the effort became to big.  The following has to happen:
# 1. See [Improve organizational support](https://github.com/BrightEdgeeServices/venvit/issues/7)
# 2. Implement this change [Automate GitHub setup for new repository](https://github.com/BrightEdgeeServices/venvit/issues/6)
function InitGit {
    GITHUB_USER="your-username"
    REPO_NAME="your-repo-name"
    TOKEN="your-github-token"

    # Check if the repository exists
    REPO_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $TOKEN" https://api.github.com/repos/$GITHUB_USER/$REPO_NAME)

    if ( $REPO_CHECK -eq 404 ) {
        then
        Write-Output "Repository does not exist. Creating a new repository..."

        # Create the repository
        Invoke-WebRequest -H "Authorization: token $TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\", \"private\":false}"

        # Add the remote and push
        git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
        git push -u origin main
    }
    else {
        Write-Output "Repository already exists."
        git push -u origin main
    }
}

function New-VirtualEnvironment {
    param (
        [PSCustomObject]$InstallationValues
    )
    if ($env:VIRTUAL_ENV) {
        "Deactivating Virtual environment $env:VIRTUAL_ENV."
        # Invoke-Script -Script "deactivate"
    }

    Invoke-Script -Script ("$env:VENV_PYTHON_BASE_DIR\Python" + $InstallationValues.PythonVer + "\python -m venv --clear $env:VENV_BASE_DIR\$env:PROJECT_NAME" + "_env")
    Set-Location -Path $InstallationValues.ProjectDir
    Invoke-Script -Script ($env:VENV_BASE_DIR + "\" + $env:PROJECT_NAME + "_env\Scripts\activate.ps1")
    Invoke-Script -Script ("python.exe -m pip install --upgrade pip")
}

function New-SupportScript {
    param (
        [string]$BaseDir,
        [string]$FileName,
        [string]$Content,
        [string]$TimeStamp
    )

    $archiveDir = Join-Path -Path $BaseDir -ChildPath "Archive"
    $scriptPath = Join-Path -Path $BaseDir -ChildPath $FileName
    if (Test-Path -Path $scriptPath) {
        Backup-ScriptToArchiveIfExists -ScriptPath $scriptPath -ArchiveDir $archiveDir -TimeStamp $TimeStamp
        Remove-Item -Path $scriptPath -Recurse -Force
    }
    Set-Content -Path $scriptPath -Value $content
}

function New-VEnvCustomSetupScripts {
    param (
        [PSCustomObject]$InstallationValues,
        [string]$TimeStamp
    )

    if ($InstallationValues.ResetScripts -eq "Y") {
        $fileName = ("VEnv" + $InstallationValues.ProjectName + "CustomSetup.ps1")
        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_DEFAULT_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += '# Set/override environment variables by changing them here.  Uncomment them and set the correct value or add a variable by replacing "??"'
        $content += '#$env:INSTALLER_PWD = "??"' + "`n"
        $content += '#$env:INSTALLER_USERID = "??"' + "`n"
        $content += '#$env:LINUX_ROOT_PWD = "??"' + "`n"
        $content += '#$env:MYSQL_DATABASE = "??"' + "`n"
        $content += '#$env:MYSQL_HOST = "??"' + "`n"
        $content += '#$env:MYSQL_PWD = "??"' + "`n"
        $content += '#$env:MYSQL_ROOT_PASSWORD = "??"' + "`n"
        $content += '#$env:MYSQL_TCP_PORT = ??' + "`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_DEFAULT_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_USER_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += "# Insert customized setup commands specific to the user.`n"
        $content += "# Values in this file will override values set by the Organization custom setup script.`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_USER_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        return @("$env:VENV_CONFIG_DEFAULT_DIR\$fileName", "$env:VENV_CONFIG_USER_DIR\$fileName")
    }
}

function New-VEnvEnvVarScripts {
    param (
        [PSCustomObject]$InstallationValues,
        [string]$TimeStamp
    )

    if ($InstallationValues.ResetScripts -eq "Y") {
        $fileName = ("VEnv" + $InstallationValues.ProjectName + "EnvVar.ps1")
        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_DEFAULT_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += '$env:VENV_PY_VER = "' + $InstallationValues.PythonVer + '"' + "`n"
        $content += '$env:PYTHONPATH = "' + $InstallationValues.ProjectDir + "\src;" + $InstallationValues.ProjectDir + "\tests" + '"' + "`n"
        $content += '$env:PROJECT_DIR = "' + $InstallationValues.ProjectDir + '"' + "`n"
        $content += '$env:PROJECT_NAME = "' + $InstallationValues.ProjectName + '"' + "`n`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_DEFAULT_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_USER_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += "# Insert customized setup commands specific to the user.`n"
        $content += "# Values in this file will override values set by the Organization custom setup script.`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_USER_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        return @("$env:VENV_CONFIG_DEFAULT_DIR\$fileName", "$env:VENV_CONFIG_USER_DIR\$fileName")
    }
}

function New-VEnvInstallScripts {
    param (
        [PSCustomObject]$InstallationValues,
        [string]$TimeStamp
    )

    if ($InstallationValues.ResetScripts -eq "Y") {
        $fileName = ("VEnv" + $InstallationValues.ProjectName + "Install.ps1")
        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_DEFAULT_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += "git init`n"
        $content += '& ' + $InstallationValues.ProjectDir + "\install.ps1`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_DEFAULT_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        $content = 'Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan' + "`n"
        $content += 'Write-Host "Running $env:VENV_CONFIG_USER_DIR\' + "$fileName..." + '"' + " -ForegroundColor Yellow`n"
        $content += "# Insert customized setup commands specific to the user`n"
        $content += "# Values in this file will override values set by the Organization installation script.`n"
        New-SupportScript -BaseDir $env:VENV_CONFIG_USER_DIR -FileName $fileName -Content $content -TimeStamp $TimeStamp | Out-Null

        return @("$env:VENV_CONFIG_DEFAULT_DIR\$fileName", "$env:VENV_CONFIG_USER_DIR\$fileName")
    }
}

function New-ProjectInstallScript {
    param (
        [PSCustomObject]$InstallationValues
    )

    $ProjectInstallScriptPath = Join-Path -Path $InstallationValues.ProjectDir -ChildPath "install.ps1"
    if (-not (Test-Path -Path $ProjectInstallScriptPath)) {
        $content = @'
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Running $env:PROJECT_DIR\install.ps1..." -ForegroundColor Yellow
Write-Host "Install Pre-Commit and related tools" -ForegroundColor Yellow
pip install --upgrade --force --no-cache-dir black
pip install --upgrade --force --no-cache-dir flake8
pip install --upgrade --force --no-cache-dir pre-commit
pip install --upgrade --force --no-cache-dir mdformat
pip install --upgrade --force --no-cache-dir coverage codecov
pre-commit install
pre-commit autoupdate
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Install $envPROJECT_NAME" -ForegroundColor Yellow

'@
        if ($InstallationValues.DevMode -eq "Y") {
            $content += 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .[dev]}'
        }
        else {
            $content += 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .}'
        }
    }
    Set-Content -Path $ProjectInstallScriptPath -Value $content
    if (-not (Test-Path (Join-Path -Path $InstallationValues.ProjectDir -ChildPath "\.pre-commit-config.yaml"))) {
        CreatePreCommitConfigYaml
    }
}

function Invoke-CreateNewVirtualEnvironment {
    param (
        [string]$ProjectName,
        [string]$PythonVer,
        [string]$Organization,
        [string]$ResetScripts,
        [string]$DevMode
    )

    $installationValues = Get-InstallationValues -ProjectName $ProjectName -PythonVer $PythonVer -Organization $Organization -DevMode $DevMode -ResetScripts $ResetScripts
    Set-Environment -InstallationValues $installationValues
    Show-EnvironmentVariables
    $continue = Read-YesOrNo -PromptText "Continue"

    Write-Host $separator -ForegroundColor Cyan

    if ($continue) {
        New-VirtualEnvironment -InstallationValues $installationValues
        New-ProjectInstallScript -InstallationValues $installationValues
        $timeStamp = Get-Date -Format "yyyyMMddHHmm"
        $venvInstallScripts = New-VEnvInstallScripts -InstallationValues $installationValues -TimeStamp $timeStamp
        $venvEnvVarScripts = New-VEnvEnvVarScripts -InstallationValues $installationValues -TimeStamp $timeStamp
        $venvCustonSetupScripts = New-VEnvCustomSetupScripts -InstallationValues $installationValues -TimeStamp $timeStamp

        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvInstallScripts[0]
        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvInstallScripts[1]
        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvEnvVarScripts[0]
        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvEnvVarScripts[1]
        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvCustonSetupScripts[0]
        Write-Host $separator -ForegroundColor Cyan
        Invoke-Script -Script $venvCustonSetupScripts[1]
        Write-Host $separator -ForegroundColor Cyan
    }
}

function Set-Environment {
    param (
        [PSCustomObject]$InstallationValues
    )
    # Configure the environment settings for local development environment
    $env:PROJECT_NAME = $InstallationValues.ProjectName
    $env:VENV_ORGANIZATION_NAME = $InstallationValues.Organization
    if ($env:VENV_ENVIRONMENT -eq "loc_dev") {
        Invoke-Script -Script ("$env:VENV_SECRETS_DEFAULT_DIR\dev_env_var.ps1")
        Invoke-Script -Script ("$env:VENV_SECRETS_USER_DIR\dev_env_var.ps1")
    }

    $organizationDir = (Join-Path -Path $env:PROJECTS_BASE_DIR -ChildPath $env:VENV_ORGANIZATION_NAME)
    $InstallationValues | Add-Member -MemberType NoteProperty -Name "OrganizationDir" -Value $organizationDir
    if (-not (Test-Path $InstallationValues.OrganizationDir)) {
        mkdir $InstallationValues.OrganizationDir | Out-Null
    }
    # $_project_dir = Join-Path $_organization_dir $ProjectName
    $InstallationValues | Add-Member -MemberType NoteProperty -Name "ProjectDir" -Value (Join-Path -Path $InstallationValues.OrganizationDir -ChildPath $env:PROJECT_NAME)
    if (-not (Test-Path $InstallationValues.ProjectDir)) {
        mkdir $InstallationValues.ProjectDir | Out-Null
    }
    return $InstallationValues
}

function Show-Help {
    $separator = "-" * 80
    Write-Host $separator -ForegroundColor Cyan

    # Usage
    @"
    Usage:
    ------
    vn.ps1 ProjectName PythonVer Organization DevMode ResetScripts
    vr.ps1 -h

    Parameters:
      ProjectName   The name of the project.
      PythonVer     Python version for the virtual environment.
      Organization  Acronym for the organization owning the project.
      DevMode       [y|n] If "y", installs \[dev\] modules from pyproject.
      ResetScripts  [y|n] If "y", moves certain scripts to the Archive directory.
"@ | Write-Host

    Write-Host $separator -ForegroundColor Cyan
}

# function ShowEnvVarHelp {
#     Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan
#
#     $_env_vars = @(
#         @("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT),
#         @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
#         @("VENVIT_DIR", "$env:VENVIT_DIR"),
#         @("VENV_SECRETS_DIR", "$env:VENV_SECRETS_DIR"),
#         @("VENV_CONFIG_DIR, $env:VENV_CONFIG_DIR"),
#         @("VENV_BASE_DIR", "$env:VENV_BASE_DIR"),
#         @("VENV_PYTHON_BASE_DIR", "$env:VENV_PYTHON_BASE_DIR")
#     )
#
#     foreach ($var in $_env_vars) {
#         if ([string]::IsNullOrEmpty($var[1])) {
#             Write-Host $var[0] -ForegroundColor Red -NoNewline
#             Write-Host " - Not Set"
#         }
#         else {
#             Write-Host $var[0] -ForegroundColor Green -NoNewline
#             $s = " - Set to: " + $var[1]
#             Write-Host $s
#         }
#     }
# }

# Script execution starts here
# Pester parameter is to ensure that the script does not execute when called from
# pester BeforeAll.  Any better ideas would be welcome.
if (-not $Pester) {
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "=[ START $dateTime ]=================================================[ vn.ps1 ]=" -ForegroundColor Blue
    # $project_name = $args[0]
    Write-Host "Create new $ProjectName virtual environment" -ForegroundColor Blue
    if ($ProjectName -eq "" -or $Help) {
        Show-Help
    }
    else {
        Invoke-CreateNewVirtualEnvironment -ProjectName $ProjectName -PythonVer $PythonVer -Organization $Organization -ResetScripts $ResetScripts -DevMode $DevMode
        Show-EnvironmentVariables
    }
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}
