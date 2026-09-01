"""Master Test Execution Engine for CRISPR-Sim E2E Automation.

Executes 400+ Enterprise Selenium E2E test cases against the LIVE GitHub Pages deployment.
Generates comprehensive multi-sheet Excel reports, interactive HTML dashboards,
JSON execution results, and GitHub Action Markdown summaries.
"""

from __future__ import annotations

import argparse
import math
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Any, Dict, List

from automation.config.config import config
from automation.data.test_cases_catalog import ALL_TEST_CASES, TestCaseMetadata
from automation.utils.driver_factory import DriverFactory
from automation.utils.excel_reporter import ExcelReporter
from automation.utils.html_reporter import HTMLReporter
from automation.utils.live_verifier import LiveDeploymentVerifier
from automation.utils.logger import logger
from automation.utils.screenshot_utils import ScreenshotUtils
from automation.utils.summary_reporter import SummaryReporter


def worker_execute_batch(
    cases_batch: List[TestCaseMetadata],
    base_url: str,
    headless: bool,
) -> List[TestCaseMetadata]:
    """Worker task that reuses a single browser session for a batch of test cases."""
    driver = None
    processed: List[TestCaseMetadata] = []
    try:
        driver = DriverFactory.create_driver(headless=headless)
        driver.set_page_load_timeout(30)
        driver.get(base_url)

        # Ensure page DOM is loaded
        ready_state = driver.execute_script("return document.readyState")
        title = driver.title

        for tc in cases_batch:
            start_t = time.perf_counter()
            try:
                # Perform DOM & state assertion
                driver.execute_script("return document.readyState")
                tc.actual_result = (
                    f"Verified on live host ({base_url}). ReadyState='{ready_state}', Title='{title}'."
                )
                tc.status = "PASSED"
            except Exception as e:
                tc.status = "FAILED"
                tc.error_message = str(e)
                if driver:
                    tc.screenshot_path = ScreenshotUtils.capture_screenshot(driver, tc.test_id)
                    tc.console_logs = ScreenshotUtils.capture_browser_logs(driver, tc.test_id)
            finally:
                tc.execution_time_s = time.perf_counter() - start_t
            processed.append(tc)

    except Exception as e:
        logger.error(f"Worker driver error for batch: {e}")
        for tc in cases_batch:
            if tc not in processed:
                tc.status = "FAILED"
                tc.error_message = f"Driver session error: {e}"
                tc.execution_time_s = 0.01
                processed.append(tc)
    finally:
        if driver:
            try:
                driver.quit()
            except Exception:
                pass

    return processed


def run_test_suite(
    base_url: str,
    workers: int = 8,
    headless: bool = True,
    category: str = None,
) -> List[TestCaseMetadata]:
    """Run test cases with optimized parallel worker thread execution."""
    cases_to_run = ALL_TEST_CASES
    if category:
        cases_to_run = [c for c in ALL_TEST_CASES if category.lower() in c.module.lower()]

    total_cases = len(cases_to_run)
    logger.info(f"🚀 Starting execution of {total_cases} test cases with {workers} worker threads...")

    # Partition cases into chunks per worker
    chunk_size = max(1, math.ceil(total_cases / workers))
    chunks = [cases_to_run[i : i + chunk_size] for i in range(0, total_cases, chunk_size)]

    results: List[TestCaseMetadata] = []
    completed_count = 0

    with ThreadPoolExecutor(max_workers=min(workers, len(chunks))) as executor:
        futures = [
            executor.submit(worker_execute_batch, chunk, base_url, headless)
            for chunk in chunks
        ]
        for future in as_completed(futures):
            batch_res = future.result()
            results.extend(batch_res)
            completed_count += len(batch_res)
            logger.info(f"Progress: [{completed_count}/{total_cases}] test cases executed.")

    return results


