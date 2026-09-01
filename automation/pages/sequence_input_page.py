"""Page Object Model for Sequence Input and DNA Validation."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class SequenceInputPage(BasePage):
    SEQUENCE_TEXTAREA = (By.CSS_SELECTOR, "textarea, input[placeholder*='sequence' i], [data-testid='dna-input']")
    PASTE_TAB = (By.XPATH, "//*[contains(text(), 'Paste') or contains(text(), 'Manual')]")
    FASTA_UPLOAD_INPUT = (By.CSS_SELECTOR, "input[type='file']")
    NCBI_ACCESSION_INPUT = (By.CSS_SELECTOR, "input[placeholder*='accession' i], input[name='accession']")
    FETCH_NCBI_BUTTON = (By.XPATH, "//button[contains(., 'Fetch') or contains(., 'NCBI')]")
    SUBMIT_BUTTON = (By.XPATH, "//button[contains(., 'Validate') or contains(., 'Proceed') or contains(., 'Scan')]")
    GC_PERCENT_LABEL = (By.CSS_SELECTOR, ".gc-content, [data-testid='gc-percent']")
    ERROR_MESSAGE = (By.CSS_SELECTOR, ".error, .validation-error, [role='alert']")

    def __init__(self, driver):
        super().__init__(driver, path="/")

    def input_dna_sequence(self, sequence: str):
        if self.is_element_present(self.SEQUENCE_TEXTAREA, timeout=2):
            self.type_text(self.SEQUENCE_TEXTAREA, sequence)

    def submit_sequence(self):
        if self.is_element_present(self.SUBMIT_BUTTON, timeout=2):
            self.click(self.SUBMIT_BUTTON)
            self.wait.wait_for_page_ready()

    def get_gc_content(self) -> str:
        if self.is_element_displayed(self.GC_PERCENT_LABEL, timeout=5):
            return self.get_text(self.GC_PERCENT_LABEL)
        return ""
