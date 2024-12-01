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

## List of Configuration Scripts

1. **`Activate.ps1`**: Activates the virtual environment.
2. **`Deactivate.ps1`**: Deactivates the virtual environment.
3. **`Install-Dependencies.ps1`**: Installs project-specific dependencies.
4. **`Update-Dependencies.ps1`**: Updates the installed dependencies to their latest versions.
5. **`Set-Environment.ps1`**: Sets up environment variables required for the project.
6. **`Unset-Environment.ps1`**: Removes the environment variables.
7. **`Build.ps1`**: Builds the project from source.
8. **`Clean.ps1`**: Cleans up build artifacts and temporary files.

These scripts offer a modular approach to managing your project's environment, allowing for extensive customization to meet the needs of complex systems.

# Sample Environment Configuration (`secrets.ps1`)

The `secrets.ps1` script serves as a template for setting up environment-specific configurations, such as API keys, database connections, and other sensitive information. Customize this script to match your environment's requirements.

**Note**: Ensure that sensitive information is handled securely and is not committed to version control systems.

# Conclusion

VenvIt is a powerful utility designed for advanced users who require extensive customization of their virtual environments. By leveraging Python and PowerShell scripting, it provides unparalleled flexibility in managing complex development and production systems. While this approach demands a higher level of expertise, it ultimately offers a more adaptable and robust solution for environment management.

# Additional Information

## Best Practices

- **Version Control**: Exclude sensitive scripts like `secrets.ps1` from version control to prevent unintentional exposure of confidential information.
- **Script Customization**: Regularly update and customize the generated scripts to align with your project's evolving needs.
- **Environment Isolation**: Use virtual environments to isolate project dependencies, preventing conflicts between different projects.

## Support and Contributions

For issues, feature requests, or contributions, please refer to the repository's [issue tracker](#) and [contribution guidelines](#).

# References

- **Python Virtual Environments**: [Official Documentation](https://docs.python.org/3/tutorial/venv.html)
- **PowerShell Scripting**: [Getting Started with PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/01-getting-started)

______________________________________________________________________

By following this guide, technical readers should be able to effectively utilize VenvIt to manage their virtual environments with greater flexibility and control.
