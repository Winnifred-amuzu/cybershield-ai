# Cyber-Shield AI — Sprint 10 Device QA Matrix

| ID | Test | Expected Result | Status |
|---|---|---|---|
| D01 | Launch application | Splash/onboarding loads without crash | PENDING DEVICE TEST |
| D02 | Complete onboarding | Login screen appears | PENDING DEVICE TEST |
| D03 | Register account | Account created and authenticated | PENDING DEVICE TEST |
| D04 | Login | Home screen opens | PENDING DEVICE TEST |
| D05 | Invalid login | Friendly error; no token stored | PENDING DEVICE TEST |
| D06 | Detect normal message | Result returned | PENDING DEVICE TEST |
| D07 | Detect scam message | SCAM/PHISHING result and risk displayed | PENDING DEVICE TEST |
| D08 | Detection timeout/network failure | User receives recoverable error | PENDING DEVICE TEST |
| D09 | History | User's own scans displayed | PENDING DEVICE TEST |
| D10 | Dashboard | Counters load | PENDING DEVICE TEST |
| D11 | Model performance | Metrics load from API | PENDING DEVICE TEST |
| D12 | System status | API/database/model status displayed | PENDING DEVICE TEST |
| D13 | URL analyzer | URL indicators returned | PENDING DEVICE TEST |
| D14 | Screenshot OCR | Text extracted and shown for review | PENDING DEVICE TEST |
| D15 | Share text | Shared message imported for review | PENDING DEVICE TEST |
| D16 | Share screenshot | OCR text imported for review | PENDING DEVICE TEST |
| D17 | Logout | Token removed and login shown | PENDING DEVICE TEST |
| D18 | Expired/invalid token | API returns session error | PENDING DEVICE TEST |
| D19 | Android release APK | APK installs and launches | PENDING DEVICE TEST |
| D20 | Android AAB | Bundle generated successfully | PENDING DEVICE TEST |

## Evidence to capture

For each failed or passed device test, capture the relevant screenshot or terminal output and record:

- device model
- Android version
- Flutter version
- API URL used
- backend version
- model version
- date/time
- result
- defect/observation

## Important release distinction

The project is a release candidate only after the PENDING DEVICE TEST items have been executed successfully. Static Python tests and API smoke tests alone do not prove Android compatibility.
