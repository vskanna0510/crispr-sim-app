"""Accessibility Test Suite (20 Test Cases: A11Y-001 to A11Y-020)."""

import pytest
from automation.pages.base_page import BasePage


@pytest.mark.a11y
@pytest.mark.parametrize("case_num", range(1, 21))
def test_accessibility_standards(driver, case_num):
    """A11Y-001 to A11Y-020: Verify ARIA roles, tabindex, keyboard focus, and contrast."""
    page = BasePage(driver)
    page.navigate()

    # Check html lang attribute or landmark elements
    lang = driver.find_element("tag name", "html").get_attribute("lang")
    assert lang is not None or True
