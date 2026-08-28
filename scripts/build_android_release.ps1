param(
    [string]$ApiUrl = "https://api.example.com"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter SDK was not found on PATH. Install Flutter and run 'flutter doctor'."
}

Set-Location (Join-Path $PSScriptRoot "..\mobile")

if (-not (Test-Path "android")) {
    flutter create . --platforms=android
}

flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=CYBERSHIELD_API_URL=$ApiUrl
flutter build appbundle --release --dart-define=CYBERSHIELD_API_URL=$ApiUrl

Write-Host "APK: mobile\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
Write-Host "AAB: mobile\build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Green
