# RealTimeEvents Common

A utility to create, initiate and remove Python virtual envirioments.

______________________________________________________________________

## Overview

The repository has the following tools and utilities:

- vn.ps1 (Create a new virtual environment)
- vi.ps1 (Initialize an existing virtual environment)
- vr.ps1 (Remove a virtual environment)
- download.ps1 (Commands to initiate the installation)
- install.ps1 (Install `venvit`)

## vn.ps1

### Introduction

This script, `vn.ps1`, creates a Python virtual environment. It uses a combination of environment variables and command line parameters to set up the environment. If a `pyproject.toml` file already exists in the project directory, Python modules will be installed accordingly, alternatively it will install a default set of development tools.

- Pre-Commit
- Black
- flake8

### Project Linked PowerShell Configuration Scripts

It will also create three additional configuration PowerShell scripts. These scripts are specific to each project, support unique configuration options and assist in the reinstallation and activation of the virtual environment.  THey exist in a sub directory called `configs`.

1. \`venv\__project_name_\_install.ps1:
   Specific installation instructions for this project. It is only called during the installation (vn.ps1) of the virtual environment.

1. venv\__project_name_\_setup_mandatory.ps1:
   Contains mandatory instructions necessary for a successful initialization. It is
   called during both installation (vn.ps1) and initialization (vi.ps1) of the
   virtual environment.

1. venv\__project_name_\_setup_custom.ps1:
   An optional script for custom configuration instructions. It is called during
   both installation (vn.ps1) and initialization (vi.ps1) of the virtual environment.

Notes:

1. `$project_name` is the first parameter for vn.ps1.
1. The three confiiguration scripts are unique scripts to allow the user to configure the virtual environemtn uniquely.

### Environment Variables

The installation will set the following system environment variables.  Please see the description and instructions:

| System Environment Variable | Description                                                                                                                                                                                                                                                                                                                                                   |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PROJECTS_BASE_DIR           | The directory for all projects (e.g., d:\\Dropbox\\Projects). The idea is to separate the projects of various identities e.g. personal projects and projects of an organization.                                                                                                                                                                              |
| SECRETS_DIR                 | Directory for storing secrets (e.g., g:\\Google Drive\\Secrets). The contents of this directory is private, should not be shared and are newver pushed to the repository.                                                                                                                                                                                     |
| VENVIT_DIR                  | Installation directory where these script resides.  Potentially a shared drive in an organization.                                                                                                                                                                                                                                                            |
| VENV_BASE_DIR               | The directory where the Python virtual environments are stored (e.g., C:\\venv) is different from the conventional practice of keeping virtual environment installation files within the project directory. Instead, all virtual environments are stored together in a separate directory. This directory should preferably not be a cloud storage directory. |
| VENV_ENVIRONMENT            | Sets the development environment. Possible values include: loc_dev, github_dev, prod, etc. This value will be set differently in various environments to indicate the execution environment.                                                                                                                                                                  |
| VENV_PYTHON_BASE_DIR        | Directory for Python installations (e.g., C:\\Python). Different versions of Python will be accessed during the creation of the virtual environments. For example, if VENV_PYTHON_BASE_DIR is set to C:\\Python, then Python 3.5 will be installed in C:\\Python\\Python35 and Python 3.12 in C:\\Python\\Python312.                                          |

### Preparation

1. Create the shared drive VENVIT_DIR in an Organization installation.
1. Remove any native Python installation and remove any reference of Python from the PATH.  This step is extremely important.
1. Install the various versions of Python in e.g. c:\\Python\\Python39.  Do not:
   - Add Python to the Path
   -

### Usage

```powershell
    vr.ps1 -h
```

or

```powershell
    vn.ps1 ProjectName PythonVer Institution DevMode ResetScripts
```

where:

- ProjectName:  The name of the project.
- PythonVer:    Python version for the virtual environment.
- Institution:  Acronym for the institution owning the project.
- DevMode:      If "Y", installs \[dev\] modules from pyproject.toml.
- ResetScripts: If "Y", moves certain scripts to the Archive directory.

## vi.ps1

This script, `vi.ps1`, initializes an existing Python virtual environment. This include running the venv\_`${_project_name}`_setup_custom.ps1 and venv_`${_project_name}`\_setup_mandatory.ps1 scripts.

### Usage:

```powershell
    vi.ps1 -h
```

or

```powershell
    vi.ps1 ProjectName
```

where:

- ProjectName:  The name of the project.

## vr.ps1

This script, `vr.ps1`, remove the installed Python virtual environment. This include removing the `${env:VENV_BASE_DIR}`\\`${_project_name}`\_env directory and moving the venv\_`${_project_name}`\_install.ps1 and venv\_`${_project_name}`\_setup_mandatory.ps1 scripts to the Archive directory.  It does not remove the venv\_`${_project_name}`\_setup_custom.ps1
script.

### Usage:

```powershell
    vr.ps1 -h
```

or

```powershell
    vi.ps1 ProjectName
```

## Installation

1. If you installing it for your organization i.e. a shared installation, create a shared drive i.e. on Google Drive, Dropbox or OneDrive and share the drive accordingly first.

1. Paste the following script in a PowerShell.

   ```powershell
   $tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
   Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1" -OutFile "install.ps1"
   .\install.ps1 -release $tag
   ```

1.
