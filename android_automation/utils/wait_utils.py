"""Explicit wait helpers and mobile interaction utilities for Appium."""

from typing import Tuple, List, Optional
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException, StaleElementReferenceException

from android_automation.config.appium_config import config
from android_automation.utils.logger import logger


class MobileWaitUtils:
    def __init__(self, driver, timeout: int = None):
        self.driver = driver
        self.timeout = timeout or config.explicit_wait
        self.wait = WebDriverWait(
            self.driver,
            self.timeout,
            ignored_exceptions=[NoSuchElementException, StaleElementReferenceException],
        )

    def wait_for_presence(self, locator: Tuple[str, str], timeout: int = None):
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.presence_of_element_located(locator))

    def wait_for_visible(self, locator: Tuple[str, str], timeout: int = None):
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.visibility_of_element_located(locator))

    def wait_for_clickable(self, locator: Tuple[str, str], timeout: int = None):
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.element_to_be_clickable(locator))

    def wait_for_all_visible(self, locator: Tuple[str, str], timeout: int = None):
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.visibility_of_all_elements_located(locator))
