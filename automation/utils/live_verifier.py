"""Deployment availability and live asset verification utility."""

import time
import requests
from typing import Dict, Any, List
from urllib.parse import urljoin
from bs4 import BeautifulSoup
from automation.config.config import config
from automation.utils.logger import logger


class LiveDeploymentVerifier:
    def __init__(self, base_url: str = None, timeout: int = 20):
        self.base_url = (base_url or config.base_url).rstrip("/")
        self.timeout = timeout

    def verify_all(self) -> Dict[str, Any]:
        """Perform comprehensive live deployment verification."""
        logger.info(f"🔍 Verifying LIVE deployment at: {self.base_url}")
        
        diagnostics = {
            "base_url": self.base_url,
            "status": "PASS",
            "http_status": None,
            "response_time_ms": None,
            "css_assets_verified": 0,
            "js_assets_verified": 0,
            "broken_assets": [],
            "dom_rendered": False,
            "errors": [],
        }

        # 1. Verify HTTP 200 on Main URL
        start_t = time.perf_counter()
        try:
            resp = requests.get(self.base_url, timeout=self.timeout, allow_redirects=True)
            elapsed_ms = (time.perf_counter() - start_t) * 1000.0
            diagnostics["http_status"] = resp.status_code
            diagnostics["response_time_ms"] = round(elapsed_ms, 2)

            if resp.status_code != 200:
                diagnostics["status"] = "FAIL"
                diagnostics["errors"].append(f"HTTP Status {resp.status_code} received instead of 200")
                return diagnostics
        except Exception as e:
            diagnostics["status"] = "FAIL"
            diagnostics["errors"].append(f"Connection failed: {str(e)}")
            return diagnostics

        html_content = resp.text
        diagnostics["dom_rendered"] = len(html_content) > 100

        # 2. Parse HTML and verify sub-resources (CSS & JS)
        try:
            soup = BeautifulSoup(html_content, "html.parser")
            
            # CSS links
            css_links = [link.get("href") for link in soup.find_all("link", rel="stylesheet") if link.get("href")]
            for css in css_links:
                full_css_url = urljoin(self.base_url + "/", css)
                try:
                    css_resp = requests.get(full_css_url, timeout=10)
                    if css_resp.status_code == 200:
                        diagnostics["css_assets_verified"] += 1
                    else:
                        diagnostics["broken_assets"].append(f"CSS ({css_resp.status_code}): {full_css_url}")
                except Exception as ex:
                    diagnostics["broken_assets"].append(f"CSS (Error): {full_css_url} - {ex}")

            # Script tags
            script_srcs = [s.get("src") for s in soup.find_all("script") if s.get("src")]
            for js in script_srcs:
                full_js_url = urljoin(self.base_url + "/", js)
                try:
                    js_resp = requests.get(full_js_url, timeout=10)
                    if js_resp.status_code == 200:
                        diagnostics["js_assets_verified"] += 1
                    else:
                        diagnostics["broken_assets"].append(f"JS ({js_resp.status_code}): {full_js_url}")
                except Exception as ex:
                    diagnostics["broken_assets"].append(f"JS (Error): {full_js_url} - {ex}")

        except Exception as ex:
            logger.warning(f"Resource parser note: {ex}")

        if diagnostics["broken_assets"]:
            diagnostics["status"] = "WARN" if diagnostics["http_status"] == 200 else "FAIL"

        logger.info(
            f"✅ Deployment Verification: Status={diagnostics['status']}, "
            f"HTTP={diagnostics['http_status']} in {diagnostics['response_time_ms']}ms, "
            f"CSS={diagnostics['css_assets_verified']}, JS={diagnostics['js_assets_verified']}"
        )
        return diagnostics
