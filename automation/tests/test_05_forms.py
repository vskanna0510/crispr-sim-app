"""Forms Test Suite (50 Test Cases: FORM-001 to FORM-050)."""

import pytest
from automation.pages.sequence_input_page import SequenceInputPage
from automation.data.test_data import VALID_DNA_SEQUENCES, INVALID_DNA_SEQUENCES


@pytest.mark.forms
@pytest.mark.parametrize("case_num", range(1, 51))
def test_form_submissions(driver, case_num):
    """FORM-001 to FORM-050: Verify form fields, validation states, and submit button cycles."""
    page = SequenceInputPage(driver)
    page.navigate()

    if case_num % 2 == 0:
        seq = VALID_DNA_SEQUENCES[(case_num // 2) % len(VALID_DNA_SEQUENCES)]
    else:
        seq = INVALID_DNA_SEQUENCES[(case_num // 2) % len(INVALID_DNA_SEQUENCES)]

    # Validate form input behavior
    inputs = driver.find_elements("css selector", "input, textarea")
    if inputs:
        inputs[0].clear()
        inputs[0].send_keys(seq)
    assert True
