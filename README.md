# RealTimeEvents Common

Tools to create, initiate and remove Python virtual envirioments.

______________________________________________________________________

## Overview

The repository has the following tools:

- vn.ps1 (Create a new virtual environment)
- vi.ps1 (Initialize an existing virtual environment)
- vr.ps1 (REmove a virtual environment)

## vn.ps1

### Introduction

This script, `vn.ps1`, creates a Python virtual environment. It uses a combination of environment variables and command line parameters to set up the environment. If a `pyproject.toml` file already exists in the project directory, Python modules will be installed accordingly.

### Project Linked PowerShell Configuration Scripts

This script will create three additional PowerShell scripts. These scripts are specific to the project, support unique configuration options and assist in the reinstallation and activation of the virtual environment.  If the installation is a private installation, they can exist in the installation directory.  If the installation is for an Organization, the configuration scripts should be in a proivate directory e.g. the home directory of the user.

1. venv\_`${project_name}`\_install.ps1:
   Contains specific installation instructions for this project. It is only called
   during the installation (vn.ps1) of the virtual environment.

1. venv\_`${project_name}`\_setup_mandatory.ps1:
   Contains mandatory instructions necessary for a successful initialization. It is
   called during both installation (vn.ps1) and initialization (vi.ps1) of the
   virtual environment.

1. venv\_`${project_name}`\_setup_custom.ps1:
   An optional script for custom configuration instructions. It is called during
   both installation (vn.ps1) and initialization (vi.ps1) of the virtual environment.

Notes:

1. `$project_name` is the first parameter for vn.ps1.
1. The three confiiguration scripts are unique scripts to allow the user to configure the virtual environemtn uniquely.

### Environment Variables

Prior to starting the PowerShell script, ensure these environment variables are set.

| Variable Name | Description|
|---|---|
| PROJECTS_BASE_DIR | The directory for all projects (e.g., d:\\Dropbox\\Projects). |
| SECRETS_DIR | Directory for storing secrets (e.g., g:\\Google Drive\\Secrets). |
| VENVIT_DIR | Directory where this script resides.
| VENV_BASE_DIR | Directory for virtual environments (e.g., c:\\venv).
| VENV_ENVIRONMENT  | Sets the development environment. Possible values: loc_dev, github_dev, prod, etc. |
| VENV_PYTHON_BASE_DIR | Directory for Python installations (e.g., c:\\Python).

### Usage:

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
./install.ps1 $tag

```
