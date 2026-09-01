"""Pytest wrapper for CRISPR-Sim E2E suite."""

from __future__ import annotations

import os
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))

from runner import E2ERunner
from test_catalog import TEST_CASES


@pytest.fixture(scope="session")
def e2e_runner():
    base_url = os.environ.get("E2E_BASE_URL", "https://crispr-sim-backend.onrender.com")
    app_url = os.environ.get("E2E_APP_URL") or None
    headless = os.environ.get("E2E_HEADLESS", "true").lower() != "false"
    runner = E2ERunner(base_url=base_url, app_url=app_url, headless=headless)
    yield runner
    runner.close()


@pytest.mark.parametrize("case", TEST_CASES, ids=lambda c: c.test_id)
def test_e2e_case(e2e_runner: E2ERunner, case):
    result = e2e_runner.run_case(case)
    assert result.status != "FAIL", f"{case.test_id}: {result.actual}"
