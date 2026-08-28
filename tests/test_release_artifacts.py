from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_calibrated_model_artifacts_exist():
    saved = ROOT / "saved_models"
    assert (saved / "calibrated_svm.pkl").exists()
    assert (saved / "calibrated_vectorizer.pkl").exists()
    assert (saved / "calibration_metadata.json").exists()


def test_mobile_release_documents_exist():
    mobile = ROOT / "mobile"
    assert (mobile / "RELEASE_BUILD_SPRINT10.md").exists()
    assert (ROOT / "DEVICE_QA_SPRINT10.md").exists()
