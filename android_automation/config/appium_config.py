"""Android Appium Configuration & Capabilities Management."""

import os
from dataclasses import dataclass
from typing import Dict, Any


@dataclass
class AndroidAppiumConfig:
    # Appium Server
    appium_server_url: str = os.getenv("APPIUM_SERVER_URL", "http://127.0.0.1:4723").rstrip("/")
    
    # Device / Emulator Specs
    device_name: str = os.getenv("ANDROID_DEVICE_NAME", "Android Emulator")
    platform_name: str = "Android"
    platform_version: str = os.getenv("ANDROID_PLATFORM_VERSION", "14.0")
    automation_name: str = "UiAutomator2"
    udid: str = os.getenv("ANDROID_UDID", "emulator-5554")
    
    # Target Application
    app_package: str = os.getenv("APP_PACKAGE", "com.crisprsim.crispr_sim")
    app_activity: str = os.getenv("APP_ACTIVITY", ".MainActivity")
    apk_path: str = os.getenv("APK_PATH", "frontend/flutter_app/build/app/outputs/flutter-apk/app-debug.apk")
    
    # Timeouts & Stability
    command_timeout: int = int(os.getenv("APPIUM_COMMAND_TIMEOUT", "120"))
    implicit_wait: int = int(os.getenv("IMPLICIT_WAIT", "10"))
    explicit_wait: int = int(os.getenv("EXPLICIT_WAIT", "15"))
    retry_count: int = int(os.getenv("RETRY_COUNT", "2"))
    
    # Output Directories
    output_dir: str = os.getenv("TEST_RESULTS_DIR", "Test Results")
    excel_dir: str = os.path.join(output_dir, "Excel")
    html_dir: str = os.path.join(output_dir, "HTML")
    json_dir: str = os.path.join(output_dir, "JSON")
    screenshots_dir: str = os.path.join(output_dir, "Screenshots")
    logs_dir: str = os.path.join(output_dir, "Logs")
    summary_dir: str = os.path.join(output_dir, "Summary")
    
    # Quality Thresholds
    pass_threshold_percent: float = float(os.getenv("PASS_THRESHOLD", "95.0"))
    critical_fail_threshold_percent: float = float(os.getenv("CRITICAL_FAIL_THRESHOLD", "5.0"))

    def get_desired_capabilities(self) -> Dict[str, Any]:
        """Return standardized W3C Appium 2.x UiAutomator2 capabilities."""
        caps = {
            "platformName": self.platform_name,
            "appium:automationName": self.automation_name,
            "appium:deviceName": self.device_name,
            "appium:platformVersion": self.platform_version,
            "appium:appPackage": self.app_package,
            "appium:appActivity": self.app_activity,
            "appium:newCommandTimeout": self.command_timeout,
            "appium:autoGrantPermissions": True,
            "appium:noReset": False,
            "appium:fullReset": False,
            "appium:ensureWebviewsHavePages": True,
            "appium:nativeWebScreenshot": True,
            "appium:connectHardwareKeyboard": True,
        }
        if os.path.exists(self.apk_path):
            caps["appium:app"] = os.path.abspath(self.apk_path)
        return caps


config = AndroidAppiumConfig()
