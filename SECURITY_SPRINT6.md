# Cyber-Shield AI — Sprint 6: Production Security & Mobile Intelligence

This sprint hardens the existing FastAPI/mobile architecture without replacing the existing Streamlit application or ML artefacts.

## Security controls added

- Environment-driven CORS allow-list instead of `*`.
- Request-body size limit (default 64 KB).
- Message length validation (default 5,000 characters).
- URL length validation (default 2,048 characters).
- Lightweight in-memory API rate limiting.
- Stricter authentication rate limiting.
- Security response headers.
- Production guard against the development JWT secret.
- Production recommendation to disable interactive API documentation.
- Restricted HTTP methods and headers through CORS.
- Explicit environment configuration through `.env.example`.

## Important deployment note

The included rate limiter is appropriate for a single-process development or small deployment. For multiple API workers/instances, replace it with a shared store such as Redis so that limits are consistent across workers.

## Start development backend

```cmd
cd backend
python -m pip install -r requirements.txt
python run.py
```

The API is normally available at `http://127.0.0.1:8000`.

## Production environment

Set a strong secret and a strict CORS allow-list before deployment:

```text
CYBERSHIELD_ENV=production
CYBERSHIELD_JWT_SECRET=<strong-random-secret>
CYBERSHIELD_CORS_ORIGINS=https://your-mobile-api-domain.example
```

The application refuses to start in production if the placeholder JWT secret is still being used.

## Mobile API

Authenticated endpoints remain:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/mobile/detect`
- `GET /api/mobile/history`
- `GET /api/mobile/dashboard`
- `GET /api/model/status`
- `GET /api/model/performance`
- `POST /api/url/analyze`

## Sprint 6 mobile intelligence

The Flutter client already contains the screenshot OCR and share-intent foundation. Sprint 6 keeps the review-before-analysis workflow: shared text or OCR output is inserted into the detection field and the user explicitly starts analysis.

## Before public release

1. Put the API behind HTTPS.
2. Replace in-memory rate limiting with a shared store when using multiple workers.
3. Use a production database with encrypted backups and access control.
4. Add monitoring and alerting for authentication failures and abnormal request rates.
5. Add dependency and vulnerability scanning to CI.
6. Keep model artefacts and calibration metadata versioned together.
7. Protect raw message history or redesign retention/redaction for production privacy requirements.
8. Add automated integration tests against a staging API.
