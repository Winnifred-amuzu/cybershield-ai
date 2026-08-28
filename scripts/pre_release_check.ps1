$ErrorActionPreference = 'Stop'

Write-Host '=== Cyber-Shield AI Sprint 10 Pre-Release Check ===' -ForegroundColor Cyan

Write-Host "`n[1/5] Python compilation" -ForegroundColor Yellow
python -m compileall -q backend ml scripts

Write-Host "[2/5] Python tests" -ForegroundColor Yellow
python -m pytest -q

Write-Host "[3/5] Flutter availability" -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter was not found on PATH. Install/configure Flutter before Android validation.'
}
flutter --version

Write-Host "[4/5] Flutter static analysis and tests" -ForegroundColor Yellow
Push-Location mobile
try {
    flutter pub get
    flutter analyze
    flutter test
} finally {
    Pop-Location
}

Write-Host "[5/5] API smoke test" -ForegroundColor Yellow
Write-Host 'Start the backend separately before running scripts/smoke_test_api.py.' -ForegroundColor DarkYellow
python scripts/smoke_test_api.py

Write-Host "`n=== PRE-RELEASE CHECK PASSED ===" -ForegroundColor Green
