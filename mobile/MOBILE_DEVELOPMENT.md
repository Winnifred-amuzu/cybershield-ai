# Cyber-Shield AI Mobile Development

The mobile application is the Flutter client for the existing Cyber-Shield AI ML system.

## Current architecture

Flutter → authenticated FastAPI → preprocessing → TF-IDF → calibrated Linear SVM (when available) → explanation/risk → SQLite history.

## Sprint 5

The API now supports calibrated inference when `saved_models/calibrated_svm.pkl` exists. Before that artifact is generated, the app remains backward-compatible with `best_model.pkl` and clearly marks confidence as uncalibrated.

### Calibrated fields

The detection response now contains:

- `confidence`
- `scam_probability`
- `confidence_is_calibrated`
- `confidence_source`
- `decision_threshold`
- `model_version`

### Training

From project root:

```cmd
pip install -r backend\requirements.txt
python ml\train_calibrated_model.py
```

Then restart the API. Check:

```text
GET /api/model/status
```

The response should report `calibrated_model_available: true` after successful training.
