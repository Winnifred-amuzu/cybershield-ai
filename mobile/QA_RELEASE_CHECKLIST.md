# Cyber-Shield AI — Sprint 9 QA & Release Checklist

## Scope
Sprint 9 focuses on end-to-end validation, mobile diagnostics, API robustness, and release readiness. No ML model is retrained in this sprint.

## Backend acceptance
- [ ] `python -m pytest tests backend/tests`
- [ ] `python scripts/smoke_test_api.py` with the API running
- [ ] `GET /health` reports `healthy`
- [ ] `GET /api/model/status` reports calibrated artefacts when available
- [ ] Auth registration/login works
- [ ] Authenticated mobile detection creates user-specific history
- [ ] Invalid source returns HTTP 422
- [ ] Oversized request returns HTTP 413
- [ ] Rate limiting returns HTTP 429 after the configured threshold
- [ ] Production startup rejects the default JWT secret
- [ ] Production startup rejects SQLite database configuration

## ML acceptance
- [ ] `calibrated_svm.pkl` exists
- [ ] `calibrated_vectorizer.pkl` exists
- [ ] `calibration_metadata.json` exists
- [ ] Model and vectorizer are loaded as a matched pair
- [ ] Confidence is labelled calibrated only when both calibrated artefacts exist
- [ ] Tuned threshold is read from metadata
- [ ] Original model artefacts remain available as fallback

## Mobile acceptance
- [ ] `flutter doctor` shows Android toolchain ready
- [ ] `flutter pub get` succeeds
- [ ] `flutter analyze` has no errors
- [ ] `flutter test` passes
- [ ] Login/register works against local API
- [ ] Detection works against the Android emulator
- [ ] Detection works against a physical Android device using `CYBERSHIELD_API_URL`
- [ ] Screenshot OCR imports text for review
- [ ] Android share intent imports text for review
- [ ] Shared screenshot OCR imports text for review
- [ ] URL analyzer works
- [ ] Dashboard and history are user-specific
- [ ] System Status screen reports API/model state
- [ ] Session expiry is shown as a clear re-login message

## Release builds
```powershell
flutter build apk --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
flutter build appbundle --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
```

## Important limitation
Flutter/Android builds must be validated on a machine with the Flutter SDK and Android SDK installed. Do not mark the Android release as tested merely because the Dart source exists.
