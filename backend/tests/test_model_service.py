import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "backend"))

from app.services.model_service import model_status


def test_model_status_has_runtime_contract():
    status = model_status()
    assert "calibrated_model_available" in status
    assert "confidence_is_calibrated" in status
    assert "confidence_source" in status
    assert "tuned_threshold" in status
