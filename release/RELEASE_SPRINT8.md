# Cyber-Shield AI — Sprint 8 Release & End-to-End Test Plan

## Objective
Move the existing Cyber-Shield AI project from development into repeatable release validation without replacing the existing Streamlit web application or ML artefacts.

## Release targets
- Existing Streamlit web application remains available.
- FastAPI backend version 3.1.0.
- Calibrated SVM is generated and available when `calibrated_svm.pkl` exists.
- PostgreSQL is the production database target.
- Android debug and release builds are generated from the same Flutter source.

## Local validation
1. Run `pytest -q` from the project root.
2. Run `python scripts/smoke_test_api.py`.
3. Run `powershell -ExecutionPolicy Bypass -File scripts/bootstrap_mobile.ps1`.
4. Start the backend with `cd backend; python run.py`.
5. Launch the Android emulator or physical Android device.
6. Confirm login, detection, dashboard, history and model-performance flows.
7. Share a text message from another Android app and verify it opens the Detection screen for review.
8. Share a screenshot and verify OCR text is shown for review before analysis.
9. Verify a scan appears only in the authenticated user's history.
10. Verify logout removes the local access token.

## Release build
Use:
`powershell -ExecutionPolicy Bypass -File scripts/build_android_release.ps1 -ApiUrl https://api.example.com`

Outputs:
- `mobile/build/app/outputs/flutter-apk/app-release.apk`
- `mobile/build/app/outputs/bundle/release/app-release.aab`

## Production acceptance criteria
- HTTPS is enabled.
- A strong JWT secret is configured.
- PostgreSQL is reachable and backed up.
- CORS contains only trusted origins.
- API rate limits are configured for the expected traffic.
- Model status reports calibrated confidence before operational use.
- API documentation is disabled in production unless deliberately enabled behind access control.
- No production secrets are committed to Git.
- Android signing credentials are stored outside source control.
- Privacy/retention policy is documented before storing real user messages.

## Known limitations
- Flutter SDK must be installed on the developer/release machine; this environment cannot produce a signed Android binary without Flutter tooling and signing credentials.
- The in-memory API rate limiter is suitable for a single-process deployment only. Use a shared gateway/Redis limiter for multi-instance production.
- The Streamlit application remains a legacy web client and is not automatically migrated to the authenticated mobile data model.
