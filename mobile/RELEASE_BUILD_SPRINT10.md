# Cyber-Shield AI — Sprint 10 Android Release Build

## Purpose

This document is the release procedure for validating the Flutter mobile client against the current Cyber-Shield AI FastAPI backend.

The Android application must not be described as production-ready until the commands below have been completed successfully on a machine with Flutter and Android SDKs installed.

## 1. Validate the development environment

From `mobile/`:

```powershell
flutter doctor
flutter pub get
flutter analyze
flutter test
```

Resolve all errors before proceeding.

## 2. Generate Android platform files if needed

If `android/` does not exist:

```powershell
flutter create . --platforms=android
```

Then repeat:

```powershell
flutter pub get
flutter analyze
flutter test
```

## 3. Run against the Android emulator

Start the backend from the project root:

```powershell
cd backend
python run.py
```

In another terminal:

```powershell
cd mobile
flutter run --dart-define=CYBERSHIELD_API_URL=http://10.0.2.2:8000
```

`10.0.2.2` is the Android Emulator address for the host computer. Do not use it for a physical phone.

## 4. Run against a physical Android phone

Find the Windows host IPv4 address:

```powershell
ipconfig
```

Use the computer's LAN IPv4 address, for example:

```powershell
flutter run --dart-define=CYBERSHIELD_API_URL=http://192.168.1.25:8000
```

Requirements:

- Phone and development computer are on the same network.
- Windows Firewall allows inbound TCP traffic to port 8000 for the selected private network.
- The FastAPI server is reachable from the phone.
- Do not expose the development server to an untrusted public network.

For production, use HTTPS rather than a raw HTTP LAN address.

## 5. Physical-device acceptance test

Perform these in order:

1. Launch the app.
2. Complete onboarding.
3. Register a new account.
4. Sign out.
5. Sign back in.
6. Submit a normal message.
7. Confirm the result screen appears.
8. Submit a known phishing/scam-style test message.
9. Confirm scam probability, risk and explanation appear.
10. Open History and confirm the scan is present.
11. Open Dashboard and confirm the scan counters update.
12. Open Model Performance.
13. Open System Status and confirm API, database and calibrated model are healthy.
14. Use URL Analyzer with a test URL.
15. Pick a screenshot containing text and run OCR.
16. Review the OCR text before analysis.
17. Use Android Share to send text to Cyber-Shield AI and confirm it is imported for review.
18. Sign out and confirm protected screens are no longer accessible.

## 6. Release APK

```powershell
flutter build apk --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
```

Output:

`build/app/outputs/flutter-apk/app-release.apk`

## 7. Release Android App Bundle

```powershell
flutter build appbundle --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
```

Output:

`build/app/outputs/bundle/release/app-release.aab`

## 8. Release gate

Do not distribute the release build until:

- `flutter analyze` passes.
- `flutter test` passes.
- Backend tests pass.
- API smoke test passes.
- Physical-device detection works.
- Authentication works.
- History is user-specific.
- Screenshot OCR works.
- Share import works.
- HTTPS production endpoint is verified.
- Production secrets are not committed.
