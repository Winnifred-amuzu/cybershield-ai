def risk_level(scam_probability: float, prediction: int | None = None) -> str:
    """Convert calibrated scam probability into a user-facing risk level.

    The probability is the probability of the SCAM class (label 1), not the
    probability of whichever class happened to be predicted.
    """
    probability = max(0.0, min(1.0, float(scam_probability)))

    if probability < 0.30:
        return "LOW"
    if probability < 0.50:
        return "MEDIUM"
    if probability < 0.80:
        return "HIGH"
    return "CRITICAL"
