# Cyber-Shield AI Production Security Checklist

## API
- [ ] Deploy behind HTTPS/TLS.
- [ ] Set `CYBERSHIELD_ENV=production`.
- [ ] Set a long random `CYBERSHIELD_JWT_SECRET`.
- [ ] Set `CYBERSHIELD_CORS_ORIGINS` to exact trusted origins.
- [ ] Keep interactive docs disabled in production unless explicitly needed.
- [ ] Put a shared rate limiter (Redis/API gateway) in front of multiple workers.
- [ ] Add central logging and alerting.
- [ ] Add dependency vulnerability scanning.

## Authentication
- [ ] Enforce verified email or another account-verification mechanism before sensitive features.
- [ ] Add refresh-token rotation if long-lived sessions are introduced.
- [ ] Add account lockout / progressive delays for repeated failed login attempts.
- [ ] Never log passwords or access tokens.

## Data
- [ ] Encrypt production database backups.
- [ ] Minimise raw message retention.
- [ ] Add retention/deletion controls.
- [ ] Protect user-history endpoints with authorization.
- [ ] Do not expose raw messages in analytics logs.

## ML
- [ ] Version model + vectorizer + calibration metadata together.
- [ ] Monitor calibration and drift.
- [ ] Revalidate thresholds after retraining.
- [ ] Keep test data isolated from threshold tuning.
- [ ] Track false negatives as a security-critical metric.

## Mobile
- [ ] Use HTTPS API URLs in release builds.
- [ ] Store access tokens only in secure storage.
- [ ] Avoid embedding backend secrets in the APK.
- [ ] Review Android share permissions and intent filters.
- [ ] Add certificate/public-key pinning only after a controlled deployment and rotation plan exists.
