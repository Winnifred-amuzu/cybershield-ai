"""Train and evaluate the calibrated Cyber-Shield AI SVM.

Run from the project root with the project's pinned requirements installed:
    python ml/train_calibrated_model.py

The script deliberately keeps the original 80/20 held-out test set. A portion
of the original training set becomes a validation set for threshold tuning, so
the test set is not used to choose the decision threshold.
"""
from __future__ import annotations

import json
from pathlib import Path
import re

import joblib
import numpy as np
import pandas as pd
from sklearn.calibration import CalibratedClassifierCV
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import (
    accuracy_score,
    brier_score_loss,
    classification_report,
    f1_score,
    log_loss,
    precision_score,
    recall_score,
)
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "datasets"
MODELS = ROOT / "saved_models"


def clean_text(text: str) -> str:
    text = str(text).lower()
    text = re.sub(r"http\S+", "", text)
    text = re.sub(r"[^a-zA-Z0-9\s]", "", text)
    return text


def load_and_harmonise() -> pd.DataFrame:
    df1 = pd.read_csv(DATA / "combined label dataset.csv")
    df2 = pd.read_csv(DATA / "smishing dataset.csv")
    df3 = pd.read_csv(DATA / "sms phishing.csv")

    df1["label"] = ((df1["spam label"] == 1) | (df1["smishing label"] == 1)).astype(int)
    df1["source"] = "sms"
    df1["attack_type"] = df1.apply(
        lambda x: "smishing" if x["smishing label"] == 1 else "spam", axis=1
    )
    df1 = df1[["message", "label", "source", "attack_type"]]

    df2 = df2.rename(columns={"translation": "message", "scam_type": "attack_type"})
    df2["label"] = 1
    df2["source"] = "sms"
    df2 = df2[["message", "label", "source", "attack_type"]]

    df3 = df3.rename(columns={"TEXT": "message"})
    df3["label"] = df3["LABEL"].astype(str).str.lower().map(
        lambda value: 0 if value == "ham" else 1
    )
    df3["source"] = "sms"
    df3["attack_type"] = df3["LABEL"].astype(str).str.lower()
    df3 = df3[["message", "label", "source", "attack_type"]]

    data = pd.concat([df1, df2, df3], ignore_index=True)
    data = data.dropna(subset=["message"])
    data = data.drop_duplicates(subset=["message"]).reset_index(drop=True)
    data["message"] = data["message"].astype(str)
    return data


def best_threshold(y_true: np.ndarray, probabilities: np.ndarray) -> tuple[float, float]:
    thresholds = np.arange(0.30, 0.801, 0.01)
    scores = [(float(t), f1_score(y_true, probabilities >= t)) for t in thresholds]
    return max(scores, key=lambda item: (item[1], -abs(item[0] - 0.5)))


def main() -> None:
    data = load_and_harmonise()
    x = data["message"].map(clean_text)
    y = data["label"].to_numpy()

    # Preserve the project's original 80/20 stratified test design.
    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.20, random_state=42, stratify=y
    )

    # Threshold tuning uses a validation slice from the training partition.
    x_fit, x_validation, y_fit, y_validation = train_test_split(
        x_train, y_train, test_size=0.125, random_state=42, stratify=y_train
    )

    vectorizer = TfidfVectorizer(max_features=5000, ngram_range=(1, 2))
    x_fit_vec = vectorizer.fit_transform(x_fit)
    x_validation_vec = vectorizer.transform(x_validation)
    x_test_vec = vectorizer.transform(x_test)

    base = LinearSVC(C=1.0, max_iter=1000)
    calibrated = CalibratedClassifierCV(base, method="sigmoid", cv=5)
    calibrated.fit(x_fit_vec, y_fit)

    validation_probability = calibrated.predict_proba(x_validation_vec)[:, 1]
    tuned_threshold, validation_f1 = best_threshold(y_validation, validation_probability)

    test_probability = calibrated.predict_proba(x_test_vec)[:, 1]
    test_prediction = (test_probability >= tuned_threshold).astype(int)

    metrics = {
        "accuracy": float(accuracy_score(y_test, test_prediction)),
        "precision": float(precision_score(y_test, test_prediction, zero_division=0)),
        "recall": float(recall_score(y_test, test_prediction, zero_division=0)),
        "f1": float(f1_score(y_test, test_prediction, zero_division=0)),
        "brier_score": float(brier_score_loss(y_test, test_probability)),
        "log_loss": float(log_loss(y_test, test_probability, labels=[0, 1])),
        "validation_f1_at_tuned_threshold": float(validation_f1),
        "test_size": int(len(y_test)),
    }

    MODELS.mkdir(parents=True, exist_ok=True)
    joblib.dump(calibrated, MODELS / "calibrated_svm.pkl")
    joblib.dump(vectorizer, MODELS / "calibrated_vectorizer.pkl")

    metadata = {
        "model_version": "calibrated-linear-svm-v1",
        "model_family": "LinearSVC + Platt sigmoid calibration",
        "calibration_method": "sigmoid",
        "calibration_cv": 5,
        "tuned_threshold": tuned_threshold,
        "vectorizer_max_features": 5000,
        "vectorizer_ngram_range": [1, 2],
        "train_test_split": 0.20,
        "threshold_validation_fraction_of_training": 0.125,
        "metrics": metrics,
        "classification_report": classification_report(
            y_test, test_prediction, output_dict=True, zero_division=0
        ),
    }
    (MODELS / "calibration_metadata.json").write_text(
        json.dumps(metadata, indent=2), encoding="utf-8"
    )

    print("Calibration training completed.")
    print(f"Dataset size: {len(data):,}")
    print(f"Tuned threshold: {tuned_threshold:.2f}")
    print(json.dumps(metrics, indent=2))
    print(f"Saved: {MODELS / 'calibrated_svm.pkl'}")
    print(f"Saved: {MODELS / 'calibrated_vectorizer.pkl'}")
    print(f"Saved: {MODELS / 'calibration_metadata.json'}")


if __name__ == "__main__":
    main()
