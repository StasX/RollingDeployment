$ErrorActionPreference = "Stop"

$scripts = "$PSScriptRoot\scripts"
$venv = "$PSScriptRoot\env"

Get-Content "$PSScriptRoot\.env" | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), 'Process')
}

& "$scripts\generate_ssh_key.ps1"
& "$scripts\install_python.ps1"
& "$scripts\install_terraform.ps1"

& python -m venv $venv
& "$venv\Scripts\python.exe" -m pip install `
    -r "$PSScriptRoot\requirements.txt"
& "$venv\Scripts\python.exe" "$PSScriptRoot\main.py"
