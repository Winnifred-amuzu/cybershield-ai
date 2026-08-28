param(
    [string]$ApiUrl = "",
    [switch]$SkipAnalyze
)

$ErrorActionPreference = "Stop"

Write-Host "=== Cyber-Shield AI Mobile Release Check ===" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter SDK was not found on PATH. Install Flutter and run 'flutter doctor' first."
}

flutter doctor

Push-Location (Join-Path $PSScriptRoot "..\mobile")
try {
    if (-not (Test-Path "android\app\src\main\AndroidManifest.xml")) {
        Write-Host "Generating Android platform files..." -ForegroundColor Yellow
        flutter create . --platforms=android
    }

    flutter pub get

    if (-not $SkipAnalyze) {
        flutter analyze
    }

    flutter test

    $defines = @()
    if ($ApiUrl) {
        $defines = @("--dart-define=CYBERSHIELD_API_URL=$ApiUrl")
    }

    Write-Host "Building release APK..." -ForegroundColor Cyan
    flutter build apk --release @defines

    Write-Host "Building release App Bundle..." -ForegroundColor Cyan
    flutter build appbundle --release @defines

    Write-Host "=== Release validation complete ===" -ForegroundColor Green
    Write-Host "APK: mobile\build\app\outputs\flutter-apk\app-release.apk"
    Write-Host "AAB: mobile\build\app\outputs\bundle\release\app-release.aab"
}
finally {
    Pop-Location
}
