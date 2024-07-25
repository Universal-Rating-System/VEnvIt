# VenvIt

A utility using Python and PowerShell scripts to to create, initiate and remove envirioments and virtual environments.

## Overview

The repository has the following tools and utilities:

- vn.ps1 (Create a new virtual environment)
- vi.ps1 (Initialize an existing virtual environment)
- vr.ps1 (Remove a virtual environment)
- download.ps1 (Commands to initiate the installation)
- install.ps1 (Install `venvit`)
- env_var_dev.ps1 (Sample environment configuration)

## vn.ps1

### Introduction

This script, `vn.ps1`, creates a Python virtual environment. It uses a combination of environment variables and command line parameters to set up the environment. If the target project directory already exists and has a `pyproject.toml`, the Python modules will be installed accordingly, alternatively it will install a default set of development tools.

- Pre-Commit
- Black
- flake8

### Project Linked PowerShell Configuration Scripts

It will also create three additional configuration PowerShell scripts. These scripts are specific to each project, support unique configuration options, and assist in the reinstallation and activation of the virtual environment. They reside in a subdirectory called `configs`.

1. venv\__project_name_\_install.ps1:
   Specific installation instructions for this project are provided. These instructions are only called during the installation (`vn.ps1`) of the virtual environment.

1. venv\__project_name_\_setup_mandatory.ps1:
   Contains mandatory instructions necessary for a successful initialization. It is called during both installation (`vn.ps1`) and initialization (`vi.ps1`) of the virtual environment.

1. venv\__project_name_\_setup_custom.ps1:
   An optional script for custom configuration instructions. It is called during both the installation (`vn.ps1`) and initialization (`vi.ps1`) of the virtual environment.

Notes:

1. _project_name_ is the first parameter for vn.ps1.
1. The three configuration scripts described above are unique for each virtual environment. They allow the user to configure the virtual environment uniquely.

### Environment Variables

The installation will set the following system environment variables.  Please see the description and instructions:

| System Environment Variable                    | Description                                                                                                                                                                                                                                                                                                                                               |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PROJECTS_BASE_DIR                              | The parent/base directory for all projects (e.g., `D:\GoogleDrive\Projects`). The idea is to separate the projects of various identities, such as personal projects and projects of an organization e.g. `\projects\company` and `\projects\myprojects`                                                                                                   |
| VENV_VENV_VENV_VENV_VENV_VENV_VENV_SECRETS_DIR | Directory for storing secrets (e.g., `~.\Secrets`). The contents of this directory are private, should not be shared, and should never be pushed to the repository.                                                                                                                                                                                       |
| VENVIT_DIR                                     | Installation directory where these script reside e.g. `\venv`                                                                                                                                                                                                                                                                                             |
| VENV_BASE_DIR                                  | The directory where the Python virtual environments are stored differs from the conventional practice of keeping virtual environment installation files within the project directory. Instead, all virtual environments are stored together in a separate directory (e.g., `c:\venv`). This directory should preferably not be a cloud storage directory. |
| VENV_ENVIRONMENT                               | Sets the variable to identify this environment. Possible values include: `loc_dev`, `github_dev`, `prod` or whatever you or the organization decide on. This value will be set differently in various environments to indicate the execution environment.                                                                                                 |
| VENV_PYTHON_BASE_DIR                           | Directory for Python installations (e.g., `C:\Python`). Different versions of Python will be accessed during the creation of the virtual environments. For example, if `VENV_PYTHON_BASE_DIR` is set to `C:\Python`, then Python 3.5 will be installed in `C:\Python\Python35` and Python 3.12 in `C:\Python\Python312`.                                  |

### Usage

```powershell
    vr.ps1 -h
```

or

```powershell
    vn.ps1 ProjectName PythonVer Institution DevMode ResetScripts
```

where:

