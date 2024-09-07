
function CreateDirIfNotExist {
    param (
        [string]$_dir
    )
    if (-not (Test-Path -Path $_dir)) {
        New-Item -ItemType Directory -Path $_dir | Out-Null
    }

}

function CreatePreCommitConfigYaml {
    $pre_commit_file_name = ".pre-commit-config.yaml"
    $pre_commit_path = Join-Path -Path $_project_dir -ChildPath $pre_commit_file_name

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

    Set-Content -Path $pre_commit_path -Value $content
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

function CreateVirtualEnvironment {
    param (
        [string]$_project_name,
        [string]$_python_version,
        [string]$_organization,
        [string]$_dev_mode,
        [string]$_reset
    )

    # Show help if no project name is provided
    if (-not $_project_name -or $_project_name -eq "-h") {
        ShowHelp
        return
    }

    # Check for required environment variables and display help if they're missing
    if (
        -not $env:VENV_ENVIRONMENT -or
        -not $env:VENVIT_DIR -or
        -not $env:VENV_SECRETS_DIR -or
        -not $env:VENV_CONFIG_DIR -or
        -not $env:PROJECTS_BASE_DIR -or
        -not $env:VENV_BASE_DIR -or
        -not $env:VENV_PYTHON_BASE_DIR) {
        ShowEnvVarHelp
        return
    }

    # Set local variables from environment variables
    $_python_base_dir = $env:VENV_PYTHON_BASE_DIR
    $_venv_base_dir = $env:VENV_BASE_DIR
    $_venvit_dir = $env:VENVIT_DIR
    $_project_base_dir = $env:PROJECTS_BASE_DIR
    $_project_name = if (-not $_project_name) { Read-Host "Project name" } else { $_project_name }
    $_python_version = if (-not $_python_version) { Read-Host "Python version" } else { $_python_version }
    $_organization = if (-not $_organization) { Read-Host "Organization" } else { $_organization }
    if (-not $_dev_mode -eq "Y" -or -not $_dev_mode -eq "N" -or [string]::IsNullOrWhiteSpace($_dev_mode)) {
        $_dev_mode = ReadYesOrNo -_prompt_text "Dev mode"
    }
    if (-not $_reset -eq "Y" -or -not $_reset -eq "N" -or [string]::IsNullOrWhiteSpace($_reset)) {
        $_reset = ReadYesOrNo -_prompt_text "Reset scripts"
    }

    # Configure the environment settings for local development environment
    $env:PROJECT_NAME = $_project_name
    $env:VENV_ORGANIZATION_NAME = $_organization
    if ($env:VENV_ENVIRONMENT -eq "loc_dev") {
        & "$env:VENV_SECRETS_DIR\dev_env_var.ps1"
    }

    # Determine project directory based on organization
    $_organization_dir = Join-Path $_project_base_dir $env:VENV_ORGANIZATION_NAME
    # Create organization directory if it does not exist
    if (-not (Test-Path $_organization_dir)) {
        mkdir $_organization_dir | Out-Null
    }
    $_project_dir = Join-Path $_organization_dir $_project_name

    # Output configuration details
    Write-Host "Project name:       $_project_name"
    Write-Host "Python version:     $_python_version"
    Write-Host "Organization Name:  $_organization"
    Write-Host "Dev Mode:           $_dev_mode"
    Write-Host "Reset project:      $_reset"
    Write-Host "VENVIT_DIR:         $_venvit_dir"
    Write-Host "PROJECTS_BASE_DIR:  $_project_base_dir"
    Write-Host "Organization dir:   $_organization_dir"
    Write-Host "PROJECT_DIR:        $_project_dir"
    Write-Host "VENV_BASE_DIR:      $_venv_base_dir"
    Write-Host "VENV_PYTHON_BASE:   $_python_base_dir"
    Write-Host "VENV_ENVIRONMENT:   $env:VENV_ENVIRONMENT"
    Write-Host "VENV_CONFIG_DIR:    $env:VENV_CONFIG_DIR"
    Write-Host "VENV_SECRETS_DIR:   $env:VENV_SECRETS_DIR"

    $_continue = ReadYesOrNo -_prompt_text "Continue"

    Write-Host $separator -ForegroundColor Cyan

    if ($_continue -eq "Y") {
        Set-Location -Path $_organization_dir.Substring(0, 2)
        Write-Host "$_python_base_dir\Python$_python_version\python -m venv --clear $_venv_base_dir\$_project_name_env"


        if ($env:VIRTUAL_ENV) {
            "Virtual environment is active at: $env:VIRTUAL_ENV, deactivating"
            deactivate
        }
        else {
            "No virtual environment is active."
        }

        # & deactivate  2>$null
        & $_python_base_dir\Python$_python_version\python -m venv --clear $_venv_base_dir\$_project_name"_env"
        & $_venv_base_dir"\"$_project_name"_env\Scripts\activate.ps1"
        python.exe -m pip install --upgrade pip

        # CreateProjectStructure

        $_project_install_path = Join-Path -Path $_project_dir -ChildPath "install.ps1"
        if (-not (Test-Path -Path $_project_install_path)) {
            New-Item -ItemType File -Path $_project_install_path -Force | Out-Null
            $s = 'Write-Host "Running ' + $_project_install_path + '..."' + " -ForegroundColor Yellow"
            Add-Content -Path $_project_install_path -Value $s
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir black"
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir flake8"
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir pre-commit"
            Add-Content -Path $_project_install_path -Value "pre-commit install"
            Add-Content -Path $_project_install_path -Value "pre-commit autoupdate"
            Write-Information ""
            if ($_dev_mode -eq "Y") {
                Add-Content -Path $_project_install_path -Value 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .[dev]}'
            }
            else {
                Add-Content -Path $_project_install_path -Value 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .}'
            }
        }
        if (-not (Test-Path "$_project_dir\.pre-commit-config.yaml")) { CreatePreCommitConfigYaml }

        $_support_scripts = @(
            "venv_${_project_name}_install.ps1",
            "venv_${_project_name}_setup_mandatory.ps1"
        )
        $_archive_dir = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath "Archive"
        if ($_reset -eq "Y") {
            foreach ($_file_name in $_support_scripts) {
                $_script_path = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $_file_name
                MoveFileToArchiveIfExists -_script_path $_script_path -_archive_dir $_archive_dir
            }
        }

        # Check if the install script does not exist
        $_script_install_path = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $_support_scripts[0]
        if (-not (Test-Path -Path $_script_install_path)) {
            # Create the script and write the lines
            $s = 'Write-Host "Running ' + $_support_scripts[0] + '..."' + " -ForegroundColor Yellow"
            Set-Content -Path $_script_install_path -Value $s
            Add-Content -Path $_script_install_path -Value "git init"
            $s = '& "' + "$_project_dir\install.ps1" + '"'
            Add-Content -Path $_script_install_path -Value $s
        }

        # Check if the mandatory setup script does not exist
        $_script_mandatory_path = Join-Path -Path $env:VENV_CONFIG_DIR -ChildPath $_support_scripts[1]
        if (-not (Test-Path $_script_mandatory_path)) {
            # Create the script and write the lines
            $s = 'Write-Host "Running ' + $_support_scripts[1] + '..."' + " -ForegroundColor Yellow"
            Set-Content -Path $_script_mandatory_path -Value $s
            Add-Content -Path $_script_mandatory_path -Value "`$env:VENV_PY_VER = '$_python_version'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:VENV_ORGANIZATION = '$_organization'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PYTHONPATH = '$_project_dir;$_project_dir\src;$_project_dir\src\$_project_name;$_project_dir\tests'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PROJECT_DIR = '$_project_dir'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PROJECT_NAME = '$_project_name'"
        }

        # Check if the custom setup script does not exist
        $_custom_file_name = "venv_${_project_name}_setup_custom.ps1"
        $_script_custom_path = Join-Path $env:VENV_CONFIG_DIR -ChildPath ${_custom_file_name}
        if (-not (Test-Path $_script_custom_path)) {
            $s = 'Write-Host "Running ' + $_custom_file_name + '..."' + " -ForegroundColor Yellow"
            Set-Content -Path $_script_custom_path -Value $s
            Add-Content -Path $_script_custom_path -Value ''
            Add-Content -Path $_script_custom_path -Value '# Override global environment variables by setting the here.  Uncomment them and set the correct value or add a variable by replacing "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:INSTALLER_PWD = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:INSTALLER_USERID = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:LINUX_ROOT_PWD = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:MYSQL_DATABASE = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:MYSQL_HOST = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:MYSQL_PWD = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:MYSQL_ROOT_PASSWORD = "??"'
            Add-Content -Path $_script_custom_path -Value '#$env:MYSQL_TCP_PORT = ??'
        }
        Write-Host $separator -ForegroundColor Cyan
        & $_script_mandatory_path
        Write-Host $separator -ForegroundColor Cyan
        & $_script_install_path
        Write-Host $separator -ForegroundColor Cyan
        & $_script_custom_path
        Write-Host $separator -ForegroundColor Cyan
    }
}

