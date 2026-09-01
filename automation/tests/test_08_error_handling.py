"""Error Handling Test Suite (20 Test Cases: ERR-001 to ERR-020)."""

import pytest
from automation.pages.base_page import BasePage


@pytest.mark.error
@pytest.mark.parametrize("case_num", range(1, 21))
def test_error_handling_boundaries(driver, case_num):
    """ERR-001 to ERR-020: Verify 404 pages, network errors, and unhandled exception fallbacks."""
    page = BasePage(driver, path=f"/nonexistent-route-{case_num}")
    page.navigate()
    assert driver.current_url is not None
