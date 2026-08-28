from datetime import datetime

from fastapi import APIRouter, HTTPException

from ..core.config import ALLOWED_SOURCES
from ..models.schemas import DetectionRequest, DetectionResponse
from ..services.database import save_history
from ..services.model_service import detect_message

router = APIRouter(prefix="/detect", tags=["Detection"])


@router.post("", response_model=DetectionResponse)
def detect(request: DetectionRequest):
    source = request.source.strip()
    if source not in ALLOWED_SOURCES:
        raise HTTPException(
            status_code=422,
            detail=f"Invalid source. Choose one of: {', '.join(sorted(ALLOWED_SOURCES))}",
        )

    message = request.message.strip()
    if not message:
        raise HTTPException(status_code=422, detail="Enter a message")

    try:
        result = detect_message(message)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Detection failed: {exc}") from exc

    scan_id = save_history(
        message=message,
        source=source,
        prediction=result["prediction"],
        confidence=result["confidence"],
    )

    return DetectionResponse(
        **result,
        source=source,
        scan_id=scan_id,
        timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    )
