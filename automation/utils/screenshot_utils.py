"""Screenshot capture and failure diagnostics utility."""

import os
from datetime import datetime
from selenium.webdriver.remote.webdriver import WebDriver
from automation.config.config import config
from automation.utils.logger import logger


class ScreenshotUtils:
    @staticmethod
    def capture_screenshot(driver: WebDriver, test_id: str, suffix: str = "failure") -> str:
        """Capture screenshot and save to the configured Screenshots directory."""
        os.makedirs(config.screenshots_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        clean_id = test_id.replace(" ", "_").replace("/", "_").replace(":", "_")
        filename = f"{clean_id}_{suffix}_{timestamp}.png"
        filepath = os.path.join(config.screenshots_dir, filename)

        try:
            driver.save_screenshot(filepath)
            logger.info(f"📸 Screenshot captured: {filepath}")
            return filepath
        except Exception as e:
            logger.error(f"Failed to capture screenshot for {test_id}: {e}")
            return ""

    @staticmethod
    def capture_browser_logs(driver: WebDriver, test_id: str) -> list:
        """Fetch and return browser console logs."""
        try:
            logs = driver.get_log("browser")
            return [f"[{entry.get('level')}] {entry.get('message')}" for entry in logs]
        except Exception:
            return []
