import os
import pytest


def test_message_request_has_length_limit():
    from app.models.schemas import DetectionRequest
    with pytest.raises(Exception):
        DetectionRequest(message="x" * 5001, source="SMS")


def test_registration_password_requires_letter_and_number():
    from app.models.auth_schemas import RegisterRequest
    with pytest.raises(Exception):
        RegisterRequest(name="Test User", email="test@example.com", password="12345678")
    with pytest.raises(Exception):
        RegisterRequest(name="Test User", email="test2@example.com", password="abcdefgh")


def test_production_placeholder_secret_guard(monkeypatch):
    monkeypatch.setenv("CYBERSHIELD_ENV", "production")
    monkeypatch.setenv("CYBERSHIELD_JWT_SECRET", "change-this-development-secret")
    # Reloading config should fail under these production settings.
    import importlib
    import app.core.config as config
    with pytest.raises(RuntimeError):
        importlib.reload(config)
    monkeypatch.setenv("CYBERSHIELD_ENV", "development")
    importlib.reload(config)
