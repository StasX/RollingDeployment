Get-Content .env | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), 'Process')
}

python -m venv env
env\Scripts\activate
pip install -r requirements.txt

