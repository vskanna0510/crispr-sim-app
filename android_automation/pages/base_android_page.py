"""Base Page Object Model for Android Appium testing."""

from typing import Tuple, List, Optional
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import NoSuchElementException, TimeoutException

from android_automation.config.appium_config import config
from android_automation.utils.wait_utils import MobileWaitUtils
from android_automation.utils.logger import logger


class BaseAndroidPage:
    def __init__(self, driver):
        self.driver = driver
        self.wait = MobileWaitUtils(driver)

    def find_element(self, locator: Tuple[str, str], timeout: int = None):
        return self.wait.wait_for_visible(locator, timeout)

    def find_elements(self, locator: Tuple[str, str], timeout: int = None):
        return self.wait.wait_for_all_visible(locator, timeout)

    def is_element_present(self, locator: Tuple[str, str], timeout: int = 3) -> bool:
        try:
            self.wait.wait_for_presence(locator, timeout)
            return True
        except (TimeoutException, NoSuchElementException):
            return False

    def is_element_displayed(self, locator: Tuple[str, str], timeout: int = 3) -> bool:
        try:
            elem = self.wait.wait_for_visible(locator, timeout)
            return elem.is_displayed()
        except (TimeoutException, NoSuchElementException):
            return False

    def click(self, locator: Tuple[str, str], timeout: int = None):
        elem = self.wait.wait_for_clickable(locator, timeout)
        elem.click()

    def type_text(self, locator: Tuple[str, str], text: str, clear_first: bool = True, timeout: int = None):
        elem = self.wait.wait_for_visible(locator, timeout)
        if clear_first:
            try:
                elem.clear()
            except Exception:
                pass
        elem.send_keys(text)

    def get_text(self, locator: Tuple[str, str], timeout: int = None) -> str:
        elem = self.wait.wait_for_visible(locator, timeout)
        return elem.text.strip()

    def scroll_into_view_by_text(self, text: str):
        """Scrolls using UiScrollable until text is visible."""
        try:
            self.driver.find_element(
                AppiumBy.ANDROID_UIAUTOMATOR,
                f'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().textContains("{text}"))'
            )
        except Exception:
            pass

    def hide_keyboard(self):
        try:
            self.driver.hide_keyboard()
        except Exception:
            pass
