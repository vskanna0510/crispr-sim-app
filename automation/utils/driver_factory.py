"""Selenium WebDriver factory for Headless Chrome and CI/CD execution."""

import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

from automation.config.config import config
from automation.utils.logger import logger


class DriverFactory:
    @staticmethod
    def create_driver(headless: bool = None) -> webdriver.Chrome:
        """Create and configure Chrome WebDriver with enterprise-grade flags."""
        if headless is None:
            headless = config.headless

        chrome_options = Options()
        if headless:
            chrome_options.add_argument("--headless=new")
        
        # Enterprise & CI/CD Stability Options
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument(f"--window-size={config.browser_width},{config.browser_height}")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-infobars")
        chrome_options.add_argument("--disable-notifications")
        chrome_options.add_argument("--ignore-certificate-errors")
        chrome_options.add_argument("--allow-running-insecure-content")
        chrome_options.add_argument("--remote-allow-origins=*")
        chrome_options.add_argument("--disable-search-engine-choice-screen")
        
        # Enable browser performance and console logs
        chrome_options.set_capability("goog:loggingPrefs", {"browser": "ALL", "performance": "ALL"})

        try:
            # First try default chromedriver discovery (CI pre-installed)
            driver = webdriver.Chrome(options=chrome_options)
        except Exception:
            try:
                # Fallback to webdriver-manager
                service = Service(ChromeDriverManager().install())
                driver = webdriver.Chrome(service=service, options=chrome_options)
            except Exception as e:
                logger.error(f"Failed to initialize Chrome Driver: {e}")
                raise

        driver.set_page_load_timeout(config.page_load_timeout)
        driver.implicitly_wait(config.implicit_wait)
        logger.debug("ChromeDriver created successfully with headless=%s", headless)
        return driver
