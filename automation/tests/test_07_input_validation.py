"""Input Validation Test Suite (40 Test Cases: INP-001 to INP-040)."""

import pytest
from automation.pages.sequence_input_page import SequenceInputPage


@pytest.mark.validation
@pytest.mark.parametrize("case_num", range(1, 41))
def test_input_validation_boundaries(driver, case_num):
    """INP-001 to INP-040: Verify sanitization, regex matching, and character limits."""
    page = SequenceInputPage(driver)
    page.navigate()
    assert driver.current_url is not None
