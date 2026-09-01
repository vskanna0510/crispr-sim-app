"""Android Mobile Login and Registration Screen POMs."""

from appium.webdriver.common.appiumby import AppiumBy
from android_automation.pages.base_android_page import BaseAndroidPage


class LoginScreen(BaseAndroidPage):
    EMAIL_FIELD = (AppiumBy.ACCESSIBILITY_ID, "email_input")
    PASSWORD_FIELD = (AppiumBy.ACCESSIBILITY_ID, "password_input")
    LOGIN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "login_submit_btn")
    REGISTER_LINK = (AppiumBy.ACCESSIBILITY_ID, "register_nav_btn")
    ERROR_SNACKBAR = (AppiumBy.XPATH, "//*[contains(@text, 'Error') or contains(@text, 'Incorrect')]")

    def login(self, email: str, password: str):
        if self.is_element_present(self.EMAIL_FIELD, timeout=2):
            self.type_text(self.EMAIL_FIELD, email)
        if self.is_element_present(self.PASSWORD_FIELD, timeout=2):
            self.type_text(self.PASSWORD_FIELD, password)
        if self.is_element_present(self.LOGIN_BUTTON, timeout=2):
            self.click(self.LOGIN_BUTTON)


class RegisterScreen(BaseAndroidPage):
    NAME_FIELD = (AppiumBy.ACCESSIBILITY_ID, "name_input")
    EMAIL_FIELD = (AppiumBy.ACCESSIBILITY_ID, "register_email_input")
    PASSWORD_FIELD = (AppiumBy.ACCESSIBILITY_ID, "register_password_input")
    SUBMIT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "register_submit_btn")

    def register(self, name: str, email: str, password: str):
        if self.is_element_present(self.NAME_FIELD, timeout=2):
            self.type_text(self.NAME_FIELD, name)
        if self.is_element_present(self.EMAIL_FIELD, timeout=2):
            self.type_text(self.EMAIL_FIELD, email)
        if self.is_element_present(self.PASSWORD_FIELD, timeout=2):
            self.type_text(self.PASSWORD_FIELD, password)
        if self.is_element_present(self.SUBMIT_BUTTON, timeout=2):
            self.click(self.SUBMIT_BUTTON)
