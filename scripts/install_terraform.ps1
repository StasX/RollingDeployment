$ErrorActionPreference = "Stop"

$TerraformVersion = "1.16.5"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {

    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
        "X64" {
            $Arch = "amd64"
        }
        "Arm64" {
            $Arch = "arm64"
        }
        default {
            throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
        }
    }

    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
    New-Item -ItemType Directory -Path $TempDir | Out-Null

    try {
        $ZipFile = Join-Path $TempDir "terraform.zip"

        $Url = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_${Arch}.zip"

        Write-Host "Downloading Terraform $TerraformVersion..."

        Invoke-WebRequest `
            -Uri $Url `
            -OutFile $ZipFile

        Expand-Archive `
            -Path $ZipFile `
            -DestinationPath $TempDir

        $InstallDir = "$env:LOCALAPPDATA\Programs\Terraform"

        New-Item `
            -ItemType Directory `
            -Path $InstallDir `
            -Force | Out-Null

        Copy-Item `
            -Path "$TempDir\terraform.exe" `
            -Destination "$InstallDir\terraform.exe" `
            -Force

        if ($env:PATH -notlike "*$InstallDir*") {
            $env:PATH = "$InstallDir;$env:PATH"
        }

        $UserPath = [Environment]::GetEnvironmentVariable(
            "Path",
            "User"
        )

        if ($UserPath -notlike "*$InstallDir*") {
            [Environment]::SetEnvironmentVariable(
                "Path",
                "$UserPath;$InstallDir",
                "User"
            )
        }

        Write-Host "Terraform $TerraformVersion installed successfully."
    }
    finally {
        if (Test-Path $TempDir) {
            Remove-Item -Path $TempDir -Recurse -Force
        }
    }
}
