from functools import lru_cache
from typing import Any, Tuple
import json

import joblib

from ..core.config import (
    CALIBRATED_MODEL_PATH,
    CALIBRATED_VECTORIZER_PATH,
    CALIBRATION_METADATA_PATH,
    DEFAULT_SCAM_THRESHOLD,
    MODEL_PATH,
    VECTORIZER_PATH,
)
from .explanation import explain_message
from .preprocessing import clean_text
from .risk import risk_level


def _load_metadata() -> dict:
    if not CALIBRATION_METADATA_PATH.exists():
        return {}
    try:
        return json.loads(CALIBRATION_METADATA_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


@lru_cache(maxsize=1)
def load_model() -> Tuple[Any, Any, bool, dict]:
    """Load the calibrated model/vectorizer pair when available.

    The original model artefacts remain the compatibility fallback. The
    calibrated model is intentionally paired with its calibrated vectorizer so
    that a future retraining run cannot accidentally mix incompatible
    artefacts.
    """
    metadata = _load_metadata()

    if CALIBRATED_MODEL_PATH.exists() and CALIBRATED_VECTORIZER_PATH.exists():
        model = joblib.load(CALIBRATED_MODEL_PATH)
        vectorizer = joblib.load(CALIBRATED_VECTORIZER_PATH)
        return model, vectorizer, True, metadata

    if not VECTORIZER_PATH.exists():
        raise FileNotFoundError(f"Vectorizer artefact not found: {VECTORIZER_PATH}")
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model artefact not found: {MODEL_PATH}")

    vectorizer = joblib.load(VECTORIZER_PATH)
    model = joblib.load(MODEL_PATH)
    return model, vectorizer, False, {}


def _prediction_from_probability(scam_probability: float, threshold: float) -> int:
    return int(float(scam_probability) >= float(threshold))


def _legacy_prediction(model: Any, vector: Any) -> tuple[int, float, float, bool, str]:
    prediction = int(model.predict(vector)[0])

    if hasattr(model, "predict_proba"):
        probabilities = model.predict_proba(vector)[0]
        scam_probability = float(probabilities[1]) if len(probabilities) > 1 else float(probabilities[0])
        confidence = float(max(probabilities))
        return prediction, confidence, scam_probability, False, "model_probability_uncalibrated"

    return prediction, 0.80, 0.80 if prediction == 1 else 0.20, False, "legacy_fixed_fallback"


def detect_message(message: str) -> dict:
    model, vectorizer, calibrated, metadata = load_model()

    cleaned = clean_text(message)
    vector = vectorizer.transform([cleaned])

    if calibrated:
        probabilities = model.predict_proba(vector)[0]
        scam_probability = float(probabilities[1])
        threshold = float(metadata.get("tuned_threshold", DEFAULT_SCAM_THRESHOLD))
        prediction = _prediction_from_probability(scam_probability, threshold)
        confidence = scam_probability if prediction == 1 else 1.0 - scam_probability
        confidence_source = "calibrated_scam_probability"
        model_version = str(metadata.get("model_version", "calibrated-svm"))
    else:
        prediction, confidence, scam_probability, _, confidence_source = _legacy_prediction(model, vector)
        threshold = DEFAULT_SCAM_THRESHOLD
        model_version = "legacy-best-model"

    result = "SCAM / PHISHING" if prediction == 1 else "SAFE"
    indicators = explain_message(message)

    return {
        "prediction": result,
        "label": prediction,
        "confidence": confidence,
        "scam_probability": scam_probability,
        "confidence_is_calibrated": calibrated,
        "confidence_source": confidence_source,
        "risk_level": risk_level(scam_probability, prediction),
        "decision_threshold": threshold,
        "model_version": model_version,
        "indicators": indicators,
        "message_length": len(message),
    }


def model_status() -> dict:
    calibrated = CALIBRATED_MODEL_PATH.exists() and CALIBRATED_VECTORIZER_PATH.exists()
    metadata = _load_metadata()
    active_model = CALIBRATED_MODEL_PATH if calibrated else MODEL_PATH
    active_vectorizer = CALIBRATED_VECTORIZER_PATH if calibrated else VECTORIZER_PATH
    artefacts_ready = active_model.exists() and active_vectorizer.exists()

    return {
        "calibrated_model_available": calibrated,
        "artefacts_ready": artefacts_ready,
        "model_path": str(active_model),
        "vectorizer_path": str(active_vectorizer),
        "model_version": metadata.get("model_version", "legacy-best-model"),
        "tuned_threshold": metadata.get("tuned_threshold", DEFAULT_SCAM_THRESHOLD),
        "confidence_is_calibrated": calibrated,
        "confidence_source": "calibrated_scam_probability" if calibrated else "legacy_fixed_fallback",
        "message": (
            "Calibrated SVM is active."
            if calibrated
            else "Legacy LinearSVC is active. Run ml/train_calibrated_model.py to enable calibrated confidence."
        ),
    }
