"""Navigation Bar and App Shell Page Object Model."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class NavigationBar(BasePage):
    LOGO = (By.CSS_SELECTOR, ".logo, [data-testid='app-logo'], header img, header h1")
    HOME_TAB = (By.XPATH, "//a[contains(., 'Home')] | //button[contains(., 'Home')] | //*[contains(@aria-label, 'Home')]")
    SCANNER_TAB = (By.XPATH, "//a[contains(., 'Scanner') or contains(., 'PAM')] | //button[contains(., 'Scanner')]")
    SIMULATION_TAB = (By.XPATH, "//a[contains(., 'Simulation') or contains(., 'Cut')] | //button[contains(., 'Simulation')]")
    HISTORY_TAB = (By.XPATH, "//a[contains(., 'History')] | //button[contains(., 'History')]")
    SETTINGS_TAB = (By.XPATH, "//a[contains(., 'Settings')] | //button[contains(., 'Settings')]")
    LOGOUT_BUTTON = (By.XPATH, "//button[contains(., 'Logout') or contains(., 'Sign Out')]")

    def go_to_home(self):
        self.click(self.HOME_TAB)
        self.wait.wait_for_page_ready()

    def go_to_scanner(self):
        self.click(self.SCANNER_TAB)
        self.wait.wait_for_page_ready()

    def go_to_history(self):
        self.click(self.HISTORY_TAB)
        self.wait.wait_for_page_ready()

    def go_to_settings(self):
        self.click(self.SETTINGS_TAB)
        self.wait.wait_for_page_ready()