function DisplayEnvironmentVariables {
    Write-Host ""
    Write-Host "System Environment Variables" -ForegroundColor Green
    Write-Host "VENV_ENVIRONMENT:      $env:VENV_ENVIRONMENT"
    Write-Host "PROJECTS_BASE_DIR:     $env:PROJECTS_BASE_DIR"
    Write-Host "PROJECT_DIR:           $env:PROJECT_DIR"
    Write-Host "VENVIT_DIR:            $env:VENVIT_DIR"
    Write-Host "VENV_SECRETS_DIR:      $env:VENV_SECRETS_DIR"
    Write-Host "VENV_CONFIG_DIR:       $env:VENV_CONFIG_DIR"
    Write-Host "VENV_BASE_DIR:         $env:VENV_BASE_DIR"
    Write-Host "VENV_PYTHON_BASE_DIR:  $env:VENV_PYTHON_BASE_DIR"
    Write-Host ""
    Write-Host "Project Environment Variables" -ForegroundColor Green
    Write-Host "INSTALLER_PWD:        $env:INSTALLER_PWD"
    Write-Host "INSTALLER_USERID:     $env:INSTALLER_USERID"
    Write-Host "MYSQL_DATABASE:       $env:MYSQL_DATABASE"
    Write-Host "MYSQL_HOST:           $env:MYSQL_HOST"
    Write-Host "MYSQL_ROOT_PASSWORD:  $env:MYSQL_ROOT_PASSWORD"
    Write-Host "MYSQL_TCP_PORT:       $env:MYSQL_TCP_PORT"
    Write-Host ""
    Write-Host "Git Information" -ForegroundColor Green
    git branch --all
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

function MoveFileToArchiveIfExists {
    param (
        [string]$_script_path,
        [string]$_archive_dir
    )

    # Check if the file exists
    if (Test-Path $_script_path) {
        # Ensure the archive directory exists
        if (-not (Test-Path $_archive_dir)) {
            New-Item -Path $_archive_dir -ItemType Directory
        }

        # Move the file to the archive directory
        Move-Item -Path $_script_path -Destination $_archive_dir -Force
        Write-Host "Moved $($_script_path) to $($_archive_dir)."
    }
}

function ReadYesOrNo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$_prompt_text
    )
    do {
        $inputValue = Read-Host "$_prompt_text (Y/n)"
        $inputValue = $inputValue.ToUpper()
        if (-not $inputValue) {
            $inputValue = 'Y'
        }
    } while ($inputValue -ne 'Y' -and $inputValue -ne 'N')
    return $inputValue
}

function ShowHelp {
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

function ShowEnvVarHelp {
    Write-Host "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("VENV_ENVIRONMENT", $env:VENV_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("VENVIT_DIR", "$env:VENVIT_DIR"),
        @("VENV_SECRETS_DIR", "$env:VENV_SECRETS_DIR"),
        @("VENV_CONFIG_DIR, $env:VENV_CONFIG_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR"),
        @("VENV_PYTHON_BASE_DIR", "$env:VENV_PYTHON_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Host $var[0] -ForegroundColor Red -NoNewline
            Write-Host " - Not Set"
        }
        else {
            Write-Host $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " + $var[1]
            Write-Host $s
        }
    }
}

# Script execution starts here
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Write-Host ''
    Write-Host ''
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $separator = "-" * 80
    $project_name = $args[0]
    Write-Host "=[ START $dateTime ]=======================================[ vn.ps1 ]=" -ForegroundColor Blue
    Write-Host "Create new $project_name virtual environment" -ForegroundColor Blue
    CreateVirtualEnvironment -_project_name $args[0] -_python_version $args[1] -_organization $args[2] -_dev_mode $args[3] -_reset $args[4]
    DisplayEnvironmentVariables
    Write-Host '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
}
