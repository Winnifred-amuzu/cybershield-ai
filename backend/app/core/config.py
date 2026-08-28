from pathlib import Path
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
MODEL_DIR = ROOT_DIR / "saved_models"
DATASET_DIR = ROOT_DIR / "datasets"
DATABASE_PATH = ROOT_DIR / "history.db"
API_PREFIX = "/api"
APP_NAME = "Cyber-Shield AI API"
APP_VERSION = "3.2.0"
ALLOWED_SOURCES = {"Email", "SMS", "WhatsApp"}

MODEL_PATH = MODEL_DIR / "best_model.pkl"
VECTORIZER_PATH = MODEL_DIR / "vectorizer.pkl"
MODEL_COMPARISON_PATH = MODEL_DIR / "model_comparison.csv"
CALIBRATED_MODEL_PATH = MODEL_DIR / "calibrated_svm.pkl"
CALIBRATED_VECTORIZER_PATH = MODEL_DIR / "calibrated_vectorizer.pkl"
CALIBRATION_METADATA_PATH = MODEL_DIR / "calibration_metadata.json"

DEFAULT_SCAM_THRESHOLD = float(os.getenv("CYBERSHIELD_SCAM_THRESHOLD", "0.50"))
JWT_SECRET = os.getenv("CYBERSHIELD_JWT_SECRET", "change-this-development-secret")
ENVIRONMENT = os.getenv("CYBERSHIELD_ENV", "development").lower()
DATABASE_URL = os.getenv("CYBERSHIELD_DATABASE_URL", f"sqlite:///{DATABASE_PATH.as_posix()}")

_cors_raw = os.getenv(
    "CYBERSHIELD_CORS_ORIGINS",
    "http://localhost:3000,http://localhost:8080",
)
CORS_ORIGINS = [item.strip() for item in _cors_raw.split(",") if item.strip()]

MAX_MESSAGE_LENGTH = int(os.getenv("CYBERSHIELD_MAX_MESSAGE_LENGTH", "5000"))
MAX_URL_LENGTH = int(os.getenv("CYBERSHIELD_MAX_URL_LENGTH", "2048"))
RATE_LIMIT_WINDOW_SECONDS = int(os.getenv("CYBERSHIELD_RATE_LIMIT_WINDOW_SECONDS", "60"))
RATE_LIMIT_MAX_REQUESTS = int(os.getenv("CYBERSHIELD_RATE_LIMIT_MAX_REQUESTS", "60"))
AUTH_RATE_LIMIT_MAX_REQUESTS = int(os.getenv("CYBERSHIELD_AUTH_RATE_LIMIT_MAX_REQUESTS", "10"))
MAX_REQUEST_BODY_BYTES = int(os.getenv("CYBERSHIELD_MAX_REQUEST_BODY_BYTES", "65536"))

if ENVIRONMENT == "production":
    if JWT_SECRET == "change-this-development-secret":
        raise RuntimeError("CYBERSHIELD_JWT_SECRET must be set to a strong secret in production")
    if DATABASE_URL.startswith("sqlite"):
        raise RuntimeError("Production requires CYBERSHIELD_DATABASE_URL to point to PostgreSQL")
    if not CORS_ORIGINS:
        raise RuntimeError("CYBERSHIELD_CORS_ORIGINS must contain at least one trusted origin in production")
