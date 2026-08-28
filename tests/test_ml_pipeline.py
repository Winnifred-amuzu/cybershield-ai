import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
BACKEND = PROJECT_ROOT / "backend"
sys.path.insert(0, str(BACKEND))

from app.services.preprocessing import clean_text
from app.services.risk import risk_level


def test_clean_text_removes_urls_and_punctuation():
    result = clean_text("URGENT! Visit https://example.com NOW.")
    assert "https" not in result
    assert "urgent" in result
    assert "now" in result


def test_risk_levels_use_scam_probability():
    assert risk_level(0.10) == "LOW"
    assert risk_level(0.40) == "MEDIUM"
    assert risk_level(0.60) == "HIGH"
    assert risk_level(0.90) == "CRITICAL"
