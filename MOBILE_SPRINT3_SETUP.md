# Cyber-Shield AI — Mobile Sprint 3 Setup

## 1. Existing web app

Keep the current Streamlit website unchanged:

```cmd
python -m streamlit run detection_app.py
```

## 2. Backend

```cmd
cd backend
python run.py
```

Backend API:

- http://127.0.0.1:8000
- Swagger: http://127.0.0.1:8000/docs

## 3. Mobile

```cmd
cd mobile
flutter create .
flutter pub get
flutter run
```

`flutter create .` is only needed if the downloaded source does not already contain platform folders.

## 4. Android emulator

The default API base URL is:

`http://10.0.2.2:8000`

## 5. Physical phone

Set `physicalDeviceBaseUrl` in `mobile/lib/services/api_config.dart` to the computer's LAN IPv4 address, then run the backend with `--host 0.0.0.0`.

## 6. Sprint 3 test flow

1. Start backend.
2. Start Flutter app.
3. Complete onboarding.
4. Enter a message and analyse it.
5. Confirm the result screen.
6. Open Dashboard, History and Models.
7. Tap the link icon and analyse a URL.
8. Return to Detection and use Scan Screenshot.
9. Select a screenshot containing text.
10. Review OCR output before analysis.
