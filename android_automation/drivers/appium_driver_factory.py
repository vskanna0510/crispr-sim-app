"""Appium WebDriver factory for Android Mobile Automation."""

import os
from typing import Optional
from appium import webdriver
from appium.options.android import UiAutomator2Options

from android_automation.config.appium_config import config
from android_automation.utils.logger import logger
from android_automation.utils.adb_utils import ADBUtils


class AppiumDriverFactory:
    @staticmethod
    def create_driver(custom_caps: dict = None) -> webdriver.Remote:
        """Create and initialize an Appium Remote WebDriver session."""
        options = UiAutomator2Options()
        caps = config.get_desired_capabilities()
        if custom_caps:
            caps.update(custom_caps)
            
        for k, v in caps.items():
            options.set_capability(k, v)

        server_url = f"{config.appium_server_url}/wd/hub" if not config.appium_server_url.endswith("/wd/hub") else config.appium_server_url
        logger.info(f"📱 Initializing Appium session on {server_url} for package '{config.app_package}'...")

        try:
            driver = webdriver.Remote(command_executor=config.appium_server_url, options=options)
            driver.implicitly_wait(config.implicit_wait)
            logger.info("✅ Appium driver session initialized successfully.")
            return driver
        except Exception as e:
            logger.error(f"Failed to initialize Appium session: {e}")
            raise
