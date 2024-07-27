# This script sets up your local development environment variables. Change
# the values to suit your personal preferences or as required other wise.
Write-Host "Initialize local development environment variables"

# Get the value of PROJECT_NAME (case-insensitive)
$project_name = $env:PROJECT_NAME

# Convert PROJECT_NAME to lowercase
$project_name = $project_name.ToLower()

# Check the value of PROJECT_NAME and set MYSQL_TCP_PORT accordingly.  Use this to assign
# different ports to your MySQL servers running in different Docker's'
# Set the default value for MYSQL_TCP_PORT
$env:MYSQL_TCP_PORT = 50000
if ($project_name -eq "project1") {
    $env:MYSQL_TCP_PORT = 50001
} elseif (
    $project_name -eq "project2" -or
    $project_name -eq "project3"
    ) {
        $env:MYSQL_TCP_PORT = 50002
}

# Set the default userid's and passwords
$env:INSTALLER_PWD="N0Pa55wrd"
$env:INSTALLER_USERID="myinstallerid"
$env:LINUX_ROOT_PWD="N0Pa55wrd"
$env:MYSQL_HOST="localhost"
$env:MYSQL_PWD="N0Pa55wrd"
$env:MYSQL_ROOT_PASSWORD='N0Pa55wrd'
$env:MYSQL_DATABASE='mydb'
#----------------------------------------------
# IMPORTANT NOTICE
#----------------------------------------------
# Correct next environment variable to reflect the correct name and value.
# This secret is the token setup in GitHub that enables you to push to the repositories.
$env:MY_SCRT='AaBbCcDdE'
