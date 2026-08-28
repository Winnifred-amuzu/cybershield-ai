from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.auth import router as auth_router
from .api.dashboard import router as dashboard_router
from .api.detection import router as detection_router
from .api.history import router as history_router
from .api.mobile import router as mobile_router
from .api.model import router as model_router
from .api.url import router as url_router
from .core.config import API_PREFIX, APP_NAME, APP_VERSION, CORS_ORIGINS, ENVIRONMENT
from .middleware.security import (
    InMemoryRateLimitMiddleware,
    RequestSizeLimitMiddleware,
    SecurityHeadersMiddleware,
)
from .services.database import create_database, database_health
from .services.model_service import model_status

app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="Cyber-Shield AI backend with calibrated ML inference, authenticated mobile endpoints and production security controls.",
    docs_url="/docs" if ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if ENVIRONMENT != "production" else None,
)

app.add_middleware(RequestSizeLimitMiddleware)
app.add_middleware(InMemoryRateLimitMiddleware)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


@app.on_event("startup")
def startup_event():
    create_database()


@app.get("/", tags=["System"])
def root():
    return {
        "name": APP_NAME,
        "version": APP_VERSION,
        "status": "online",
        "mobile_ready": True,
        "authentication": True,
        "environment": ENVIRONMENT,
    }


@app.get("/health", tags=["System"])
def health():
    db_ok = database_health()
    ml = model_status()
    ml_ok = bool(ml.get("artefacts_ready", False))
    overall = db_ok and ml_ok
    return {
        "status": "healthy" if overall else "degraded",
        "environment": ENVIRONMENT,
        "database": "ok" if db_ok else "unavailable",
        "model": "ok" if ml_ok else "unavailable",
        "confidence_is_calibrated": bool(ml.get("confidence_is_calibrated", False)),
        "model_version": ml.get("model_version"),
    }


app.include_router(auth_router, prefix=API_PREFIX)
app.include_router(detection_router, prefix=API_PREFIX)
app.include_router(history_router, prefix=API_PREFIX)
app.include_router(dashboard_router, prefix=API_PREFIX)
app.include_router(model_router, prefix=API_PREFIX)
app.include_router(url_router, prefix=API_PREFIX)
app.include_router(mobile_router, prefix=API_PREFIX)
