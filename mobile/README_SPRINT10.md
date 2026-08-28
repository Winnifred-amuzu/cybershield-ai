# Sprint 10 — Physical Android Device & Release Candidate

Sprint 10 is focused on validating the mobile application on a real Android device and producing the release artifacts. It does not replace the existing Streamlit website, FastAPI backend, datasets or ML artefacts.

## Architecture

Flutter Mobile → FastAPI → calibrated TF-IDF/SVM → explanation/risk → user history database.

## Development endpoints

Android emulator:

`http://10.0.2.2:8000`

Physical Android phone:

`http://<WINDOWS-LAN-IP>:8000`

Production:

`https://<production-api-domain>`

Use `--dart-define=CYBERSHIELD_API_URL=...` to select the endpoint.

## Release principle

The app is a release candidate only after real-device tests and APK/AAB builds have passed. This repository intentionally does not claim that those Flutter-specific tests were executed in an environment without Flutter/Android SDKs.
