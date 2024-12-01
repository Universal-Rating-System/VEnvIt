# VenvIt

A utility using Python and PowerShell scripts to create, initiate and remove virtual environments for developers- and production systems. Due to the complexity and uniquness of these environments, care is taken to allow the users with much power to configure the enviroment. Consequently, instead of using configuration files (ini\\toml\\json), settings are set by user manipulated scripts. This brings complexity and a need for a good understanding of how this application work.

| **Category** | **Status' and Links** |
| ------------ | ------------------------------------------------------------------------------------------------------------------------- |
| General | [![][maintenance_y_img]][maintenance_y_lnk] [![][semver_pic]][semver_link] |
| CI | [![][pre_commit_ci_img]][pre_commit_ci_lnk] [![][codecov_img]][codecov_lnk] [![][gha_docu_img]][gha_docu_lnk] |
| Github | [![][gh_issues_img]][gh_issues_lnk] [![][gh_language_img]][gh_language_lnk] [![][gh_last_commit_img]][gh_last_commit_lnk] |

# Overview

The repository has the following tools and utilities:

- vn.ps1 (Create a new virtual environment)
- vi.ps1 (Initialize an existing virtual environment)
- vr.ps1 (Remove a virtual environment)
- Install.ps1 (Commands to initiate the installation)
- Install-Conclude.ps1 (Install `venvit`)
- secrets.ps1 (Sample environment configuration)

# vn.ps1

## Introduction

`vn.ps1`, creates a Python new virtual environment. It uses a combination of environment variables and command line parameters to set up the environment. If the target project directory already exists and has a `pyproject.toml`, the Python modules will be installed accordingly, alternatively it will install a default set of development tools:

- Pre-Commit
- Black
- flake8

## Project Linked PowerShell Configuration Scripts

It will also create eight additional configuration PowerShell scripts. These scripts are specific to each project, support unique configuration options, and assist in the installation and activation of the virtual environment. They reside in various subdirectories accessed through the environment variables pointing to the directories.

1. `VEnvProjectNameInstall.ps1`, `VEnvProjectNameEnvVar.ps1` and `VenVProjectNameSetup_custom.ps1` each are created in `VENV_CONFIG_DEFUALT_DIR` and `VENV_CONFIG_USER_DIR` during the execution of `vn.ps1`.

   1. _ProjectName_ referred to in the scriptnames below is the first parameter for vn.ps1.

   2. `VENV_CONFIG_DEFUALT_DIR` typically resides on a shared drive, preferably as a subdirectory of the main installation directory (`VENVIT_DIR`) for all developers of the organization to access it. It contains specific installation instructions for this project.

   3. `VENV_CONFIG_USER_DIR` typically reside on the developers/machine local drive, should only be exposed to the current user/environment. It contains instructions specifically for that user/environment. Settings set by the scripts in this dicretory supercede the settings set by scripts in `VENV_CONFIG_DEFUALT_DIR`.

   4. If the `-ResetScripts` switch is on, it will archive the current scripts for this project and create new hardcoded default scripts. With `-ResetScripts` switch off, the existing scripts will be called if they exist.

   5. 'VEnvProjectNameInstall.ps1' is only called by `vn.ps1`. It containes special instruction for this virtual environment being created. The initial default version can be updated. If the virtual environment is called again, it will call the updated script.<br>

      ```
      Note:
      If the `vr.ps1` script was called before to remove the virtual environment, the scripts are archived and a new one will be created.  You can refer to the archive created by `vr.ps1` to access the previous scripts.
      ```

   6. `VEnvProjectNameEnvVar.ps1` sets environment variables for the project.

   7. `VenVProjectNameSetup_custom.ps1` contains special instructions for setting up the virtual environment.

2. A `Secrets.ps1` is created in each of the ` VENV_SECRETS_DEFAULT_DIR` and ` VENV_SECRETS_DEFAULT_DIR` directories. It contains instructions specifically to setting secrets for the project.

3. The eight scripts described above are unique for each virtual environment. They allow the user to configure the virtual environment uniquely.

## Environment Variables

The installation will set the following system environment variables:

