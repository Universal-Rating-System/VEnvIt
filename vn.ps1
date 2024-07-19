# Define a function to handle creating a new virtual environment
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

function CreateVirtualEnvironment {
    param (
        [string]$_project_name,
        [string]$_python_version,
        [string]$_institution,
        [string]$_dev_mode,
        [string]$_reset
    )

    # Clear the screen
    # Clear-Host

    # Show help if no project name is provided
    if (-not $_project_name -or $_project_name -eq "-h") {
            ShowHelp
        return
    }

    Write-Information "Create new $_project_name virtual environment"

    # Check for required environment variables and display help if they're missing
    if (-not $env:RTE_ENVIRONMENT -or -not $env:SCRIPTS_DIR -or -not $env:SECRETS_DIR -or -not $env:PROJECTS_BASE_DIR -or -not $env:VENV_BASE_DIR -or -not $env:VENV_PYTHON_BASE_DIR) {
        ShowEnvVarHelp
        return
    }

    $env:PROJECT_NAME = $_project_name
    if ($env:RTE_ENVIRONMENT -eq "loc_dev") {
        & "$env:SECRETS_DIR\env_var_dev.ps1"
    }

    # Set local variables from environment variables
    $_python_base_dir = $env:VENV_PYTHON_BASE_DIR
    $_venv_base_dir = $env:VENV_BASE_DIR
    $_scripts_dir = $env:SCRIPTS_DIR
    $_project_base_dir = $env:PROJECTS_BASE_DIR
    $_project_name = if (-not $_project_name) { Read-Host "Project name" } else { $_project_name }
    $_python_version = if (-not $_python_version) { Read-Host "Python version" } else { $_python_version }
    $_institution = if (-not $_institution) { Read-Host "Institution" } else { $_institution }
    if (-not $_dev_mode -eq "Y" -or -not $_dev_mode -eq "N" -or [string]::IsNullOrWhiteSpace($_dev_mode)) {
        $_dev_mode = ReadYesOrNo -_prompt_text "Dev mode"
    }
    if (-not $_reset -eq "Y" -or -not $_reset -eq "N" -or [string]::IsNullOrWhiteSpace($_reset)) {
        $_reset = ReadYesOrNo -_prompt_text "Reset scripts"
    }

    # Determine project directory based on institution
    switch ($_institution) {
        "PP" { $_institution_dir = Join-Path $_project_base_dir "PP" }
        "RTE" { $_institution_dir = Join-Path $_project_base_dir "RTE" }
        "RE" { $_institution_dir = Join-Path $_project_base_dir "ReahlExamples" }
        "HdT" { $_institution_dir = Join-Path $_project_base_dir "HdT" }
        "DdT" { $_institution_dir = Join-Path $_project_base_dir "DdT" }
        "Citiq" { $_institution_dir = Join-Path $_project_base_dir "Citiq" }
        default { $_institution_dir = Join-Path $_project_base_dir "BEE" }
    }
    # Create institution directory if it does not exist
    if (-not (Test-Path $_institution_dir)) {mkdir $_institution_dir}
    $_project_dir = Join-Path $_institution_dir $_project_name

    # Output configuration details
    Write-Information "Project name:      $_project_name"
    Write-Information "Python version:    $_python_version"
    Write-Information "Institution Accr:  $_institution"
    Write-Information "Dev Mode:          $_dev_mode"
    Write-Information "Reset project:     $_reset"
    Write-Information "SCRIPTS_DIR:       $_scripts_dir"
    Write-Information "PROJECTS_BASE_DIR: $_project_base_dir"
    Write-Information "INSTITUTION_DIR:   $_institution_dir"
    Write-Information "PROJECT_DIR:       $_project_dir"
    Write-Information "VENV_BASE_DIR:     $_venv_base_dir"
    Write-Information "VENV_PYTHON_BASE:  $_python_base_dir"

    $_continue = ReadYesOrNo -_prompt_text "Continue"

    if ($_continue -eq "Y") {
        Set-Location -Path $_institution_dir.Substring(0,2)
        Write-Information "$_python_base_dir\Python$_python_version\python -m venv --clear $_venv_base_dir\$_project_name_env"


        if ($env:VIRTUAL_ENV) {
            "Virtual environment is active at: $env:VIRTUAL_ENV, deactivating"
            deactivate
            } else {
            "No virtual environment is active."
        }

        # & deactivate  2>$null
        & $_python_base_dir\Python$_python_version\python -m venv --clear $_venv_base_dir\$_project_name"_env"
        & $_venv_base_dir"\"$_project_name"_env\Scripts\activate.ps1"
        python.exe -m pip install --upgrade pip

        if (-not (Test-Path $_project_dir)) {
            New-Item -ItemType Directory -Path "$_project_dir" -Force
            New-Item -ItemType Directory -Path "$_project_dir\docs" -Force
        }

        Set-Location -Path $_project_dir
        if (-not (Test-Path "$_project_dir\docs\requirements_docs.txt")) {
            New-Item -ItemType File -Path "$_project_dir\docs\requirements_docs.txt" -Force
        }

        $_project_install_path = Join-Path -Path $_project_dir -ChildPath "install.ps1"
        if (-not (Test-Path -Path $_project_install_path)) {
            New-Item -ItemType File -Path $_project_install_path -Force
            $s = 'Write-Information "Running ' + $_project_install_path + '..."' + " -ForegroundColor Yellow"
            Add-Content -Path $_project_install_path -Value $s
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir black"
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir flake8"
            Add-Content -Path $_project_install_path -Value "pip install --upgrade --force --no-cache-dir pre-commit"
            Add-Content -Path $_project_install_path -Value "pre-commit install"
            Add-Content -Path $_project_install_path -Value "pre-commit autoupdate"
            Add-Content ""
            if($_dev_mode -eq "Y") {
                Add-Content -Path $_project_install_path -Value 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .[dev]}'
                } else {
                    Add-Content -Path $_project_install_path -Value 'if (Test-Path -Path $env:PROJECT_DIR\pyproject.toml) {pip install --no-cache-dir -e .}'
            }        }
        if (-not (Test-Path "$_project_dir\.pre-commit-config.yaml")) { CreatePreCommitConfigYaml }

        $_support_scripts = @(
            "venv_${_project_name}_install.ps1",
            "venv_${_project_name}_setup_mandatory.ps1"
        )
        $_archive_dir = Join-Path -Path $_scripts_dir -ChildPath "Archive"
        if ($_reset -eq "Y") {
            foreach ($_file_name in $_support_scripts) {
                $_script_path = Join-Path -Path $_scripts_dir -ChildPath $_file_name
                MoveFileToArchiveIfExists -_script_path $_script_path -_archive_dir $_archive_dir
            }
        }

        # Check if the install script does not exist
        $_script_install_path = Join-Path -Path $_scripts_dir -ChildPath $_support_scripts[0]
        if (-not (Test-Path -Path $_script_install_path)) {
            # Create the script and write the lines
            $s = 'Write-Information "Running ' + $_support_scripts[0] + '..."' + " -ForegroundColor Yellow"
            Set-Content -Path $_script_install_path -Value $s
            Add-Content -Path $_script_install_path -Value "git init"
            $s = '& "' + "$_project_dir\install.ps1" + '"'
            Add-Content -Path $_script_install_path -Value $s
        }

        # Check if the mandatory setup script does not exist
        $_script_mandatory_path = Join-Path -Path $_scripts_dir -ChildPath $_support_scripts[1]
        if (-not (Test-Path $_script_mandatory_path)) {
            # Create the script and write the lines
            $s = 'Write-Information "Running ' + $_support_scripts[1] + '..."' + " -ForegroundColor Yellow"
            Set-Content -Path $_script_mandatory_path -Value $s
            Add-Content -Path $_script_mandatory_path -Value "`$env:VENV_PY_VER = '$_python_version'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:VENV_INSTITUTION = '$_institution'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PYTHONPATH = '$_project_dir;$_project_dir\src;$_project_dir\src\$_project_name;$_project_dir\tests'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PROJECT_DIR = '$_project_dir'"
            Add-Content -Path $_script_mandatory_path -Value "`$env:PROJECT_NAME = '$_project_name'"
        }

        # Check if the custom setup script does not exist
        $_custom_file_name = "venv_${_project_name}_setup_custom.ps1"
        $_script_custom_path = Join-Path $_scripts_dir -ChildPath ${_custom_file_name}
        if (-not (Test-Path $_script_custom_path)) {
            $s = 'Write-Information "Running ' + $_custom_file_name + '..."' + " -ForegroundColor Yellow"
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
        & $_script_mandatory_path
        & $_script_install_path
        & $_script_custom_path
    }
}

