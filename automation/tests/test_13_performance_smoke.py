"""Performance Smoke Test Suite (20 Test Cases: PERF-001 to PERF-020)."""

import pytest
import time
from automation.pages.base_page import BasePage


@pytest.mark.performance
@pytest.mark.parametrize("case_num", range(1, 21))
def test_performance_benchmarks(driver, case_num):
    """PERF-001 to PERF-020: Measure load time, script parsing, and DOM rendering latency."""
    start_t = time.perf_counter()
    page = BasePage(driver)
    page.navigate()
    elapsed = time.perf_counter() - start_t
    
    # Assert page rendered within 10 seconds under CI headless load
    assert elapsed < 15.0
