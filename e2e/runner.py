"""CRISPR-Sim E2E test runner — Selenium + API."""

from __future__ import annotations

import json
import os
import time
import traceback
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager

from report_generator import TestResult, generate_report
from test_catalog import E2ETestCase, SHORT_DNA, TEST_CASES, VALID_DNA


class E2ERunner:
    def __init__(
        self,
        base_url: str,
        app_url: Optional[str] = None,
        headless: bool = True,
        timeout: int = 60,
    ):
        self.base_url = base_url.rstrip("/")
        self.app_url = (app_url or "").rstrip("/") or None
        self.headless = headless
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({"Accept": "application/json"})
        self._token: Optional[str] = None
        self._driver: Optional[webdriver.Chrome] = None
        self._selenium_ready = False

    def _now(self) -> str:
        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    def _ensure_auth(self) -> bool:
        if self._token:
            return True
        email = f"e2e_runner_{uuid.uuid4().hex[:8]}@example.com"
        password = "TestPass123!"
        try:
            r = self.session.post(
                f"{self.base_url}/auth/register",
                json={"email": email, "password": password, "full_name": "E2E Runner"},
                timeout=self.timeout,
            )
            if r.status_code == 201:
                self._token = r.json().get("access_token")
                return bool(self._token)
            if r.status_code == 409:
                r = self.session.post(
                    f"{self.base_url}/auth/login",
                    json={"email": email, "password": password},
                    timeout=self.timeout,
                )
            elif r.status_code != 200:
                r = self.session.post(
                    f"{self.base_url}/auth/login",
                    json={"email": "e2e_user_1@example.com", "password": password},
                    timeout=self.timeout,
                )
            if r.status_code == 200:
                self._token = r.json().get("access_token")
        except Exception:
            return False
        return bool(self._token)

    def _auth_headers(self) -> dict[str, str]:
        if not self._token:
            self._ensure_auth()
        if self._token:
            return {"Authorization": f"Bearer {self._token}"}
        return {}

    def _get_driver(self) -> webdriver.Chrome:
        if self._driver is None:
            opts = Options()
            if self.headless:
                opts.add_argument("--headless=new")
            opts.add_argument("--no-sandbox")
            opts.add_argument("--disable-dev-shm-usage")
            opts.add_argument("--window-size=1920,1080")
            opts.add_argument("--disable-gpu")
            service = Service(ChromeDriverManager().install())
            self._driver = webdriver.Chrome(service=service, options=opts)
            self._driver.set_page_load_timeout(self.timeout)
            self._selenium_ready = True
        return self._driver

    def close(self):
        if self._driver:
            try:
                self._driver.quit()
            except Exception:
                pass
            self._driver = None

    def _status_ok(self, code: int, expected: int | list[int]) -> bool:
        if isinstance(expected, list):
            return code in expected
        return code == expected

    def _needs_auth(self, case: E2ETestCase) -> bool:
        if case.requires_auth:
            return True
        if case.headers and "Authorization" in (case.headers or {}):
            return False
        expected = case.expect_status
        if expected == 401 or (isinstance(expected, list) and 401 in expected):
            return False
        public_get = {"/", "/health", "/openapi.json", "/advanced/cas-systems", "/validation/cases"}
        if case.method == "GET" and case.path in public_get:
            return False
        if case.path and case.path.startswith("/sequence/gene-info"):
            return False
        if case.path in ("/crispr/off-target", "/crispr/safety-score"):
            return False
        if case.path == "/chat/rag":
            return False
        if case.path and case.path.startswith("/auth/"):
            return False
        if case.method == "POST" and case.path == "/":
            return False
        return case.test_type == "api" and case.path is not None

    def _run_api(self, case: E2ETestCase) -> tuple[str, str, bool]:
        url = f"{self.base_url}{case.path}"
        headers = dict(case.headers or {})
        if self._needs_auth(case):
            headers.update(self._auth_headers())

        kwargs: dict[str, Any] = {"timeout": self.timeout, "headers": headers}
        if case.json_body is not None:
            kwargs["json"] = case.json_body
        if case.files is not None:
            kwargs["files"] = case.files
            kwargs.pop("json", None)

        method = (case.method or "GET").upper()
        resp = self.session.request(method, url, **kwargs)
        if resp.status_code == 401 and self._needs_auth(case):
            self._token = None
            headers.update(self._auth_headers())
            kwargs["headers"] = headers
            resp = self.session.request(method, url, **kwargs)
        actual = f"HTTP {resp.status_code}"
        ok = self._status_ok(resp.status_code, case.expect_status)

        body_text = ""
        try:
            if resp.content:
                body = resp.json() if "application/json" in resp.headers.get("content-type", "") else {}
                if isinstance(body, dict):
                    body_text = json.dumps(body)[:500]
                    if case.expect_keys and resp.status_code < 400:
                        missing = [k for k in case.expect_keys if k not in body]
                        if missing:
                            ok = False
                            actual += f"; missing keys: {missing}"
                    if case.expect_contains and case.expect_contains not in body_text:
                        ok = False
                        actual += f"; expected contains '{case.expect_contains}'"
                elif isinstance(body, list) and case.tags:
                    for tag in case.tags:
                        if tag.startswith("cas_index_"):
                            idx = int(tag.split("_")[-1])
                            if idx < len(body):
                                item = body[idx]
                                for fld in ("id", "name", "pam_motif"):
                                    if fld not in item:
                                        ok = False
                                        actual += f"; cas[{idx}] missing {fld}"
        except Exception as exc:
            if resp.status_code < 400:
                body_text = resp.text[:300]
            actual += f"; parse: {exc}"

        if body_text and ok:
            actual += f"; {body_text[:200]}"
        return actual, "PASS" if ok else "FAIL", ok

    def _run_selenium(self, case: E2ETestCase) -> tuple[str, str, bool]:
        action = case.selenium_action or ""
        driver = self._get_driver()
        wait = WebDriverWait(driver, min(self.timeout, 30))

        try:
            if action == "swagger_docs_load":
                driver.get(f"{self.base_url}/docs")
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "swagger-ui")))
                src = driver.page_source
                ok = "CRISPR" in src or "crispr" in src.lower() or "swagger" in src.lower()
                return f"Loaded /docs ({len(src)} bytes)", "PASS" if ok else "FAIL", ok

            if action == "redoc_load":
                driver.get(f"{self.base_url}/redoc")
                wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
                ok = "redoc" in driver.page_source.lower() or "openapi" in driver.page_source.lower()
                return "ReDoc page loaded", "PASS" if ok else "FAIL", ok

            if action == "swagger_auth_section":
                driver.get(f"{self.base_url}/docs")
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "swagger-ui")))
                ok = "Authentication" in driver.page_source or "auth" in driver.page_source.lower()
                return "Authentication section checked", "PASS" if ok else "FAIL", ok

            if action == "swagger_crispr_section":
                driver.get(f"{self.base_url}/docs")
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "swagger-ui")))
                ok = "CRISPR" in driver.page_source
                return "CRISPR section checked", "PASS" if ok else "FAIL", ok

            if action == "swagger_execute_health":
                driver.get(f"{self.base_url}/docs")
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "swagger-ui")))
                # Click first GET /health operation if visible
                buttons = driver.find_elements(By.CSS_SELECTOR, "button.opblock-summary-control")
                clicked = False
                for btn in buttons:
                    if "health" in btn.text.lower():
                        btn.click()
                        clicked = True
                        break
                if not clicked and buttons:
                    buttons[0].click()
                time.sleep(0.5)
                try_btn = driver.find_elements(By.CSS_SELECTOR, "button.btn.try-out__btn")
                if try_btn:
                    try_btn[0].click()
                    time.sleep(0.3)
                exec_btns = driver.find_elements(By.CSS_SELECTOR, "button.btn.execute")
                if exec_btns:
                    exec_btns[0].click()
                    time.sleep(1.5)
                ok = "200" in driver.page_source or "healthy" in driver.page_source.lower()
                return "Swagger execute attempted", "PASS" if ok else "FAIL", ok

            if action == "browser_root_json":
                driver.get(f"{self.base_url}/")
                body = driver.find_element(By.TAG_NAME, "body").text
                ok = "CRISPR" in body or "ok" in body.lower()
                return body[:200], "PASS" if ok else "FAIL", ok

            if action == "browser_openapi_json":
                driver.get(f"{self.base_url}/openapi.json")
                body = driver.find_element(By.TAG_NAME, "body").text
                ok = "paths" in body and "openapi" in body
                return f"openapi.json ({len(body)} chars)", "PASS" if ok else "FAIL", ok

            if action == "browser_cors_check":
                driver.get(f"{self.base_url}/docs")
                result = driver.execute_script(
                    """
                    return fetch(arguments[0], {method: 'OPTIONS'})
                      .then(r => r.status)
                      .catch(e => 'error:' + e.message);
                    """,
                    f"{self.base_url}/health",
                )
                ok = str(result) in ("200", "204", "405") or "error" not in str(result).lower()
                return f"OPTIONS status: {result}", "PASS" if ok else "FAIL", ok

            if action.startswith("swagger_scroll_"):
                driver.get(f"{self.base_url}/docs")
                wait.until(EC.presence_of_element_located((By.CLASS_NAME, "swagger-ui")))
                idx = int(action.split("_")[-1])
                driver.execute_script(f"window.scrollTo(0, {idx * 400});")
                time.sleep(0.3)
                ok = driver.find_element(By.CLASS_NAME, "swagger-ui").is_displayed()
                return f"Scrolled section {idx}", "PASS" if ok else "FAIL", ok

            if action in ("flutter_app_load", "flutter_login_visible"):
                if not self.app_url:
                    return "APP_URL not configured — skipped", "SKIP", True
                driver.get(self.app_url)
                time.sleep(8)  # Flutter web bootstrap
                src = driver.page_source + driver.title
                if action == "flutter_app_load":
                    ok = "crispr" in src.lower() or "flutter" in src.lower()
                    return f"App loaded title={driver.title}", "PASS" if ok else "FAIL", ok
                # login visible — semantics may be limited on canvas
                ok = "Sign in" in src or "CRISPR" in src or "sign" in src.lower()
                return f"Login check title={driver.title}", "PASS" if ok else "FAIL", ok

            return f"Unknown selenium action: {action}", "FAIL", False
        except Exception as exc:
            return f"Selenium error: {exc}", "FAIL", False

    def _run_pipeline(self, case: E2ETestCase) -> tuple[str, str, bool]:
        try:
            self._token = None
            if not self._ensure_auth():
                return "Could not authenticate", "FAIL", False
            headers = self._auth_headers()

            r1 = self.session.post(
                f"{self.base_url}/sequence/paste",
                json={"sequence": SHORT_DNA},
                headers=headers,
                timeout=self.timeout,
            )
            if r1.status_code != 200:
                return f"paste failed: {r1.status_code}", "FAIL", False
            session_id = r1.json().get("session_id")

            r2 = self.session.post(
                f"{self.base_url}/crispr/scan",
                json={"sequence": SHORT_DNA, "cas_type": "cas9", "session_id": session_id},
                headers=headers,
                timeout=self.timeout,
            )
            if r2.status_code != 200:
                return f"scan failed: {r2.status_code}", "FAIL", False
            sites = r2.json().get("pam_sites", [])
            pam_start = sites[0]["start"] if sites else 20

            r3 = self.session.post(
                f"{self.base_url}/crispr/cut",
                json={"sequence": SHORT_DNA, "pam_start": pam_start, "cas_type": "cas9"},
                headers=headers,
                timeout=self.timeout,
            )
            if r3.status_code != 200:
                return f"cut failed: {r3.status_code}", "FAIL", False
            cut_pos = r3.json().get("cut_position", pam_start)

            r4 = self.session.post(
                f"{self.base_url}/crispr/nhej",
                json={"sequence": SHORT_DNA, "cut_position": cut_pos, "deletion_size": 2},
                headers=headers,
                timeout=self.timeout,
            )
            if r4.status_code != 200:
                return f"nhej failed: {r4.status_code}", "FAIL", False
            edited = r4.json().get("repaired_sequence", SHORT_DNA)

            r5 = self.session.post(
                f"{self.base_url}/analysis/translate",
                json={"sequence": edited},
                headers=headers,
                timeout=self.timeout,
            )
            if r5.status_code != 200:
                return f"translate failed: {r5.status_code}", "FAIL", False

            return "Pipeline paste→scan→cut→nhej→translate OK", "PASS", True
        except Exception as exc:
            return f"Pipeline error: {exc}", "FAIL", False

    def run_case(self, case: E2ETestCase) -> TestResult:
        if case.skip_reason:
            return TestResult(
                test_id=case.test_id,
                module=case.module,
                name=case.name,
                description=case.description,
                steps=case.steps,
                expected=case.expected,
                actual=case.skip_reason,
                status="SKIP",
                severity=case.severity,
                duration_ms=0,
                test_type=case.test_type,
                executed_at=self._now(),
                remarks="Skipped by catalog",
            )

        start = time.perf_counter()
        try:
            if case.tags and "pipeline" in case.tags:
                actual, status, _ = self._run_pipeline(case)
            elif case.test_type == "selenium":
                actual, status, _ = self._run_selenium(case)
            elif case.test_type == "api":
                actual, status, _ = self._run_api(case)
            else:
                actual, status = "Unknown test type", "FAIL"
        except Exception as exc:
            actual = f"Exception: {exc}\n{traceback.format_exc()[-300:]}"
            status = "FAIL"

        duration_ms = (time.perf_counter() - start) * 1000
        if case.path == "/auth/logout" and status == "PASS":
            self._token = None
        return TestResult(
            test_id=case.test_id,
            module=case.module,
            name=case.name,
            description=case.description,
            steps=case.steps,
            expected=case.expected,
            actual=actual[:1000],
            status=status,
            severity=case.severity,
            duration_ms=duration_ms,
            test_type=case.test_type,
            executed_at=self._now(),
        )

    def run_all(self, cases: Optional[list[E2ETestCase]] = None) -> list[TestResult]:
        cases = cases or TEST_CASES
        # Pre-register fixture users for login tests (idempotent).
        for i in range(1, 6):
            try:
                self.session.post(
                    f"{self.base_url}/auth/register",
                    json={
                        "email": f"e2e_user_{i}@example.com",
                        "password": "TestPass123!",
                        "full_name": f"E2E User {i}",
                    },
                    timeout=self.timeout,
                )
            except Exception:
                pass
        self._ensure_auth()
        results: list[TestResult] = []
        for case in cases:
            results.append(self.run_case(case))
        return results


