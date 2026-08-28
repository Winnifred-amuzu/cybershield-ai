# Cyber-Shield AI — Sprint 9 Release Notes

## Goal
Validate the integrated web/API/mobile architecture and remove deployment-facing inconsistencies without replacing the current system.

## Key fixes
1. The calibrated SVM now loads `calibrated_svm.pkl` together with `calibrated_vectorizer.pkl` as an atomic pair.
2. Health reporting now verifies that the active model and vectorizer artefacts actually exist.
3. The mobile API client has request timeouts and clearer handling for HTTP 401 and 429 responses.
4. The mobile API base URL is controlled by `CYBERSHIELD_API_URL`; the development default remains the Android emulator address.
5. A System Status screen was added for API/database/model diagnostics.
6. A QA and release checklist was added for repeatable end-to-end validation.

## Current architecture
Flutter Mobile → FastAPI → preprocessing → calibrated TF-IDF/SVM → explanation/risk → user history database.
The existing Streamlit application remains part of the system and is not removed.

## Release rule
The Android application must not be described as production-ready until `flutter analyze`, `flutter test`, a debug device test, and release APK/AAB builds have been completed on a machine with Flutter and Android SDKs installed.