function DisplayEnvironmentVariables {
    Write-Information ""
    Write-Information "System Environment Variables"  -ForegroundColor Green
    Write-Information "RTE_ENVIRONMENT:       $env:RTE_ENVIRONMENT"
    Write-Information "PROJECTS_BASE_DIR:     $env:PROJECTS_BASE_DIR"
    Write-Information "PROJECT_DIR:           $env:PROJECT_DIR"
    Write-Information "SCRIPTS_DIR:           $env:SCRIPTS_DIR"
    Write-Information "SECRETS_DIR:           $env:SECRETS_DIR"
    Write-Information "VENV_BASE_DIR:         $env:VENV_BASE_DIR"
    Write-Information "VENV_PYTHON_BASE_DIR:  $env:VENV_PYTHON_BASE_DIR"
    Write-Information ""
    Write-Information "Project Environment Variables"  -ForegroundColor Green
    Write-Information "INSTALLER_PWD:        $env:INSTALLER_PWD"
    Write-Information "INSTALLER_USERID:     $env:INSTALLER_USERID"
    Write-Information "MYSQL_DATABASE:       $env:MYSQL_DATABASE"
    Write-Information "MYSQL_HOST:           $env:MYSQL_HOST"
    Write-Information "MYSQL_ROOT_PASSWORD:  $env:MYSQL_ROOT_PASSWORD"
    Write-Information "MYSQL_TCP_PORT:       $env:MYSQL_TCP_PORT"
    Write-Information ""
    Write-Information "Git Information"  -ForegroundColor Green
    git branch --all
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
        Write-Information "Moved $($_script_path) to $($_archive_dir)."
    } else {
        Write-Information "File $($_script_path) does not exist."
    }
}


