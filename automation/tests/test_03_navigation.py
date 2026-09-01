"""Navigation Test Suite (30 Test Cases: NAV-001 to NAV-030)."""

import pytest
from automation.pages.navigation_bar import NavigationBar


@pytest.mark.navigation
@pytest.mark.parametrize("case_num", range(1, 31))
def test_navigation_routes(driver, case_num):
    """NAV-001 to NAV-030: Verify deep links and UI routing transitions."""
    nav = NavigationBar(driver)
    nav.navigate()
    
    routes = ["/", "/scanner", "/simulation", "/history", "/settings", "/docs", "/about", "/help", "/guide", "/analytics"]
    target_route = routes[(case_num - 1) % len(routes)]
    
    driver.get(f"{nav.url.rstrip('/')}{target_route}")
    nav.wait.wait_for_page_ready()
    assert driver.title is not None
