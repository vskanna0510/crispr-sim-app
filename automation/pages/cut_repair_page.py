"""Page Object Models for Cut/Repair, History, Settings, and Accessibility."""

from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage


class CutRepairPage(BasePage):
    CUT_BUTTON = (By.XPATH, "//button[contains(., 'Simulate Cut') or contains(., 'Cut')]")
    NHEJ_RADIO = (By.CSS_SELECTOR, "input[value='nhej'], [data-testid='repair-nhej']")
    HDR_RADIO = (By.CSS_SELECTOR, "input[value='hdr'], [data-testid='repair-hdr']")
    DONOR_INPUT = (By.CSS_SELECTOR, "textarea[name='donor'], input[placeholder*='donor' i]")
    APPLY_REPAIR_BUTTON = (By.XPATH, "//button[contains(., 'Repair') or contains(., 'Apply')]")
    PROTEIN_MUTATION_REPORT = (By.CSS_SELECTOR, ".mutation-analysis, [data-testid='mutation-card']")

    def __init__(self, driver):
        super().__init__(driver, path="/simulation")


class HistoryPage(BasePage):
    SESSION_LIST = (By.CSS_SELECTOR, ".history-item, .session-row, [data-testid='history-row']")
    DELETE_BUTTON = (By.CSS_SELECTOR, ".delete-btn, [data-testid='delete-session']")
    EXPORT_CSV_BUTTON = (By.XPATH, "//button[contains(., 'Export') or contains(., 'CSV')]")

    def __init__(self, driver):
        super().__init__(driver, path="/history")


class SettingsPage(BasePage):
    DARK_MODE_TOGGLE = (By.CSS_SELECTOR, "input[type='checkbox'], .theme-switch, [role='switch']")
    SAVE_HISTORY_CHECKBOX = (By.CSS_SELECTOR, "input[name='save_history']")
    AUTO_RANK_CHECKBOX = (By.CSS_SELECTOR, "input[name='auto_rank']")
    SAVE_BUTTON = (By.XPATH, "//button[contains(., 'Save') or contains(., 'Update')]")

    def __init__(self, driver):
        super().__init__(driver, path="/settings")


class AccessibilityPage(BasePage):
    MAIN_LANDMARK = (By.TAG_NAME, "main")
    HEADINGS = (By.CSS_SELECTOR, "h1, h2, h3, h4, h5, h6")
    BUTTONS = (By.TAG_NAME, "button")
    INPUTS = (By.CSS_SELECTOR, "input, select, textarea")

    def __init__(self, driver):
        super().__init__(driver, path="/")
