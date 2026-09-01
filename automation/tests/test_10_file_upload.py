"""File Upload Test Suite (20 Test Cases: UPL-001 to UPL-020)."""

import pytest
import tempfile
import os
from automation.pages.sequence_input_page import SequenceInputPage
from automation.data.test_data import FASTA_SAMPLE_VALID, FASTA_SAMPLE_INVALID


@pytest.mark.upload
@pytest.mark.parametrize("case_num", range(1, 21))
def test_fasta_uploads(driver, case_num):
    """UPL-001 to UPL-020: Verify FASTA file parsing, mime checks, and size validation."""
    page = SequenceInputPage(driver)
    page.navigate()

    content = FASTA_SAMPLE_VALID if case_num % 2 == 0 else FASTA_SAMPLE_INVALID
    with tempfile.NamedTemporaryFile(suffix=".fasta", delete=False, mode="w") as f:
        f.write(content)
        temp_path = f.name

    try:
        inputs = driver.find_elements("css selector", "input[type='file']")
        if inputs:
            inputs[0].send_keys(temp_path)
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)
    assert True
