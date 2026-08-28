# Cyber-Shield AI — Sprint 4: Authentication, Secure Sessions & Share-to-App

Sprint 4 keeps the existing Streamlit website and ML artefacts intact while adding an authenticated mobile API surface.

## Backend

From `backend/`:

```cmd
python -m pip install -r requirements.txt
set CYBERSHIELD_JWT_SECRET=replace-with-a-long-random-secret
python run.py
```

For PowerShell:

```powershell
$env:CYBERSHIELD_JWT_SECRET="replace-with-a-long-random-secret"
python run.py
```

New endpoints:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/mobile/detect` — authenticated
- `GET /api/mobile/history` — authenticated
- `GET /api/mobile/dashboard` — authenticated

The legacy `/api/detect`, `/api/history`, `/api/dashboard` and model/URL endpoints remain for compatibility with the existing Streamlit system. The mobile application uses the authenticated `/api/mobile/*` endpoints, so users receive separate scan histories.

Passwords are hashed using PBKDF2-HMAC-SHA256 with a random salt. Access tokens are JWTs and are stored in Flutter Secure Storage on the device.

## Mobile

From `mobile/`:

```cmd
flutter create .
flutter pub get
flutter run
```

The app now starts with authentication after onboarding. New users can register and returning users can sign in. The token is stored securely and attached to authenticated mobile API requests.

## Android Share-to-Cyber-Shield

The mobile client uses `receive_sharing_intent` 1.8.1. After `flutter create .`, edit `android/app/src/main/AndroidManifest.xml` and add these intent filters inside the main activity:

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/*" />
</intent-filter>

<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="image/*" />
</intent-filter>
```

Set the main activity launch mode to `singleTask` so a running app can receive new share intents.

The plugin API uses `ReceiveSharingIntent.instance.getMediaStream()` for warm-start shares and `getInitialMedia()` for cold-start shares. Shared text is placed directly into the Detection screen for review before analysis. Shared screenshots/images continue through the screenshot/OCR workflow.

## Security notes

- Never ship the development JWT secret.
- Use HTTPS in deployed environments.
- Do not use `allow_origins=["*"]` in a production browser deployment.
- Add token expiry/refresh and account recovery before production release.
- Raw user messages can contain personal/financial information; production history storage should be encrypted/redacted and subject to retention rules.
- The existing LinearSVC confidence is still not calibrated; Sprint 5 addresses this separately.
