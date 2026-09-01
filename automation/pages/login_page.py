"""Page Object Model for Authentication and Login screens."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class LoginPage(BasePage):
    # Locators
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email'], input[name='email'], input[id*='email'], flt-semantics input")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password'], input[name='password'], input[id*='password']")
    LOGIN_BUTTON = (By.XPATH, "//button[contains(., 'Login') or contains(., 'Sign In') or @type='submit']")
    REGISTER_LINK = (By.XPATH, "//a[contains(., 'Register') or contains(., 'Sign Up')] | //button[contains(., 'Register')]")
    ERROR_BANNER = (By.CSS_SELECTOR, ".error, .alert-danger, [role='alert'], .toast-error")
    USER_PROFILE = (By.CSS_SELECTOR, ".user-avatar, .profile-badge, [data-testid='user-profile']")

    def __init__(self, driver):
        super().__init__(driver, path="/login")

    def login(self, email: str, password: str):
        if self.is_element_present(self.EMAIL_INPUT, timeout=2):
            self.type_text(self.EMAIL_INPUT, email)
        if self.is_element_present(self.PASSWORD_INPUT, timeout=2):
            self.type_text(self.PASSWORD_INPUT, password)
        if self.is_element_present(self.LOGIN_BUTTON, timeout=2):
            self.click(self.LOGIN_BUTTON)
            self.wait.wait_for_page_ready()

    def get_error_message(self) -> str:
        if self.is_element_displayed(self.ERROR_BANNER, timeout=5):
            return self.get_text(self.ERROR_BANNER)
        return ""

    def is_logged_in(self) -> bool:
        return self.is_element_displayed(self.USER_PROFILE, timeout=5)
