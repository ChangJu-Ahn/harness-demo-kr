from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def post_intake(lead_count, sampling_rate_hz, signal_samples, model_confidence):
    return client.post(
        "/ecg/intake",
        json={
            "lead_count": lead_count,
            "sampling_rate_hz": sampling_rate_hz,
            "signal_samples": signal_samples,
            "model_confidence": model_confidence,
        },
    )


def test_accept_valid_high_confidence():
    r = post_intake(12, 500, 2500, 0.95)
    assert r.status_code == 200
    assert r.json() == {"decision": "accept", "reason": None}


def test_accept_confidence_threshold_inclusive():
    r = post_intake(12, 500, 2500, 0.80)
    assert r.status_code == 200
    assert r.json() == {"decision": "accept", "reason": None}


def test_accept_minimum_signal_length_inclusive():
    r = post_intake(12, 500, 2500, 0.95)
    assert r.status_code == 200
    assert r.json() == {"decision": "accept", "reason": None}


def test_needs_human_review_low_confidence():
    r = post_intake(12, 500, 2500, 0.50)
    assert r.status_code == 200
    assert r.json() == {"decision": "needs_human_review", "reason": "low_confidence"}


def test_reject_lead_count_takes_priority_over_confidence():
    r = post_intake(8, 500, 2500, 0.10)
    assert r.status_code == 200
    assert r.json() == {"decision": "reject", "reason": "lead_count"}


def test_reject_sampling_rate():
    r = post_intake(12, 300, 2500, 0.95)
    assert r.status_code == 200
    assert r.json() == {"decision": "reject", "reason": "sampling_rate"}


def test_reject_signal_length_below_boundary():
    r = post_intake(12, 500, 2499, 0.95)
    assert r.status_code == 200
    assert r.json() == {"decision": "reject", "reason": "signal_length"}


def test_missing_field_returns_422():
    r = client.post(
        "/ecg/intake",
        json={"lead_count": 12, "sampling_rate_hz": 500, "signal_samples": 2500},
    )
    assert r.status_code == 422


def test_wrong_type_returns_422():
    r = client.post(
        "/ecg/intake",
        json={
            "lead_count": "twelve",
            "sampling_rate_hz": 500,
            "signal_samples": 2500,
            "model_confidence": 0.95,
        },
    )
    assert r.status_code == 422