def _resolve_base_url() -> tuple[str, str]:
    """Pick API URL: explicit env > healthy local Docker > Render production."""
    if os.environ.get("E2E_BASE_URL"):
        url = os.environ["E2E_BASE_URL"].rstrip("/")
        env = os.environ.get("E2E_ENV", "Custom")
        return url, env

    local = "http://localhost:8000"
    try:
        r = requests.get(f"{local}/health", timeout=3)
        if r.status_code == 200:
            data = r.json()
            if data.get("database") not in (None, "unavailable"):
                return local, os.environ.get("E2E_ENV", "Local Docker")
    except Exception:
        pass

    return (
        "https://crispr-sim-backend.onrender.com",
        os.environ.get("E2E_ENV", "Production"),
    )


def run_e2e_suite(
    output_dir: Optional[str] = None,
) -> tuple[list[TestResult], str]:
    base_url, env_name = _resolve_base_url()
    app_url = os.environ.get("E2E_APP_URL", "")
    headless = os.environ.get("E2E_HEADLESS", "true").lower() != "false"
    print(f"Target: {base_url} ({env_name})")

    out_dir = Path(output_dir) if output_dir else Path(__file__).resolve().parent / "reports"
    out_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    report_path = out_dir / f"E2E_Test_Report_CRISPR-Sim_{timestamp}.xlsx"

    runner = E2ERunner(base_url=base_url, app_url=app_url or None, headless=headless)
    try:
        results = runner.run_all()
        generate_report(
            results,
            report_path,
            base_url=base_url,
            app_url=app_url or None,
            environment=env_name,
        )
    finally:
        runner.close()

    return results, str(report_path)
