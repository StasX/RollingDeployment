$ErrorActionPreference = "Stop"

$KeyDir = "./keys"
$KeyName = "$env:PROJECT_NAME-key"

# Create keys directory if it doesn't exist
New-Item -ItemType Directory -Path $KeyDir -Force | Out-Null

$KeyPath = Join-Path $KeyDir $KeyName
$PemPath = "$KeyPath.pem"
$PubPath = "$KeyPath.pub"

# Generate SSH key if it doesn't exist
if (-not (Test-Path $KeyPath) -and -not (Test-Path $PemPath)) {
    ssh-keygen `
        -t rsa `
        -b 4096 `
        -f $KeyPath `
        -N '""'
}

# Rename private key to .pem
if (-not (Test-Path $PemPath)) {
    Move-Item -Path $KeyPath -Destination $PemPath
}

Write-Host "SSH key pair generated at $PemPath and $PubPath"
