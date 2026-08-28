# Cyber-Shield AI Backend API

This backend is the first mobile-app extension of the existing Cyber-Shield AI Streamlit system.

It deliberately reuses the existing:

- `saved_models/best_model.pkl`
- `saved_models/vectorizer.pkl`
- `saved_models/model_comparison.csv`
- `history.db`

The original `detection_app.py` remains untouched and continues to run the existing web application.

## Start the API from the project root

```cmd
cd backend
python run.py
```

Or:

```cmd
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API documentation

Once running:

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`
- Health: `http://127.0.0.1:8000/health`

## Endpoints

- `POST /api/detect`
- `GET /api/history`
- `GET /api/dashboard`
- `GET /api/model/performance`

## Important compatibility note

The current deployed model is `LinearSVC`. It does not expose `predict_proba()`, so the original application's `0.80` confidence fallback is preserved for behavioural compatibility. The API explicitly returns `confidence_is_calibrated: false` so that the mobile client does not present this value as a calibrated probability.
