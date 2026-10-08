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

if ($env:PROJECT_NAME) {
    $env:TF_VAR_PROJECT_NAME = $env:PROJECT_NAME
}

if ($env:MOST_RECENT) {
    $env:TF_VAR_MOST_RECENT = $env:MOST_RECENT
}

if ($env:AMI_ID) {
    $env:TF_VAR_AMI_ID = $env:AMI_ID
}

if ($env:USE_DOMAIN) {
    $env:TF_VAR_USE_DOMAIN = $env:USE_DOMAIN
}

if ($env:DOMAIN_NAME) {
    $env:TF_VAR_DOMAIN_NAME = $env:DOMAIN_NAME
}

if ($env:ADMIN_ALLOWED_CIDR) {
    $env:TF_VAR_ADMIN_ALLOWED_CIDR = $env:ADMIN_ALLOWED_CIDR
}

& python -m venv $venv
& "$venv\Scripts\python.exe" -m pip install `
    -r "$PSScriptRoot\requirements.txt"
& "$venv\Scripts\python.exe" "$PSScriptRoot\main.py"