| System Environment Variable | Description |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PROJECTS_BASE_DIR | The parent/base directory for all projects (e.g., `~\Projects`). The idea is to organise\\group repositories by organization e.g. such as personal projects and projects of an organization e.g. `\projects\company` and `\projects\myprojects` |
| VENV_BASE_DIR | The directory where the Python virtual environments are stored. It differs from the conventional practice of keeping virtual environment installation files within the project directory. Instead, all virtual environments are stored together in a separate directory (e.g., `~\venv`). |
| VENV_CONFIG_DEFAULT_DIR | The default or "organization wide" scripts `VEnvProjectNameSetupCustom.ps1`, `VEnvProjectNameEnvVar.ps1` and `VEnvProjectNameInstall.ps1` scripts are stored here. This directory would typically be a subdirectory of `VENVIT_DIR` e.g `$VENVIT_DIR\$VENV_CONFIG_DEFAULT_DIR` and be shared for the use of all clients. |
| VENV_CONFIG_USER_DIR | Directory for storing user configuration scripts for the various virtual environments (e.g., `~.\VenvitConfigs`). `VENV_CONFIG_USER_DIR` should onbly be exposed to the current user\\machine. |
| VENV_ENVIRONMENT | Sets the variable to identify the working environment. Possible values include: `loc_dev`, `github_dev`, `prod` or whatever you or the organization decide on. This value will be set differently in various environments. The default will be set by `$VENV_CONFIG_DEFAULT_DIR\$VEnvProjectNameEnvVar.ps1` and should then be superceded in `$VENV_CONFIG_USER_DIR\$VEnvProjectNameEnvVar.ps1` to indicate the execution for that machine. |
| VENV_PYTHON_BASE_DIR | Directory for Python base installations (e.g., `C:\Python`). Different versions of Python will be accessed during the creation of the virtual environments. For example, if `VENV_PYTHON_BASE_DIR` is set to `C:\Python`, then Python 3.5 will be installed in `C:\Python\Python35` and Python 3.12 in `C:\Python\Python312`. |
| VENV_SECRETS_DEFAULT_DIR | Directory for storing default\\organization scripts with secrets for the current environmrnt as per VENV_ENVIRONMENT e.g. `$VENVIT_DIR\Secrets`. The contents of this directory is disclosed to all who have access to the installation. |
| VENV_SECRETS_USER_DIR | Directory for storing user scripts with secrets for the current environme e.g. `~.\Secrets`. The contents of this directory are private, should not be shared, and should never be pushed to the pository. This script will override similar values from VENV_SECRETS_DEFAULT_DIR |
| VENVIT_DIR | Installation directory where these script reside e.g. `\VEnvIt`. In an organizational structure this should be a shred drive. |

## Usage

```powershell
    vn.ps1 ProjectName PythonVer Institution -ResetScripts ResetScripts -DevMode DevMode
```

or

```powershell
    vn.ps1 -Help
```

or

```powershell
    vn.ps1 -Pester
```

where:

| Parameter | Description |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ProjectName | The name of the project. |
| PythonVer | Python version for the virtual environment e.g. 39 or 312 |
| Organization | Acronym for the institution owning the project. |
| ResetScripts | [y|n] If "y", it zip and move the `VEnvProjectNameSetupCustom.ps1`, `VEnvProjectNameEnvVar.ps1` and `VEnvProjectNameInstall.ps1` scripts to the Archive directory. |
| DevMode | [y|n] If "y", installs [dev] modules from pyproject.toml. |
| Pester | Used excludively for Pester testing purposes. |

# vi.ps1

`vi.ps1`, initializes an existing Python virtual environment. This includes running the `VEnvProjectNameSetupCustom.ps1` and `VEnvProjectNameEnvVar.ps1` scripts.

## Usage:

```powershell
    vi.ps1 ProjectName
```

or

```powershell
    vi.ps1 -Help
```

or

## Usage:

```powershell
    vi.ps1 -Pester
```

where:

| Parameter | Description |
| ----------- | --------------------------------------------- |
| ProjectName | The name of the project. |
| Pester | Used excludively for Pester testing purposes. |

# vr.ps1

`vr.ps1`, remove the installed Python virtual environment. This includes archiving and removing the `VEnvProjectNameSetupCustom.ps1`, `VEnvProjectNameEnvVar.ps1` and `VEnvProjectNameInstall.ps1` scripts.

## Usage:

```powershell
    vr.ps1 ProjectName
```

or

```powershell
    vr.ps1 -Help
```

or

```powershell
    vr.ps1 -Pester
```

where:

| Parameter | Description |
| ----------- | ------------------------ |
| ProjectName | The name of the project. |

# Server Installation

1. Decide on the values for the System Environment Variables.

2. Remove any native Python installation and ensure that any references to any Python installation are removed from the PATH. This step is vital for a successful operation.

3. Install the various versions of Python you intend to use (e.g., `C:\Python\Python39`, `C:\Python\Python312`, etc.). Make sure you use the following settings on the different installation configuration pages. Following are the options based on a Python 3.10 installation.

   - [ ] **Do not** select "Use admin privileges when installing py.exe."
   - [ ] **Do not** select "Add python.exe" to the PATH.
   - Use the "Customize installation."
   - [ ] **Unselect** "py launcher".
   - [ ] **Unselect** for all users (require admin privileges).
   - [ ] **Unselect** "Install Python3.10 for all users."
   - [ ] **Unselect** "Create shortcuts for installed applications."
   - [ ] **Unselect** "Add Python to environment variables."
   - [x] **Select** "Precompile standard library."
   - [x] **Select** "Download debugging tools."
   - [x] **Select** "Download debug binaries (requires VS 2017 or later)."
   - Change the "Customize install location" to e.g. 'C:\\Python\\Python310'

4. The shared directory VENVIT_DIR must exist and be accessible.

