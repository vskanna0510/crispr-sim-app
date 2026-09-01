"""Page Object Model for Registration screen."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class RegistrationPage(BasePage):
    NAME_INPUT = (By.CSS_SELECTOR, "input[name='name'], input[id*='name'], input[placeholder*='Name']")
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email'], input[name='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password'], input[name='password']")
    CONFIRM_PASSWORD_INPUT = (By.CSS_SELECTOR, "input[name='confirm_password'], input[id*='confirm']")
    SUBMIT_BUTTON = (By.XPATH, "//button[contains(., 'Sign Up') or contains(., 'Register') or @type='submit']")
    SUCCESS_ALERT = (By.CSS_SELECTOR, ".success, .alert-success, [role='status']")

    def __init__(self, driver):
        super().__init__(driver, path="/register")

    def register(self, name: str, email: str, password: str, confirm_password: str = None):
        if self.is_element_present(self.NAME_INPUT, timeout=2):
            self.type_text(self.NAME_INPUT, name)
        self.type_text(self.EMAIL_INPUT, email)
        self.type_text(self.PASSWORD_INPUT, password)
        if confirm_password and self.is_element_present(self.CONFIRM_PASSWORD_INPUT, timeout=2):
            self.type_text(self.CONFIRM_PASSWORD_INPUT, confirm_password)
        self.click(self.SUBMIT_BUTTON)
        self.wait.wait_for_page_ready()
