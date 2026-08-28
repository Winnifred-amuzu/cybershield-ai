"""Local API smoke test for Cyber-Shield AI."""
from pathlib import Path
import os
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

checks = []

r = client.get("/")
assert r.status_code == 200, r.text
checks.append(("root", r.status_code))

r = client.get("/health")
assert r.status_code == 200, r.text
checks.append(("health", r.status_code))

r = client.get("/api/model/status")
assert r.status_code == 200, r.text
checks.append(("model-status", r.status_code))

r = client.post("/api/detect", json={
    "message": "URGENT! Verify your bank account immediately at http://example.com",
    "source": "SMS",
})
assert r.status_code == 200, r.text
payload = r.json()
assert payload["prediction"] in {"SAFE", "SCAM / PHISHING"}
assert 0.0 <= payload["scam_probability"] <= 1.0
checks.append(("detect", r.status_code))

print("Cyber-Shield AI API smoke test: PASS")
for name, status in checks:
    print(f"  {name}: HTTP {status}")
print(f"  prediction: {payload['prediction']}")
print(f"  calibrated: {payload['confidence_is_calibrated']}")
print(f"  model: {payload['model_version']}")
