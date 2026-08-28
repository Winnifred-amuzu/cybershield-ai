# Cyber-Shield AI Mobile — Sprint 3

Flutter mobile client for the existing Cyber-Shield AI scam-detection system.

## Sprint 3 features

- Professional dark cybersecurity UI.
- First-launch onboarding.
- Detection for Email, SMS and WhatsApp.
- Backend-powered SAFE / SCAM-PHISHING detection.
- Result screen with risk, indicators and the existing uncalibrated-confidence warning.
- Dashboard, History and Model Performance.
- Screenshot-to-text OCR using Google ML Kit.
- Basic URL structural analyzer.
- Safe explicit external-browser URL opening.
- Centralised API configuration.

## Important: generate Flutter platform folders

The source package intentionally keeps the Flutter project platform-neutral. If the `android/` and/or `ios/` folders do not exist on your machine, run this once from `mobile/`:

```cmd
flutter create .
```

This generates the native platform scaffolding while preserving the Dart files in `lib/` and the existing `pubspec.yaml`.

Then install packages:

```cmd
flutter pub get
```

## Start the backend

From the project root:

```cmd
cd backend
python run.py
```

Backend: `http://127.0.0.1:8000`

## Android emulator

The app is configured to use `http://10.0.2.2:8000`, which maps the Android emulator to the development computer.

```cmd
cd mobile
flutter run
```

## Physical Android phone

Edit `lib/services/api_config.dart` and replace `physicalDeviceBaseUrl` with the development PC's LAN IPv4 address. Run the backend with:

```cmd
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Allow Python through Windows Firewall if prompted.

## Screenshot OCR

The Screenshot Analyzer uses Google ML Kit's on-device Latin text recognition. The user selects an image, OCR extracts text, and the extracted text is placed in the normal Detection message box for review before analysis.

## URL analyzer

The URL analyzer performs structural checks such as URL validity, HTTPS use, long URLs, common shorteners, embedded user information and non-default ports. It does not claim that a domain is malicious or safe and does not replace threat-intelligence or sandbox analysis.

## Sprint 4

The mobile client now supports authenticated registration/login, secure token storage and authenticated user-specific detection/history/dashboard endpoints. It also listens for shared text through `receive_sharing_intent` so a message shared from another application can be imported into the Detection screen for review.
