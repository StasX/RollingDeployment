$ErrorActionPreference = "Stop"

Get-Content .env | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), 'Process')
}

& "$PSScriptRoot/scripts/generate_ssh_key.ps1"

& "$PSScriptRoot/scripts/install_python.ps1"

& "$PSScriptRoot/scripts/install_terraform.ps1"

python -m venv env
env\Scripts\activate
pip install -r requirements.txt

py botstrap.py
