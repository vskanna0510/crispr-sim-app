"""Configuration management for Selenium E2E Automation."""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class AutomationConfig:
    # BASE_URL must point to the LIVE deployment URL (e.g. GitHub Pages or production web app)
    base_url: str = os.getenv(
        "BASE_URL",
        "https://vskanna0510.github.io/crispr-sim-app",
    ).rstrip("/")
    
    # Timeouts & Retries
    page_load_timeout: int = int(os.getenv("PAGE_LOAD_TIMEOUT", "30"))
    implicit_wait: int = int(os.getenv("IMPLICIT_WAIT", "10"))
    explicit_wait: int = int(os.getenv("EXPLICIT_WAIT", "15"))
    retry_count: int = int(os.getenv("RETRY_COUNT", "2"))
    
    # Browser flags
    headless: bool = os.getenv("HEADLESS", "true").lower() == "true"
    browser_width: int = int(os.getenv("BROWSER_WIDTH", "1920"))
    browser_height: int = int(os.getenv("BROWSER_HEIGHT", "1080"))
    
    # Output paths
    output_dir: str = os.getenv("TEST_RESULTS_DIR", "Test Results")
    screenshots_dir: str = os.path.join(output_dir, "Screenshots")
    logs_dir: str = os.path.join(output_dir, "Logs")
    excel_dir: str = os.path.join(output_dir, "Excel")
    html_dir: str = os.path.join(output_dir, "HTML")
    json_dir: str = os.path.join(output_dir, "JSON")
    summary_dir: str = os.path.join(output_dir, "Summary")
    
    # Thresholds
    pass_threshold_percent: float = float(os.getenv("PASS_THRESHOLD", "95.0"))
    critical_fail_threshold_percent: float = float(os.getenv("CRITICAL_FAIL_THRESHOLD", "5.0"))


# Global singleton instance
config = AutomationConfig()
