"""Page Object Model for PAM Scanner & Guide RNA recommendations."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class PamScannerPage(BasePage):
    CAS_DROPDOWN = (By.CSS_SELECTOR, "select[name='cas_type'], [data-testid='cas-select']")
    SCAN_BUTTON = (By.XPATH, "//button[contains(., 'Scan PAM') or contains(., 'Find Sites')]")
    PAM_CARDS = (By.CSS_SELECTOR, ".pam-card, .site-item, [data-testid='pam-site']")
    RECOMMENDED_BADGE = (By.CSS_SELECTOR, ".recommended-badge, .badge-success")
    SELECT_FIRST_PAM_BUTTON = (By.XPATH, "(//button[contains(., 'Select') or contains(., 'Cut')])[1]")

    def __init__(self, driver):
        super().__init__(driver, path="/scanner")

    def select_cas_type(self, cas_type: str = "cas9"):
        if self.is_element_present(self.CAS_DROPDOWN, timeout=3):
            # Select or click option
            dropdown = self.find_element(self.CAS_DROPDOWN)
            dropdown.click()
            opt = (By.XPATH, f"//option[@value='{cas_type}'] | //*[text()='{cas_type.upper()}']")
            if self.is_element_present(opt, timeout=2):
                self.click(opt)

    def scan(self):
        self.click(self.SCAN_BUTTON)
        self.wait.wait_for_page_ready()

    def get_pam_site_count(self) -> int:
        if self.is_element_present(self.PAM_CARDS, timeout=5):
            return len(self.find_elements(self.PAM_CARDS))
        return 0
