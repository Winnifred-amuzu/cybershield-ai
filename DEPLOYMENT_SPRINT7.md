# Cyber-Shield AI — Sprint 7 Deployment & Release Guide

Sprint 7 moves the current system toward deployable infrastructure while keeping the existing Streamlit application and model artefacts intact.

## 1. Development mode

Backend:

```powershell
cd backend
python run.py
```

Mobile emulator:

```powershell
cd mobile
flutter pub get
flutter run
```

## 2. Production database

Production mode requires PostgreSQL. SQLite remains supported for development.

Create `.env` from `.env.production.example` and replace every placeholder secret.

Then:

```powershell
docker compose -f docker-compose.production.yml up -d --build
```

The API is bound to `127.0.0.1:8000` so it is not directly exposed to the public internet. Put Nginx, Caddy or a cloud load balancer in front of it for HTTPS.

## 3. Migrating the existing SQLite data

After PostgreSQL is running, set `CYBERSHIELD_DATABASE_URL` to the PostgreSQL connection string and run:

```powershell
python backend/migrate_sqlite_to_postgres.py
```

The source SQLite database is read-only during migration.

## 4. HTTPS

Use `deploy/nginx.conf.example` as a starting point. Obtain a trusted TLS certificate, configure the real API domain and reverse proxy to `127.0.0.1:8000`.

Do not put the PostgreSQL port on the public internet.

## 5. Mobile production endpoint

Build the Android application with the real API URL:

```powershell
flutter build apk --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
```

For Play Store distribution:

```powershell
flutter build appbundle --release --dart-define=CYBERSHIELD_API_URL=https://api.example.com
```

## 6. Physical Android testing

For local testing on a physical device, replace `physicalDeviceBaseUrl` in `api_config.dart` with the development PC's LAN IPv4 address, or pass `CYBERSHIELD_API_URL` using `--dart-define`.

The phone and development PC must be on the same network and Windows Firewall must permit the backend port during development.

## 7. Release checklist

- [ ] Strong production JWT secret configured.
- [ ] Strong PostgreSQL password configured.
- [ ] PostgreSQL is not publicly exposed.
- [ ] HTTPS is active.
- [ ] CORS contains only trusted origins.
- [ ] Production docs are disabled by default.
- [ ] Calibrated model artefacts exist and are tested.
- [ ] Model version is recorded.
- [ ] Android app points to HTTPS API.
- [ ] Share intent tested on a physical device.
- [ ] Screenshot OCR tested on representative screenshots.
- [ ] Authentication tested with valid/invalid credentials.
- [ ] User history isolation tested.
- [ ] Rate limiting tested.
- [ ] Database backup and restore procedure tested.
- [ ] Privacy/data-retention policy defined before real user messages are collected.

## 8. Important current limitation

The request rate limiter is intentionally in-memory. For multiple API workers or multiple API instances, move rate limiting to a shared infrastructure component such as Redis or an API gateway before horizontal scaling.
