from __future__ import annotations

from fastapi import FastAPI

app = FastAPI(title="ECG Inference Service")


@app.get("/healthz")
def healthz() -> dict:
    return {"status": "ok"}
