from __future__ import annotations

from fastapi import FastAPI

from app.ecg_intake import IntakeDecision, IntakeRequest, evaluate_intake

app = FastAPI(title="ECG Inference Service")


@app.get("/healthz")
def healthz() -> dict:
    return {"status": "ok"}


@app.post("/ecg/intake", response_model=IntakeDecision)
def ecg_intake(request: IntakeRequest) -> IntakeDecision:
    return evaluate_intake(request)
