"""Device screenshot capture and diagnostics for Android automation."""

import os
from datetime import datetime
from android_automation.config.appium_config import config
from android_automation.utils.logger import logger


class MobileScreenshotUtils:
    @staticmethod
    def capture_screenshot(driver, test_id: str, suffix: str = "failure") -> str:
        """Capture mobile device screenshot and save to Test Results/Screenshots/."""
        os.makedirs(config.screenshots_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        clean_id = test_id.replace(" ", "_").replace("/", "_").replace(":", "_")
        filename = f"ANDROID_{clean_id}_{suffix}_{timestamp}.png"
        filepath = os.path.join(config.screenshots_dir, filename)

        try:
            driver.save_screenshot(filepath)
            logger.info(f"📸 Device screenshot saved: {filepath}")
            return filepath
        except Exception as e:
            logger.error(f"Failed to capture device screenshot for {test_id}: {e}")
            return ""
