from typing import List

import pandas as pd
from fastapi import APIRouter, HTTPException

from ..core.config import MODEL_COMPARISON_PATH
from ..models.schemas import ModelPerformanceRecord
from ..services.model_service import model_status

router = APIRouter(prefix="/model", tags=["Model"])


@router.get("/performance", response_model=List[ModelPerformanceRecord])
def model_performance():
    if not MODEL_COMPARISON_PATH.exists():
        raise HTTPException(status_code=404, detail="Model comparison file not found")

    df = pd.read_csv(MODEL_COMPARISON_PATH)
    df.columns = [str(column).strip().lower() for column in df.columns]

    records = []
    for _, row in df.iterrows():
        records.append(
            ModelPerformanceRecord(
                model=str(row["model"]),
                accuracy=float(row["accuracy"]),
                precision=float(row["precision"]),
                recall=float(row["recall"]),
                f1=float(row["f1"]),
            )
        )

    return records


@router.get("/status")
def model_runtime_status():
    return model_status()
