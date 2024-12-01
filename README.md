# VEnvIt

| **Category** | **Status' and Links** |
| ------------ | ------------------------------------------------------------------------------------------------------------------------- |
| General | \[![][maintenance_y_img]\][maintenance_y_lnk] \[![][semver_pic]\][semver_link] |
| CI | \[![][pre_commit_ci_img]\][pre_commit_ci_lnk] \[![][codecov_img]\][codecov_lnk] \[![][gha_docu_img]\][gha_docu_lnk] |
| Github | \[![][gh_issues_img]\][gh_issues_lnk] \[![][gh_language_img]\][gh_language_lnk] \[![][gh_last_commit_img]\][gh_last_commit_lnk] |

VEnvIt is a utility that employs Python and PowerShell scripts to create, initialize, and remove virtual environments tailored for both development and production systems. It provides significant flexibility, allowing users to configure their environments according to specific requirements.

Instead of relying on traditional configuration files (INI, TOML, JSON), VEnvIt uses user-modifiable scripts for settings configuration. This design choice offers greater flexibility and adaptability, enabling fine-grained customization that standard configuration files cannot accommodate.

However, this approach introduces additional complexity and requires a thorough understanding of the application's workings. Proficiency in Python and PowerShell scripting is essential to effectively utilize and configure VEnvIt.

## Key Features

- **Flexible Environment Management**: Create, initialize, and remove virtual environments using customizable scripts.
- **User-Controlled Configuration**: Configure settings through scripts for maximum adaptability.
- **Tailored for Complex Systems**: Designed to handle the intricacies of unique development and production environments.

## Prerequisites

- **Scripting Knowledge**: Familiarity with Python and PowerShell scripting languages.
- **Understanding of Virtual Environments**: Basic knowledge of virtual environments and their role in development and production systems.

# Usage Overview

VEnvIt provides three primary scripts for managing virtual environments:

- `vn.ps1`: Creates a new virtual environment.
- `vi.ps1`: Initializes an existing virtual environment.
- `vr.ps1`: Removes a virtual environment.

Additional configuration scripts are auto-generated during environment setup for customization.

# Detailed Usage

## Creating a New Virtual Environment (`vn.ps1`)

### Introduction

The `vn.ps1` script creates a new Python virtual environment. It uses a combination of environment variables and command-line parameters to set up the environment. If the target project directory already exists and contains a `pyproject.toml` file, the Python modules will be installed accordingly. Otherwise, it installs a default set of development tools:

- **Pre-Commit**
- **Black**
- **Flake8**

### Syntax

```powershell
.\vn.ps1 -ProjectName <ProjectName> -PythonVer <PythonVer> -Organization <Organization> [-ResetScripts y|n] [-DevMode y|n]
```

or

```powershell
.\vn.ps1 -Help
```

or

### Parameters

- `ProjectName`: The name of the project.
- `PythonVer`: The Python version for the virtual environment (e.g., `39` or `312`).
- `Organization`: Acronym for the organization owning the project.
- `-ResetScripts`: Optional. Use `-ResetScripts y` to reset scripts.
- `-DevMode`: Optional. Use `-DevMode y` to install development modules from `pyproject.toml`.

### Example

```powershell
.\vn.ps1 -ProjectName MyProject -PythonVer 310 -Organization MyOrg -ResetScripts y -DevMode y
```

This command creates a new virtual environment for a project named **MyProject**, using Python 3.10, associated with the organization **MyOrg**, resets scripts, and installs development modules.

## Initializing an Existing Virtual Environment (`vi.ps1`)

### Introduction

The `vi.ps1` script initializes an existing virtual environment, ensuring all configurations and dependencies are up to date. This includes running project-specific setup and environment variable scripts.

### Syntax

```powershell
.\vi.ps1 -ProjectName <ProjectName>
```

### Parameters

- `ProjectName`: The name of the project.

### Example

```powershell
.\vi.ps1 -ProjectName MyProject
```

or

```powershell
.\vi.ps1 -Help
```

This command initializes the virtual environment for **MyProject**.

## Removing a Virtual Environment (`vr.ps1`)

### Introduction

The `vr.ps1` script removes an existing virtual environment, including all associated configurations and dependencies. It also archives and removes project-specific configuration scripts.

### Syntax

```powershell
.\vr.ps1 -ProjectName <ProjectName>
```

### Parameters

- `ProjectName`: The name of the project.

### Example

```powershell
.\vr.ps1 -ProjectName MyProject
```

This command removes the virtual environment for **MyProject**.

# Project-Specific PowerShell Configuration Scripts

