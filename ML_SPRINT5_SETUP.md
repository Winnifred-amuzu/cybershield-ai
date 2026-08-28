# Cyber-Shield AI — Sprint 5 ML Hardening

## What changed

Sprint 5 replaces the application's fixed LinearSVC confidence fallback with an optional calibrated SVM pipeline.

The compatibility design is deliberate:

- `saved_models/best_model.pkl` remains the legacy model.
- `saved_models/vectorizer.pkl` remains the existing vectorizer.
- `saved_models/calibrated_svm.pkl` is generated only after running the calibration script.
- Until that artifact exists, the API continues using the legacy model and explicitly reports that confidence is uncalibrated.

## Train the calibrated model

From the project root, use the pinned project environment:

```cmd
pip install -r backend\requirements.txt
python ml\train_calibrated_model.py
```

The script:

1. Recreates the dataset harmonisation used by the supplied notebook.
2. Preserves the original stratified 80/20 held-out test set.
3. Uses a validation slice from the training partition for threshold tuning.
4. Trains `LinearSVC` with sigmoid probability calibration.
5. Evaluates accuracy, precision, recall, F1, Brier score and log loss.
6. Saves `calibrated_svm.pkl` and calibration metadata.

## Run the API

```cmd
cd backend
python run.py
```

Then inspect:

- `http://127.0.0.1:8000/docs`
- `GET /api/model/status`

## Interpretation

The API now exposes:

- `confidence`: probability of the predicted class when calibrated.
- `scam_probability`: probability assigned to the SCAM class.
- `confidence_is_calibrated`: whether the calibrated artifact is active.
- `confidence_source`: how the confidence was obtained.
- `decision_threshold`: threshold selected on the validation partition.
- `model_version`: active inference artifact identifier.

Risk is based on **SCAM probability**, not on the maximum probability of either class.

## Important production note

Do not treat calibration as proof of real-world accuracy. Calibration must be rechecked when the training distribution changes. The project should eventually use temporal validation and monitored retraining.

## Testing

```cmd
python -m pytest tests backend\tests
```

The tests cover preprocessing and risk-threshold behaviour. API integration tests should be expanded as deployment requirements mature.
