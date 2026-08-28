# Cyber-Shield AI — Sprint 10 End-to-End QA

## Objective
Validate the real Android client against the current FastAPI backend and calibrated ML model before release.

## Preconditions
- Backend starts successfully with `python backend/run.py`.
- `/health` reports `healthy`.
- `/api/model/status` reports `confidence_is_calibrated: true`.
- Android phone and development PC are on the same network for physical-device testing.
- Windows Firewall permits the backend port when testing from a physical device.

## Test Matrix

| ID | Test | Expected result |
|---|---|---|
| E2E-01 | Launch app | App starts without crash |
| E2E-02 | Onboarding | Completes and persists |
| E2E-03 | Register | Account created and token stored securely |
| E2E-04 | Login | User enters authenticated home screen |
| E2E-05 | Detect safe text | SAFE result returned |
| E2E-06 | Detect phishing text | SCAM / PHISHING result returned |
| E2E-07 | Result details | Risk, probability and indicators displayed |
| E2E-08 | History | Current user's scan appears |
| E2E-09 | Dashboard | User statistics load |
| E2E-10 | Model status | Calibrated model displayed |
| E2E-11 | URL analyzer | URL indicators displayed |
| E2E-12 | Screenshot OCR | Text extracted before analysis |
| E2E-13 | Share text | Shared text imported for review |
| E2E-14 | Share screenshot | OCR extracts shared image text |
| E2E-15 | Expired/invalid token | User receives session-expired message |
| E2E-16 | Rate limit | User receives a controlled 429 message |
| E2E-17 | API unavailable | Mobile app shows a readable network error |
| E2E-18 | Logout | Token removed and login screen restored |
| E2E-19 | APK | Release APK installs on test device |
| E2E-20 | AAB | Release AAB generated successfully |

## Release Gate

All critical tests E2E-01 through E2E-10 must pass before internal release. E2E-11 through E2E-20 must be executed before public distribution.

## Evidence to Capture

For the final project documentation, capture screenshots of:
1. Login screen
2. Detection screen
3. SAFE result
4. SCAM / PHISHING result
5. Screenshot OCR workflow
6. Share-to-Cyber-Shield workflow
7. Dashboard
8. History
9. Model Performance / System Status
10. Android application information / installed release build
