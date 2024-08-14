# Release 6.0.1

## General Changes


## Ticket Included

1. BEE-00096 | venvit | Update README with missing information
______________________________________________________________________

# Release 6.0.0

## General Changes

- Fork the project from [Batch](https://github.com/BrightEdgeeServices/Batch)
- General restructure of the project, creating the `src` and `tst` folders with the relevant code.
- Improved and updated README.md

## GitHub

- Reformat the ISSUE_TEMPLATE's.
- Add `New Release` issue template.
- Combine `Pre-Commit` and `Check-Documentation` workflows into 'Pre-Commit-and-Document-Check'
- Add a numbered prefix to the workflow file names.
- Removed `CI` workflow, since no formal testing is done.  When Pester is employed, it will be commissioned again.
- Removed unnecessary environment variables from `04-build-and-deploy-to-production.yml`.
- Removed unnecessary steps from `04-build-and-deploy-to-production.yml` not relates to PowerShell scripts.
- Add steps to `04-build-and-deploy-to-production.yml` for PowerShell scripts.

## Source

- Rename `env_var_dev.ps1` to `dev_env_var.ps1`.
- Introduce the `download.ps1` script for facilitating the source from the GitHub repository.
- Introduce the `install.ps1` script to install the scripts and automate the setup and configuration.
- Rename the RTE_ENVIRONMENT environment variable to VENV_ENVIRONMENT.
- Rename the SCRIPTS_DIR environment variable to VENVIT_DIR.
- Rename the SECRETS_DIR environment variable to VENV_SECRETS_DIR.
- Add the VENV_CONFIG_DIR environment variable for greater flexibility to implement shared installations in an organization.
- Improved the display of messages to the console.
- Moved the bulk of the help functions to `README.md`.
- Improved the `usage` clauses in the help.
- Started a basic testing script.

______________________________________________________________________

# Release 5.3.32 - 66

## General Changes

- Testing the installation scripts.

______________________________________________________________________

# Release 5.3.2 - 31

## General Changes

- Testing the GitHub Actions workflow scripts.

______________________________________________________________________

# Release 5.3.1

## General Changes

- Forked from the original "Batch" project.
