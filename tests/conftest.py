"""Pytest configuration and shared fixtures."""

import os
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

# Tests run without PostgreSQL or JWT by default.
os.environ.setdefault("REQUIRE_AUTH", "false")
_backend_data = Path(__file__).parent.parent / "backend" / "data"
_backend_data.mkdir(parents=True, exist_ok=True)
os.environ.setdefault(
    "DATABASE_URL",
    f"sqlite:///{_backend_data / 'test_crispr.db'}",
)

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
