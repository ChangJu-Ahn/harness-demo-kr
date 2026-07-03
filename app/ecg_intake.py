from __future__ import annotations

from typing import Literal, Optional

from pydantic import BaseModel

VALID_LEAD_COUNT = 12
VALID_SAMPLING_RATES = {250, 500, 1000}
MIN_SIGNAL_SECONDS = 5
MIN_CONFIDENCE = 0.80

Decision = Literal["accept", "reject", "needs_human_review"]
Reason = Literal["lead_count", "sampling_rate", "signal_length", "low_confidence"]


class IntakeRequest(BaseModel):
    lead_count: int
    sampling_rate_hz: int
    signal_samples: int
    model_confidence: float


class IntakeDecision(BaseModel):
    decision: Decision
    reason: Optional[Reason] = None


def evaluate_intake(request: IntakeRequest) -> IntakeDecision:
    if request.lead_count != VALID_LEAD_COUNT:
        return IntakeDecision(decision="reject", reason="lead_count")
    if request.sampling_rate_hz not in VALID_SAMPLING_RATES:
        return IntakeDecision(decision="reject", reason="sampling_rate")
    if request.signal_samples < request.sampling_rate_hz * MIN_SIGNAL_SECONDS:
        return IntakeDecision(decision="reject", reason="signal_length")
    if request.model_confidence < MIN_CONFIDENCE:
        return IntakeDecision(decision="needs_human_review", reason="low_confidence")
    return IntakeDecision(decision="accept", reason=None)
