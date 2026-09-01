import os
import pytest
from automation.config.config import config
from automation.utils.driver_factory import DriverFactory
from automation.utils.screenshot_utils import ScreenshotUtils
from automation.utils.logger import logger


def pytest_addoption(parser):
    parser.addoption(
        "--base-url",
        action="store",
        default=os.getenv("BASE_URL", "http://127.0.0.1:8000"),
        help="Target BASE_URL for live E2E tests",
    )


def pytest_configure(config):
    base = config.getoption("--base-url", default=None)
    if base:
        from automation.config.config import config as auto_config
        auto_config.base_url = base.rstrip("/")
    # Register custom marks
    for mark in ["auth", "authz", "navigation", "ui", "forms", "crud", "validation", "error", "session", "upload", "a11y", "responsive", "performance", "regression"]:
        config.addinivalue_line("markers", f"{mark}: E2E test category marker")


@pytest.fixture(scope="session")
def browser_config(request):
    base = request.config.getoption("--base-url")
    if base:
        config.base_url = base.rstrip("/")
    return config


@pytest.fixture(scope="function")
def driver(request):
    """Function-level WebDriver fixture with automatic teardown and screenshot on failure."""
    d = DriverFactory.create_driver(headless=config.headless)
    yield d
    
    # Check test status for automatic screenshot
    if hasattr(request.node, "rep_call") and request.node.rep_call.failed:
        test_id = request.node.name
        ScreenshotUtils.capture_screenshot(d, test_id, suffix="failure")
        
    try:
        d.quit()
    except Exception:
        pass


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, "rep_" + rep.when, rep)