function ShowHelp {
    $separator = "-" * 80
    Write-Information $separator -ForegroundColor Cyan

    # Introduction
@"
This script, 'vn.ps1', creates a Python virtual environment. It uses a combination
of environment variables and command line parameters to set up the environment.
If a 'pyproject.toml' file already exists in the project directory, Python modules
will be installed accordingly. If the '_dev_mode' command line parameter is set
to "Y", the modules in the [dev] section of the pyproject.toml will also be installed.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan

    # Project Linked PowerShell Scripts
@"
    Support PowerShell Scripts:
    ----------------------------------
    This script will create three additional PowerShell scripts. These scripts are
    specific to the project and assist in the reinstallation and activation of the
    virtual environment:

    1. venv_'${project_name}'_install.ps1:
        Contains specific installation instructions for this project. It is only called
        during the installation (vn.ps1) of the virtual environment.

    2. venv_'${project_name}'_setup_mandatory.ps1:
        Contains mandatory instructions necessary for a successful initialization. It is
        called during both installation (vn.ps1) and initialization (vi.ps1) of the
        virtual environment.

    3. venv_'${project_name}'_setup_custom.ps1:
        An optional script for custom configuration instructions. It is called during
        both installation (vn.ps1) and initialization (vi.ps1) of the virtual environment.

    Notes:
    1. '$project_name' is the first parameter for vn.ps1.
    2. The three Support PowerShell Scripts are not pushed to the repository.  These files
       are specific to the macine it is installed on.  If the loca repository is in cloud
       storage, it will be synced to the othr installations of the user.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan

    # Environment Variables
@"
    Environment Variables:
    ----------------------
    Prior to starting the PowerShell script, ensure these environment variables are set.

    1. RTE_ENVIRONMENT: Sets the development environment. Possible values: loc_dev, github_dev, prod, etc.
    2. PROJECTS_BASE_DIR: The directory for all projects (e.g., d:\Dropbox\Projects).
    3. SECRETS_DIR: Directory for storing secrets (e.g., g:\Google Drive\Secrets).
    4. SCRIPTS_DIR: Directory where this script resides.
    5. VENV_BASE_DIR: Directory for virtual environments (e.g., c:\venv).
    6. VENV_PYTHON_BASE_DIR: Directory for Python installations (e.g., c:\Python).
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan

    # Usage
@"
    Usage:
    ------
    vn.ps1 ProjectName PythonVer Institution DevMode ResetScripts
    vr.ps1 -h

    Parameters:
    1. ProjectName:  The name of the project.
    2. PythonVer:    Python version for the virtual environment.
    3. Institution:  Acronym for the institution owning the project.
    4. DevMode:      If "Y", installs [dev] modules from pyproject.toml.
    5. ResetScripts: If "Y", moves certain scripts to the Archive directory.
"@ | Write-Information

    Write-Information $separator -ForegroundColor Cyan
}

function ShowEnvVarHelp {
    Write-Information "Make sure the following system environment variables are set. See the help for more detail." -ForegroundColor Cyan

    $_env_vars = @(
        @("RTE_ENVIRONMENT", $env:RTE_ENVIRONMENT),
        @("PROJECTS_BASE_DIR", "$env:PROJECTS_BASE_DIR"),
        @("SCRIPTS_DIR", "$env:SCRIPTS_DIR"),
        @("SECRETS_DIR", "$env:SECRETS_DIR"),
        @("VENV_BASE_DIR", "$env:VENV_BASE_DIR"),
        @("VENV_PYTHON_BASE_DIR", "$env:VENV_PYTHON_BASE_DIR")
    )

    foreach ($var in $_env_vars) {
        if ([string]::IsNullOrEmpty($var[1])) {
            Write-Information $var[0] -ForegroundColor Red -NoNewline
            Write-Information " - Not Set"
        } else {
            Write-Information $var[0] -ForegroundColor Green -NoNewline
            $s = " - Set to: " +  $var[1]
            Write-Information $s
        }
    }
}

function ReadYesOrNo {
    param (
        [Parameter(Mandatory=$true)]
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

# Script execution starts here
Write-Information ''
Write-Information ''
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Information "=[ START $dateTime ]==================================================" -ForegroundColor Blue
CreateVirtualEnvironment -_project_name $args[0] -_python_version $args[1] -_institution $args[2] -_dev_mode $args[3] -_reset $args[4]
DisplayEnvironmentVariables
Write-Information '-[ END ]------------------------------------------------------------------------' -ForegroundColor Cyan
