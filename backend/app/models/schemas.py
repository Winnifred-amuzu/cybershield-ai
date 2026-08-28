from typing import List
from pydantic import BaseModel, Field, ConfigDict

from ..core.config import MAX_MESSAGE_LENGTH


class DetectionRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    message: str = Field(..., min_length=1, max_length=MAX_MESSAGE_LENGTH, description="Message text to analyse")
    source: str = Field(default="SMS", min_length=2, max_length=20, description="Message source: Email, SMS or WhatsApp")


class DetectionResponse(BaseModel):
    prediction: str
    label: int
    confidence: float
    scam_probability: float
    confidence_is_calibrated: bool
    confidence_source: str
    risk_level: str
    decision_threshold: float
    model_version: str
    indicators: List[str]
    source: str
    message_length: int
    scan_id: int
    timestamp: str


class HistoryRecord(BaseModel):
    id: int
    message: str
    source: str
    prediction: str
    confidence: float
    timestamp: str


class DashboardResponse(BaseModel):
    total_scans: int
    threats_found: int
    safe_scans: int
    scam_scans: int
    distribution: dict


class ModelPerformanceRecord(BaseModel):
    model: str
    accuracy: float
    precision: float
    recall: float
    f1: float