When you create a new virtual environment using `vn.ps1`, it generates additional PowerShell configuration scripts specific to the project. These scripts support unique configuration options and assist in the installation and activation of the virtual environment. They reside in various subdirectories accessed through environment variables pointing to these directories.

### Script Descriptions

1. **`VEnv<ProjectName>Install.ps1`**: Contains special instructions for installing this virtual environment. It is only called by `vn.ps1`. The initial default version can be updated for subsequent runs.
2. **`VEnv<ProjectName>EnvVar.ps1`**: Sets environment variables for the project.
3. **`VEnv<ProjectName>Setup_custom.ps1`**: Contains special instructions for setting up the virtual environment.
4. **`Secrets.ps1`**: Contains instructions for setting secrets for the project. Created in both the default and user secrets directories (`VENV_SECRETS_DEFAULT_DIR` and `VENV_SECRETS_USER_DIR`).

### Script Locations

- **Default Configuration Directory (`VENV_CONFIG_DEFAULT_DIR`)**: This directory typically resides on a shared drive, preferably as a subdirectory of the main installation directory (`VENVIT_DIR`). It contains organization-wide scripts.
- **User Configuration Directory (`VENV_CONFIG_USER_DIR`)**: This directory typically resides on the local drive of the developer's machine and should only be accessible to the current user/environment. Scripts here override those in the default directory.

### Script Management

- If the `-ResetScripts` switch is used with `vn.ps1`, it will archive the current scripts for this project and create new default scripts. Without `-ResetScripts`, existing scripts will be used if they exist.
- If `vr.ps1` is called to remove the virtual environment, the scripts are archived, and new ones will be created upon the next execution of `vn.ps1`. You can refer to the archive created by `vr.ps1` to access previous scripts.

# Environment Variables

VEnvIt utilizes several environment variables to manage virtual environments effectively. These variables should be set during installation.

| Environment Variable | Description |
| -------------------- | ----------- |
| **PROJECTS_BASE_DIR** | The parent/base directory for all projects (e.g., `C:\Projects`). Organize repositories by organization, such as personal projects and organizational projects (e.g., `C:\Projects\MyOrg\MyProject`, `C:\Projects\Company\CompanyProject`). |
| **VENV_BASE_DIR** | The directory where the Python virtual environments are stored (e.g., `~\venv`). Unlike the conventional practice of keeping virtual environment files within the project directory, all virtual environments are stored together in this dedicated directory. |
| **VENV_CONFIG_DEFAULT_DIR** | Directory for default (organization-wide) configuration scripts. Typically a subdirectory of `VENVIT_DIR` (e.g., `$VENVIT_DIR\Configs`). Shared among all developers. |
| **VENV_CONFIG_USER_DIR** | Directory for user-specific configuration scripts (e.g., `~\VEnvIt\Configs`). Should only be accessible to the current user/machine. Scripts here override those in the default directory. |
| **VENV_ENVIRONMENT** | Identifies the working environment. Possible values include `loc_dev`, `github_dev`, `prod`, or other values defined by the organization. This variable may be set differently in various environments. The default is set in `$VENV_CONFIG_DEFAULT_DIR\VEnv<ProjectName>EnvVar.ps1` and can be overridden in `$VENV_CONFIG_USER_DIR\VEnv<ProjectName>EnvVar.ps1`. |
| **VENV_PYTHON_BASE_DIR** | Directory for Python base installations (e.g., `C:\Python`). Different versions of Python are accessed during the creation of virtual environments (e.g., `C:\Python\Python35`, `C:\Python\Python312`). |
| **VENV_SECRETS_DEFAULT_DIR** | Directory for default (organization-wide) secrets scripts for the current environment as per `VENV_ENVIRONMENT` (e.g., `$VENVIT_DIR\Secrets`). Contents are accessible to all who have access to the installation. |
| **VENV_SECRETS_USER_DIR** | Directory for user-specific secrets scripts for the current environment (e.g., `~\VEnvIt\Secrets`). Contents are private and should not be shared or pushed to repositories. Scripts here override those in the default directory. |
| **VENVIT_DIR** | Installation directory where VEnvIt scripts reside (e.g., `C:\VEnvIt`). In an organizational setup, this should be a shared drive. |

# Server Installation

To install VEnvIt on a server, follow these steps:

1. **Set Environment Variables**: Decide on the values for the system environment variables listed above and set them accordingly.

2. **Remove Existing Python Installations**: Remove any native Python installations and ensure that any references to Python installations are removed from the `PATH` environment variable. This step is vital for successful operation.