| Parameter    | Description                                                                                                                                            |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ProjectName  | The name of the project.                                                                                                                               |
| PythonVer    | Python version for the virtual environment.                                                                                                            |
| Institution  | Acronym for the institution owning the project.                                                                                                        |
| DevMode      | \[y\|n\] If "y", installs \[dev\] modules from pyproject.toml.                                                                                         |
| ResetScripts | \[y\|n\] If "y", it zip and move the venv\__project_name_\_install.ps1 and venv\__project_name_\_setup_mandatory.ps1 scripts to the Archive directory. |

## vi.ps1

This script, `vi.ps1`, initializes an existing Python virtual environment. This include running the venv\__project_name_\_setup_custom.ps1 and venv\__project_name_\_setup_mandatory.ps1 scripts.

### Usage:

```powershell
    vi.ps1 -h
```

or

```powershell
    vi.ps1 ProjectName
```

where:

| Parameter   | Description              |
| ----------- | ------------------------ |
| ProjectName | The name of the project. |

## vr.ps1

This script, `vr.ps1`, remove the installed Python virtual environment. This include removing the _VENV_BASE_DIR\\project_name_env_ directory,  zip and move the venv\__project_name_\_install.ps1, venv\__project_name_\_setup_mandatory.ps1 and venv\__project_name_\_setup_custom.ps1 scripts to the `Archive` directory.
script.

### Usage:

```powershell
    vr.ps1 -h
```

or

```powershell
    vr.ps1 ProjectName
```

where:

| Parameter   | Description              |
| ----------- | ------------------------ |
| ProjectName | The name of the project. |

## Installation

1. Decide on the values for the System Environment Variables.

1. Remove any native Python installation and ensure that any references to any Python installation are removed from the PATH. This step is vital for a successful operation.

1. Install the various versions of Python you intend to use (e.g., `C:\Python\Python39`, `C:\Python\Python312`, etc.).  Make sure tyou use the following settings on the different installation configuration pages.  Following are the options based on a Python 3.10 installation.

   - [ ] **Do not** select "Use admin privileges when installaing py.exe".
   - [ ] **Do not** select "Add python.exe" to the PATH.
   - Use the "Customize installation".
   - [ ] **Unselect** "py launcher".
   - [ ] **Unselect** for all users (require admin proviledges).
   - [ ] **Unselect** "Install Python3.10 for all users".
   - [ ] **Unselect** "Create shortcuts for installed applications".
   - [ ] **Unselect** "Add Python to environment variables".
   - [x] **Select** "Precompile standard library".
   - [x] **Select** "Download debugging tools".
   - [x] **Select** "Download debug binaries (requires VS 2017 or later).
   - Change the "Customize install location" to e.g. 'C:\\Python\\Python310'

1. Open a new **PowerShell with Administrator rights**.  Do not use an existing one.  Paste the following script in the **PowerShell with Administrator rights**.  The script below can also be found in the `download.ps1` script.

   ```powershell
   $tempDir = New-Item -ItemType Directory -Path (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName()))
   $tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
   $installScriptPath = Join-Path -Path $tempDir.FullName -ChildPath "install.ps1"
   Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1" -OutFile $installScriptPath
   & $installScriptPath -release $tag -installScriptDir $tempDir
   Remove-Item -Path $tempDir.FullName -Recurse -Force
   Unblock-File "$env:VENVIT_DIR\vn.ps1"
   Unblock-File "$env:VENVIT_DIR\vi.ps1"
   Unblock-File "$env:VENVIT_DIR\vr.ps1"

   ```

1. Configure the env_var_dev.ps1 script in the SECRETS_DIR.

   - Set the ports for the various Docker containers.
   - Set the $env:MY_SCRT='AaBbCcDdE' combination to the correct name and value configured in GitHub.

1. Confirm your installation:

   1. Open a new PowerShell.

   1. Check with the `gci:env` command if the environment variables were created and has the correct values.

   1. ```powershell
       vn TestProject 310 myorg Y Y
      ```

   1.