5. Open a new **PowerShell with Administrator rights**. Do not use an existing one. Paste the following script in the **PowerShell with Administrator rights**. The script below can also be found in the `Install.ps1` script.

   ```powershell
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
    $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $env:TEMP -ChildPath ("venvit_" + [Guid]::NewGuid().ToString()))
    $Tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
    $UpgradeScriptPath = Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "Installation-Files.zip"
    Invoke-WebRequest "https://github.com/BrightEdgeeServices/venvit/releases/download/$Tag/Installation-Files.zip" -OutFile $UpgradeScriptPath
    Expand-Archive -Path $UpgradeScriptPath -DestinationPath $UpgradeScriptDir
    Import-Module -Name (Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "src/Install-Conclude.psm1")
    Invoke-ConcludeInstall -Release $Tag -UpgradeScriptDir $UpgradeScriptDir`n
   ```

6. Configure the secrets.ps1 script in the VENV_SECRETS_DEFAULT_DIR and VENV_SECRETS_USER_DIR

   - Set the ports for the various Docker containers.
   - Set the $env:MY_SCRT='AaBbCcDdE' combination to the correct name and value configured in GitHub.

7. Confirm your installation:

   1. Open a new PowerShell.

   2. Check with the `gci:env` command if the environment variables were created and has the correct values.

   3. ```powershell
      vn MyProject 310 MyOrg Y Y
      ```

   4. Check the following:

      1. The virtual environment is activated.
      2. The current directory is `..\myorg\TestProject`.
      3. The environment variables exist and have the correct values:
         ```powershell
         gci env:
         ```

   5. ```powershell
      vi TestProject
      ```

   6. Check the following:

      1. The virtual environment is activated.
      2. The current directory is `..\myorg\TestProject`.

   7. ```powershell
       vr TestProject
      ```

   8. Check the following:

      1. The virtual environment is deactivated.

# Contributor Guide

Thank you for your interest in improving \`venvit'. This project is open-source under the [MIT license](https://github.com/BrightEdgeeServices/venvit/blob/master/LICENSE) and welcomes contributions in the form of bug reports, feature requests, and pull requests.

Here is a list of important resources for contributors:

- [Source Code](https://github.com/BrightEdgeeServices/venvit)

- [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues)

## How to report a bug

Report bugs on the [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues). When filing an issue, make sure to answer these questions:

- Describe the problem as complete as possible, using the following guidelines.
  - What was the command that you executed?
  - What did you expect to see?
  - What did you see instead?
- The best way to get your bug fixed is to provide a test case, and/or steps to reproduce the issue.
- Which operating system and Python version are you using?
- Which version of this project are you using?

## How to request a feature

Request features on the [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues). Please give as much detail as possible:

- Description of Feature or Improvement.
- What benefit it would bring to the system.
- Proposed Solution.

## How to submit changes

- Open a pull request to submit changes to this project.

- If your changes add functionality, update the documentation accordingly.

- It is recommended to open an issue before starting work on anything. This will allow a chance to talk it over with the owners and validate your approach.

# Example how to use vi, vn and vr

To be completed

[codecov_img]: https://img.shields.io/codecov/c/gh/BrightEdgeeServices/venvit "CodeCov"
[codecov_lnk]: (https://app.codecov.io/gh/BrightEdgeeServices/venvit) "CodeCov"
[gha_docu_img]: https://img.shields.io/readthedocs/venvit "Read the Docs"
[gha_docu_lnk]: https://github.com/BrightEdgeeServices/venvit/blob/master/.github/workflows/02-check-documentation.yml "Read the Docs"
[gh_issues_img]: https://img.shields.io/github/issues-raw/BrightEdgeeServices/venvit "GitHub - Issue Counter"
[gh_issues_lnk]: https://github.com/BrightEdgeeServices/venvit/issues "GitHub - Issue Counter"
[gh_language_img]: https://img.shields.io/github/languages/top/BrightEdgeeServices/venvit "GitHub - Top Language"
[gh_language_lnk]: https://github.com/BrightEdgeeServices/venvit "GitHub - Top Language"
[gh_last_commit_img]: https://img.shields.io/github/last-commit/BrightEdgeeServices/venvit/master "GitHub - Last Commit"
[gh_last_commit_lnk]: https://github.com/BrightEdgeeServices/venvit/commit/master "GitHub - Last Commit"
[maintenance_y_img]: https://img.shields.io/badge/Maintenance%20Intended-%E2%9C%94-green.svg?style=flat-square "Maintenance - intended"
[maintenance_y_lnk]: http://unmaintained.tech/ "Maintenance - intended"
[pre_commit_ci_img]: https://img.shields.io/github/actions/workflow/status/BrightEdgeeServices/venvit/01-pre-commit-and-document-check.yml?label=pre-commit "Pre-Commit"
[pre_commit_ci_lnk]: https://github.com/BrightEdgeeServices/venvit/blob/master/.github/workflows/01-pre-commit-and-document-check.yml "Pre-Commit"
[semver_link]: https://semver.org/ "Sentic Versioning - 2.0.0"
[semver_pic]: https://img.shields.io/badge/Semantic%20Versioning-2.0.0-brightgreen.svg?style=flat-square "Sentic Versioning - 2.0.0"