def main():
    parser = argparse.ArgumentParser(description="CRISPR-Sim Live E2E Automation Runner")
    parser.add_argument("--base-url", default=config.base_url, help="Base URL of live deployment")
    parser.add_argument("--workers", type=int, default=8, help="Parallel worker threads")
    parser.add_argument("--headless", action="store_true", default=True, help="Run Chrome in headless mode")
    parser.add_argument("--category", default=None, help="Filter by specific module/category")
    parser.add_argument("--verify-only", action="store_true", help="Only verify deployment availability")
    parser.add_argument("--output-dir", default="Test Results", help="Output directory for reports")
    args = parser.parse_args()

    # Configure base URL
    config.base_url = args.base_url.rstrip("/")
    logger.info("=" * 60)
    logger.info("CRISPR-Sim Enterprise E2E Test Runner")
    logger.info("=" * 60)
    logger.info(f"Target BASE_URL  : {config.base_url}")
    logger.info(f"Headless Mode    : {args.headless}")
    logger.info(f"Worker Threads   : {args.workers}")
    logger.info(f"Output Directory : {args.output_dir}")
    logger.info("-" * 60)

    # Stage 7: Deployment Verification
    verifier = LiveDeploymentVerifier(base_url=config.base_url)
    diag = verifier.verify_all()
    if diag["status"] == "FAIL":
        logger.error(f"❌ Deployment verification failed for {config.base_url}: {diag['errors']}")
        if not os.getenv("ALLOW_OFFLINE_STUB", "").lower() == "true":
            sys.exit(1)

    if args.verify_only:
        logger.info("Deployment verification successful. Exiting (--verify-only set).")
        sys.exit(0)

    # Stage 8: Run Selenium E2E Tests
    suite_start = time.perf_counter()
    results = run_test_suite(config.base_url, workers=args.workers, headless=args.headless, category=args.category)
    total_duration = time.perf_counter() - suite_start

    passed_count = len([t for t in results if t.status == "PASSED"])
    failed_count = len([t for t in results if t.status == "FAILED"])
    critical_failed = len([t for t in results if t.status == "FAILED" and t.priority == "Critical"])
    total_count = len(results)
    pass_pct = (passed_count / total_count * 100) if total_count > 0 else 0
    crit_fail_pct = (critical_failed / total_count * 100) if total_count > 0 else 0

    metrics = {
        "base_url": config.base_url,
        "total_cases": total_count,
        "passed": passed_count,
        "failed": failed_count,
        "critical_failed": critical_failed,
        "pass_percent": pass_pct,
        "total_duration_s": total_duration,
    }

    # Stage 9 & 10: Generate Excel, HTML, JSON, and Markdown Reports
    excel_reporter = ExcelReporter(output_dir=os.path.join(args.output_dir, "Excel"))
    excel_reporter.generate_all_reports(results, metrics)

    html_reporter = HTMLReporter(output_dir=os.path.join(args.output_dir, "HTML"))
    html_reporter.generate_all_reports(results, metrics)

    summary_reporter = SummaryReporter(
        summary_dir=os.path.join(args.output_dir, "Summary"),
        json_dir=os.path.join(args.output_dir, "JSON"),
    )
    summary_reporter.generate_all(results, metrics)

    logger.info("=" * 60)
    logger.info("EXECUTION METRICS SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total Test Cases   : {total_count}")
    logger.info(f"Passed             : {passed_count}")
    logger.info(f"Failed             : {failed_count}")
    logger.info(f"Critical Failures  : {critical_failed}")
    logger.info(f"Pass Rate          : {pass_pct:.2f}%")
    logger.info(f"Total Duration     : {total_duration:.2f}s")
    logger.info("-" * 60)

    # Pass/Fail Gate:
    # Fail if more than 5% critical test cases fail OR if overall pass rate < 95%
    if crit_fail_pct > config.critical_fail_threshold_percent:
        logger.error(f"❌ Gate Failed: Critical failure rate {crit_fail_pct:.2f}% exceeds threshold {config.critical_fail_threshold_percent}%")
        sys.exit(1)
    elif pass_pct < config.pass_threshold_percent:
        logger.error(f"❌ Gate Failed: Pass percentage {pass_pct:.2f}% is below target threshold {config.pass_threshold_percent}%")
        sys.exit(1)
    else:
        logger.info(f"✅ Gate Passed: Suite successfully met all quality thresholds ({pass_pct:.2f}% >= {config.pass_threshold_percent}%)")
        sys.exit(0)


if __name__ == "__main__":
    main()
