# Download the install file to the current directory
$tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
$url = "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/install.ps1"
Invoke-WebRequest -Uri $url -OutFile "installation_files.zip"