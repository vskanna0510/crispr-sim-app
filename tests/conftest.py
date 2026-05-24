"""Pytest configuration and shared fixtures."""

import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

# Ensure the backend package is on the path when tests are run from project root.
sys.path.insert(0, str(Path(__file__).parent.parent / "backend"))

from main import app  # noqa: E402  (import after sys.path edit)


@pytest.fixture(scope="session")
def client() -> TestClient:
    """Synchronous HTTPX test client for the FastAPI app."""
    with TestClient(app) as c:
        yield c


# ─── Shared DNA constants ─────────────────────────────────────────────────────

VALID_DNA = (
    "ATGGTGCACCTGACTCCTGAGGAGAAGTCTGCCGTTACTGCCCTGTGGGGCAAGGTGAACGTGGATGAA"
    "GTTGGTGGTGAGGCCCTGGGCAGGCTGCTGGTGGTCTACCCTTGGACCCAGAGGTTCTTTGAGTCCTT"
)

SHORT_DNA = "ATGCATGCATGCATGCATGCAGGATGC"

INVALID_DNA = "ATGCATGXYZ"
