"""Base Page Object Model with shared web interaction primitives."""

from typing import Tuple, List, Optional
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException, TimeoutException

from automation.config.config import config
from automation.utils.wait_utils import WaitUtils
from automation.utils.logger import logger


class BasePage:
    def __init__(self, driver: WebDriver, path: str = ""):
        self.driver = driver
        self.path = path
        self.wait = WaitUtils(driver)
        self.actions = ActionChains(driver)

    @property
    def url(self) -> str:
        base = config.base_url.rstrip("/")
        if not self.path or self.path == "/":
            return base
        sub = self.path if self.path.startswith("/") else f"/{self.path}"
        return f"{base}{sub}"

    def navigate(self) -> "BasePage":
        target = self.url
        logger.info(f"Navigating to: {target}")
        self.driver.get(target)
        self.wait.wait_for_page_ready()
        return self

    def get_title(self) -> str:
        return self.driver.title

    def get_current_url(self) -> str:
        return self.driver.current_url

    def find_element(self, locator: Tuple[str, str], timeout: int = None) -> WebElement:
        return self.wait.wait_for_visible(locator, timeout)

    def find_elements(self, locator: Tuple[str, str], timeout: int = None) -> List[WebElement]:
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
        self.scroll_into_view(elem)
        elem.click()

    def type_text(self, locator: Tuple[str, str], text: str, clear_first: bool = True, timeout: int = None):
        elem = self.wait.wait_for_visible(locator, timeout)
        self.scroll_into_view(elem)
        if clear_first:
            elem.clear()
        elem.send_keys(text)

    def get_text(self, locator: Tuple[str, str], timeout: int = None) -> str:
        elem = self.wait.wait_for_visible(locator, timeout)
        return elem.text.strip()

    def get_attribute(self, locator: Tuple[str, str], attribute: str, timeout: int = None) -> Optional[str]:
        elem = self.wait.wait_for_presence(locator, timeout)
        return elem.get_attribute(attribute)

    def scroll_into_view(self, element: WebElement):
        try:
            self.driver.execute_script("arguments[0].scrollIntoView({block: 'center', inline: 'nearest'});", element)
        except Exception:
            pass

    def execute_script(self, script: str, *args):
        return self.driver.execute_script(script, *args)