3. **Install Python Versions**: Install the various versions of Python you intend to use (e.g., `C:\Python\Python39`, `C:\Python\Python312`). During installation, use the following settings:

   - **Do Not** select "Use admin privileges when installing py.exe."
   - **Do Not** add `python.exe` to the `PATH`.
   - Choose "Customize installation."
   - **Unselect** "py launcher."
   - **Unselect** "Install for all users."
   - **Unselect** "Create shortcuts for installed applications."
   - **Unselect** "Add Python to environment variables."
   - **Select** "Precompile standard library."
   - **Select** "Download debugging tools."
   - **Select** "Download debug binaries (requires VS 2017 or later)."
   - Change the "Customize install location" to your desired directory (e.g., `C:\Python\Python310`).

4. **Ensure Shared Directory Exists**: The shared directory `VENVIT_DIR` must exist and be accessible.

5. **Run Installation Script**: Open a new PowerShell window **with Administrator rights**. Do not use an existing one. Paste the following script into the PowerShell window:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   $UpgradeScriptDir = New-Item -ItemType Directory -Path (Join-Path -Path $env:TEMP -ChildPath ("venvit_" + [Guid]::NewGuid().ToString()))
   $Tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
   $UpgradeScriptPath = Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "Installation-Files.zip"
   Invoke-WebRequest "https://github.com/BrightEdgeeServices/venvit/releases/download/$Tag/Installation-Files.zip" -OutFile $UpgradeScriptPath
   Expand-Archive -Path $UpgradeScriptPath -DestinationPath $UpgradeScriptDir
   Import-Module -Name (Join-Path -Path $UpgradeScriptDir.FullName -ChildPath "src/Install-Conclude.psm1")
   Invoke-ConcludeInstall -Release $Tag -UpgradeScriptDir $UpgradeScriptDir
   ```

6. **Configure Secrets Scripts**: Configure the `Secrets.ps1` script in both `VENV_SECRETS_DEFAULT_DIR` and `VENV_SECRETS_USER_DIR`:

   - Set the ports for the various Docker containers.
   - Set environment variables for secrets (e.g., `$env:MY_SECRET = 'AaBbCcDdE'`), ensuring they match configurations in GitHub or other services.

7. **Confirm Installation**:

   - Open a new PowerShell window.

   - Verify that the environment variables are set correctly using `Get-ChildItem Env:`.

   - Create a test project:

     ```powershell
     .\vn.ps1 -ProjectName TestProject -PythonVer 310 -Organization MyOrg -ResetScripts y -DevMode y
     ```

     - Ensure the virtual environment is activated.
     - Verify the current directory is correct (e.g., `..\MyOrg\TestProject`).
     - Confirm environment variables exist and have correct values.

   - Initialize the test project:

     ```powershell
     .\vi.ps1 -ProjectName TestProject
     ```

     - Ensure the virtual environment is activated.
     - Verify the current directory is correct.

   - Remove the test project:

     ```powershell
     .\vr.ps1 -ProjectName TestProject
     ```

     - Ensure the virtual environment is deactivated.

# Contributor Guide

Thank you for your interest in contributing to **VEnvIt**. This project is open-source under the [MIT License](https://github.com/BrightEdgeeServices/venvit/blob/master/LICENSE) and welcomes contributions in the form of bug reports, feature requests, and pull requests.

## Important Resources

- **Source Code**: [GitHub Repository](https://github.com/BrightEdgeeServices/venvit)
- **Issue Tracker**: [GitHub Issues](https://github.com/BrightEdgeeServices/venvit/issues)

## Reporting Bugs

Please report bugs on the [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues). When filing an issue, please include:

- A detailed description of the problem.
  - What command did you execute?
  - What did you expect to see?
  - What did you see instead?
- Steps to reproduce the issue or a test case.
- Information about your operating system and Python version.
- The version of VEnvIt you are using.

## Requesting Features

Feature requests are also handled through the [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues). Please include:

- A detailed description of the proposed feature or improvement.
- The benefits it would bring to the project.
- Any proposed solutions or implementation ideas.

## Submitting Changes

- Open a pull request to submit changes.
- Ensure your code follows the project's coding standards and conventions.
- If your changes add functionality, update the documentation accordingly.
- It's recommended to open an issue before starting work to discuss your ideas and approach with the maintainers.

# License

This project is licensed under the terms of the [MIT License](https://github.com/BrightEdgeeServices/venvit/blob/master/LICENSE).

# Support

For support or any questions, please open an issue on the [Issue Tracker](https://github.com/BrightEdgeeServices/venvit/issues).

# Example Usage of `vn.ps1`, `vi.ps1`, and `vr.ps1`

_To be completed in future updates._
