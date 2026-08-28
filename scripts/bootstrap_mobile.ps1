$ErrorActionPreference = "Stop"

Write-Host "Cyber-Shield AI mobile bootstrap" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter SDK was not found on PATH. Install Flutter and run 'flutter doctor'."
}

Set-Location (Join-Path $PSScriptRoot "..\mobile")

if (-not (Test-Path "android")) {
    Write-Host "Generating Android platform files..." -ForegroundColor Yellow
    flutter create . --platforms=android
}

flutter pub get
flutter analyze
flutter test

Write-Host "Mobile project is ready. Run 'flutter run' to launch it." -ForegroundColor Green
