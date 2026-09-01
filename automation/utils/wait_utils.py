"""Explicit wait helpers for robust Selenium element interactions."""

from typing import Tuple, List, Optional
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, StaleElementReferenceException

from automation.config.config import config
from automation.utils.logger import logger


class WaitUtils:
    def __init__(self, driver: WebDriver, timeout: int = None):
        self.driver = driver
        self.timeout = timeout or config.explicit_wait
        self.wait = WebDriverWait(
            self.driver,
            self.timeout,
            ignored_exceptions=[NoSuchElementException, StaleElementReferenceException],
        )

    def wait_for_presence(self, locator: Tuple[str, str], timeout: int = None) -> WebElement:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.presence_of_element_located(locator))

    def wait_for_visible(self, locator: Tuple[str, str], timeout: int = None) -> WebElement:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.visibility_of_element_located(locator))

    def wait_for_clickable(self, locator: Tuple[str, str], timeout: int = None) -> WebElement:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.element_to_be_clickable(locator))

    def wait_for_all_visible(self, locator: Tuple[str, str], timeout: int = None) -> List[WebElement]:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.visibility_of_all_elements_located(locator))

    def wait_for_text_present(self, locator: Tuple[str, str], text: str, timeout: int = None) -> bool:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.text_to_be_present_in_element(locator, text))

    def wait_for_url_contains(self, fraction: str, timeout: int = None) -> bool:
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(EC.url_contains(fraction))

    def wait_for_page_ready(self, timeout: int = 15) -> bool:
        """Wait until document.readyState is 'complete'."""
        try:
            return WebDriverWait(self.driver, timeout).until(
                lambda d: d.execute_script("return document.readyState") == "complete"
            )
        except TimeoutException:
            logger.warning("Page ready state check timed out; continuing...")
            return False
