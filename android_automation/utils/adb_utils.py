"""Android Debug Bridge (ADB) and Emulator management utilities."""

import os
import subprocess
import time
import requests
from typing import Optional, List, Dict, Any

from android_automation.config.appium_config import config
from android_automation.utils.logger import logger


class ADBUtils:
    @staticmethod
    def run_adb_command(args: List[str], timeout: int = 30) -> str:
        cmd = ["adb"] + args
        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
            return res.stdout.strip()
        except Exception as e:
            logger.warning(f"ADB command failed: {' '.join(cmd)} - {e}")
            return ""

    @classmethod
    def get_connected_devices(cls) -> List[str]:
        output = cls.run_adb_command(["devices"])
        devices = []
        for line in output.splitlines()[1:]:
            if "\tdevice" in line:
                devices.append(line.split("\t")[0])
        return devices

    @classmethod
    def wait_for_emulator_ready(cls, max_wait_seconds: int = 120) -> bool:
        logger.info("⏳ Verifying Android Emulator readiness via ADB...")
        start = time.time()
        while time.time() - start < max_wait_seconds:
            boot_completed = cls.run_adb_command(["shell", "getprop", "sys.boot_completed"])
            if boot_completed == "1":
                logger.info("✅ Android Emulator is fully booted and online.")
                return True
            time.sleep(3)
        logger.warning("Timeout waiting for emulator boot completion.")
        return False

    @classmethod
    def install_apk(cls, apk_path: str = None) -> bool:
        path = apk_path or config.apk_path
        if not os.path.exists(path):
            logger.warning(f"APK not found at path: {path}")
            return False
        logger.info(f"📲 Installing APK: {path}")
        res = cls.run_adb_command(["install", "-r", "-g", path], timeout=60)
        return "Success" in res

    @classmethod
    def capture_logcat(cls, test_id: str) -> str:
        os.makedirs(config.logs_dir, exist_ok=True)
        log_file = os.path.join(config.logs_dir, f"{test_id}_logcat.log")
        output = cls.run_adb_command(["logcat", "-d", "-t", "500"])
        try:
            with open(log_file, "w", encoding="utf-8") as f:
                f.write(output)
            return log_file
        except Exception:
            return ""

    @staticmethod
    def verify_appium_health(appium_url: str = None) -> bool:
        url = (appium_url or config.appium_server_url).rstrip("/") + "/status"
        try:
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                logger.info(f"✅ Appium server is HEALTHY at {url}")
                return True
        except Exception as e:
            logger.warning(f"Appium health check failed at {url}: {e}")
        return False
