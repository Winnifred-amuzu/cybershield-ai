from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException

from ..auth.dependencies import get_current_user
from ..core.config import ALLOWED_SOURCES
from ..models.schemas import DetectionRequest, DetectionResponse
from ..services.database import get_user_history, get_user_dashboard, save_user_history
from ..services.model_service import detect_message

router = APIRouter(prefix="/mobile", tags=["Mobile"])


@router.post("/detect", response_model=DetectionResponse)
def mobile_detect(request: DetectionRequest, user=Depends(get_current_user)):
    source = request.source.strip()
    message = request.message.strip()
    if source not in ALLOWED_SOURCES:
        raise HTTPException(status_code=422, detail=f"Invalid source. Choose one of: {', '.join(sorted(ALLOWED_SOURCES))}")
    if not message:
        raise HTTPException(status_code=422, detail="Enter a message")

    try:
        result = detect_message(message)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Detection failed: {exc}") from exc

    scan_id = save_user_history(user["id"], message, source, result["prediction"], result["confidence"])
    return DetectionResponse(
        **result,
        source=source,
        scan_id=scan_id,
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    )


@router.get("/history")
def mobile_history(limit: int = 100, user=Depends(get_current_user)):
    return get_user_history(user["id"], min(max(limit, 1), 200))


@router.get("/dashboard")
def mobile_dashboard(user=Depends(get_current_user)):
    return get_user_dashboard(user["id"])
