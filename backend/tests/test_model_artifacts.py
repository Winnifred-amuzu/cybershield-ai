import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "backend"))

from app.core.config import CALIBRATED_MODEL_PATH, CALIBRATED_VECTORIZER_PATH
from app.services.model_service import load_model


def test_calibrated_artifacts_are_paired_when_available():
    if CALIBRATED_MODEL_PATH.exists() and CALIBRATED_VECTORIZER_PATH.exists():
        _, _, calibrated, _ = load_model()
        assert calibrated is True
