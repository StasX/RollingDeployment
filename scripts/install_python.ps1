$ErrorActionPreference = "Stop"


python -m pip --version *> $null

if ($LASTEXITCODE -ne 0) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Python/pip not found. Installing Python..."

        winget install `
            --id Python.Python.3.14 `
            --exact `
            --accept-package-agreements `
            --accept-source-agreements
    }
    else {
        Write-Error "winget is not available. Please install Python 3 manually."
        exit 1
    }
}
