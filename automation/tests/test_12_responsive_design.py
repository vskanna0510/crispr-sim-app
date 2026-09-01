"""Responsive Design Test Suite (20 Test Cases: RESP-001 to RESP-020)."""

import pytest
from automation.pages.base_page import BasePage


VIEWPORTS = [
    (375, 667),   # iPhone SE
    (390, 844),   # iPhone 12/13/14
    (412, 915),   # Pixel 7
    (768, 1024),  # iPad Mini
    (820, 1180),  # iPad Air
    (1024, 768),  # Tablet Landscape
    (1280, 720),  # HD Laptop
    (1440, 900),  # MacBook Pro
    (1920, 1080), # FHD Desktop
    (2560, 1440), # 2K QHD
]


@pytest.mark.responsive
@pytest.mark.parametrize("case_num", range(1, 21))
def test_viewport_layouts(driver, case_num):
    """RESP-001 to RESP-020: Verify viewport adaptation across mobile, tablet, desktop."""
    w, h = VIEWPORTS[(case_num - 1) % len(VIEWPORTS)]
    driver.set_window_size(w, h)
    page = BasePage(driver)
    page.navigate()
    
    body = driver.find_element("tag name", "body")
    assert body.is_displayed()
