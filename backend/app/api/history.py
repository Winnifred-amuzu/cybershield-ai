from typing import List

from fastapi import APIRouter, Query

from ..models.schemas import HistoryRecord
from ..services.database import get_history

router = APIRouter(prefix="/history", tags=["History"])


@router.get("", response_model=List[HistoryRecord])
def history(limit: int = Query(default=100, ge=1, le=1000)):
    return get_history(limit=limit)
