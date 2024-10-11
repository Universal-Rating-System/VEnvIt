function New-CustomTempDir {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Prefix
    )
    $TempDir = Join-Path -Path $env:TEMP -ChildPath ($Prefix + "_" + [Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $TempDir | Out-Null
    return $TempDir
}

Export-ModuleMember -Function 'New-CustomTempDir'
