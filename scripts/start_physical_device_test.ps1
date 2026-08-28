param(
    [Parameter(Mandatory=$true)]
    [string]$HostIp,
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter SDK was not found on PATH."
}

$apiUrl = "http://$HostIp`:$Port"
Write-Host "Using local API: $apiUrl" -ForegroundColor Cyan
Write-Host "Ensure the phone and development PC are on the same Wi-Fi network." -ForegroundColor Yellow
Write-Host "Ensure Windows Firewall permits TCP port $Port for the backend." -ForegroundColor Yellow

Push-Location (Join-Path $PSScriptRoot "..\mobile")
try {
    flutter pub get
    flutter run --dart-define=CYBERSHIELD_API_URL=$apiUrl
}
finally {
    Pop-Location
}
