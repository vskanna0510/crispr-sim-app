"""Pytest configuration and fixtures for Android Appium Automation."""

import pytest
import os
import sys

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

from android_automation.config.appium_config import config
from android_automation.drivers.appium_driver_factory import AppiumDriverFactory
from android_automation.utils.logger import logger
from android_automation.utils.adb_utils import ADBUtils


@pytest.fixture(scope="session")
def appium_driver():
    """Session-scoped Appium remote driver or mock session."""
    driver = None
    try:
        if ADBUtils.verify_appium_health():
            driver = AppiumDriverFactory.create_driver()
    except Exception as e:
        logger.warning(f"Live Appium session skipped ({e}); using test catalog verification.")
    
    yield driver

    if driver:
        try:
            driver.quit()
        except Exception:
            pass
