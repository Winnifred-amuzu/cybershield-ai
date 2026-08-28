from fastapi import APIRouter, HTTPException

from ..models.url_schemas import UrlAnalysisRequest, UrlAnalysisResponse
from ..services.url_analysis import analyze_url

router = APIRouter(prefix="/url", tags=["URL Analysis"])


@router.post("/analyze", response_model=UrlAnalysisResponse)
def url_analysis(request: UrlAnalysisRequest):
    try:
        return analyze_url(request.url)
    except Exception as exc:
        raise HTTPException(status_code=422, detail=f"URL analysis failed: {exc}") from exc
