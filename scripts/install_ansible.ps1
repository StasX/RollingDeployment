$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "install_ansible.sh"

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "WSL is unavailable. Install WSL2 with Ubuntu first."
}

$wslPath = (wsl.exe -- wslpath -a "$scriptPath")

if ($LASTEXITCODE -ne 0) {
    throw "Failed to convert script path."
}

$wslPath = $wslPath.Trim()

wsl.exe -- bash "$wslPath"

if ($LASTEXITCODE -ne 0) {
    throw "Ansible installation failed."
}
