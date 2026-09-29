"""Liveness endpoint for the API process."""

from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    status: Literal["ok"]
    service: str


@router.get("/healthz", response_model=HealthResponse)
async def healthz() -> HealthResponse:
    """Report whether the API process can serve HTTP requests."""
    return HealthResponse(status="ok", service="hafidz-api")
