#!/usr/bin/env python3
"""Entry point: run CRISPR-Sim E2E suite and write Excel report."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Allow running from repo root or e2e/
sys.path.insert(0, str(Path(__file__).resolve().parent))

from runner import run_e2e_suite
from test_catalog import TEST_CASES


def main() -> int:
    parser = argparse.ArgumentParser(description="CRISPR-Sim Selenium + API E2E tests")
    parser.add_argument(
        "--output-dir",
        default=str(Path(__file__).resolve().parent / "reports"),
        help="Directory for .xlsx report",
    )
    parser.add_argument(
        "--base-url",
        default=None,
        help="API base URL (overrides E2E_BASE_URL / auto-detect)",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List test case count and exit",
    )
    args = parser.parse_args()

    if args.list:
        print(f"Total test cases: {len(TEST_CASES)}")
        modules = {}
        for t in TEST_CASES:
            modules[t.module] = modules.get(t.module, 0) + 1
        for m, c in sorted(modules.items()):
            print(f"  {m}: {c}")
        return 0

    if args.base_url:
        import os
        os.environ["E2E_BASE_URL"] = args.base_url.rstrip("/")

    print(f"Running {len(TEST_CASES)} E2E test cases...")
    results, report_path = run_e2e_suite(output_dir=args.output_dir)

    passed = sum(1 for r in results if r.status == "PASS")
    failed = sum(1 for r in results if r.status == "FAIL")
    skipped = sum(1 for r in results if r.status == "SKIP")
    print(f"\nResults: {passed} passed, {failed} failed, {skipped} skipped")
    print(f"Report: {report_path}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
