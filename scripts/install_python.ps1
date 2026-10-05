$ErrorActionPreference = "Stop"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Python not found. Installing Python..."

        winget install `
            --id Python.Python.3.14 `
            --exact `
            --accept-package-agreements `
            --accept-source-agreements

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install Python."
            exit 1
        }
    }
    else {
        Write-Error "winget is not available. Please install Python 3 manually."
        exit 1
    }
}
