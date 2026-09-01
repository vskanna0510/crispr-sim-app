"""Android Mobile Screens: Sequence, PAM Scanner, Simulation, History, Settings."""

from appium.webdriver.common.appiumby import AppiumBy
from android_automation.pages.base_android_page import BaseAndroidPage


class SequenceInputScreen(BaseAndroidPage):
    SEQUENCE_INPUT = (AppiumBy.ACCESSIBILITY_ID, "dna_sequence_input")
    PASTE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "paste_dna_btn")
    UPLOAD_FASTA_BTN = (AppiumBy.ACCESSIBILITY_ID, "upload_fasta_btn")
    SUBMIT_BTN = (AppiumBy.ACCESSIBILITY_ID, "proceed_to_scan_btn")
    GC_PERCENT_BADGE = (AppiumBy.ACCESSIBILITY_ID, "gc_percent_badge")

    def enter_sequence(self, sequence: str):
        if self.is_element_present(self.SEQUENCE_INPUT, timeout=2):
            self.type_text(self.SEQUENCE_INPUT, sequence)

    def submit(self):
        if self.is_element_present(self.SUBMIT_BTN, timeout=2):
            self.click(self.SUBMIT_BTN)


class PamScannerScreen(BaseAndroidPage):
    CAS_SELECT_DROPDOWN = (AppiumBy.ACCESSIBILITY_ID, "cas_select_dropdown")
    SCAN_BTN = (AppiumBy.ACCESSIBILITY_ID, "scan_pam_btn")
    PAM_SITE_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'pam_site_') or contains(@text, 'PAM')]")
    FIRST_CUT_BTN = (AppiumBy.XPATH, "(//*[contains(@text, 'Cut') or contains(@content-desc, 'cut_btn')])[1]")

    def scan(self):
        if self.is_element_present(self.SCAN_BTN, timeout=2):
            self.click(self.SCAN_BTN)


class SimulationScreen(BaseAndroidPage):
    CUT_SIMULATE_BTN = (AppiumBy.ACCESSIBILITY_ID, "simulate_cut_btn")
    NHEJ_OPTION = (AppiumBy.ACCESSIBILITY_ID, "repair_nhej_radio")
    HDR_OPTION = (AppiumBy.ACCESSIBILITY_ID, "repair_hdr_radio")
    DONOR_INPUT = (AppiumBy.ACCESSIBILITY_ID, "donor_template_input")
    APPLY_REPAIR_BTN = (AppiumBy.ACCESSIBILITY_ID, "apply_repair_btn")
    MUTATION_CARD = (AppiumBy.ACCESSIBILITY_ID, "mutation_result_card")


class HistoryScreen(BaseAndroidPage):
    SESSION_ITEM = (AppiumBy.XPATH, "//*[contains(@content-desc, 'session_item_')]")
    CLEAR_ALL_BTN = (AppiumBy.ACCESSIBILITY_ID, "clear_history_btn")


class SettingsScreen(BaseAndroidPage):
    THEME_TOGGLE = (AppiumBy.ACCESSIBILITY_ID, "theme_switch")
    SAVE_HISTORY_SWITCH = (AppiumBy.ACCESSIBILITY_ID, "save_history_switch")
    ANALYTICS_SWITCH = (AppiumBy.ACCESSIBILITY_ID, "analytics_switch")


class RAGChatScreen(BaseAndroidPage):
    CHAT_FAB = (AppiumBy.ACCESSIBILITY_ID, "rag_chat_fab")
    MESSAGE_INPUT = (AppiumBy.ACCESSIBILITY_ID, "chat_message_input")
    SEND_BTN = (AppiumBy.ACCESSIBILITY_ID, "chat_send_btn")
    ASSISTANT_RESPONSE = (AppiumBy.XPATH, "//*[contains(@content-desc, 'assistant_msg_')]")
