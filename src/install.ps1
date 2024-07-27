$tempDir = New-Item -ItemType Directory -Path (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName()))
$tag = (Invoke-WebRequest "https://api.github.com/repos/BrightEdgeeServices/venvit/releases" | ConvertFrom-Json)[0].tag_name
$installScriptPath = Join-Path -Path $tempDir.FullName -ChildPath "conclude_install.ps1"
Invoke-WebRequest -Uri "https://github.com/BrightEdgeeServices/venvit/releases/download/$tag/conclude_install.ps1" -OutFile $installScriptPath
& $installScriptPath -release $tag -installScriptDir $tempDir
# The next line is used for testing purposes.  It will executhe installation.ps1 in
# the development directory and not the downloaded copy.  Once Pester is installed,
# it should be redundant.
# & "D:\Dropbox\Projects\BEE\venvit\src\install.ps1" -release $tag -installScriptDir "D:\Dropbox\Projects\BEE\venvit\"
Remove-Item -Path $tempDir.FullName -Recurse -Force
Unblock-File "$env:VENVIT_DIR\vn.ps1"
Unblock-File "$env:VENVIT_DIR\vi.ps1"
Unblock-File "$env:VENVIT_DIR\vr.ps1"
Unblock-File "$env:VENV_SECRETS_DIR\dev_env_var.ps1"
