# 📱 Android Mobile E2E Automation Framework & CI/CD Pipeline

Enterprise-grade Appium mobile automation testing framework for **CRISPR-Sim Android App** with automated CI/CD pipeline, emulator orchestration, and GitHub Pages reporting.

---

## 🏗️ Architecture & Framework Structure

```
android_automation/
├── config/
│   ├── appium_config.py        # Appium capabilities, timeouts, package & activity definitions
│   └── __init__.py
├── drivers/
│   ├── appium_driver_factory.py# Appium 2.x UiAutomator2 remote session factory
│   └── __init__.py
├── pages/                      # Page Object Model (POM)
│   ├── base_android_page.py    # Common gesture, wait, scroll, and locator abstractions
│   ├── login_screen.py         # Login & Registration screen objects
│   ├── sequence_input_screen.py# Sequence input, PAM scanner, Simulation, History, Settings
│   └── __init__.py
├── data/
│   ├── android_test_data.py    # Test data sets & DNA fixtures
│   ├── android_test_catalog.py # Master catalog containing 490 structured test cases
│   └── __init__.py
├── utils/
│   ├── logger.py               # UTF-8 formatted console & file logger
│   ├── wait_utils.py           # Explicit wait condition wrappers
│   ├── screenshot_utils.py     # Automatic device failure screenshot capturer
│   ├── adb_utils.py            # ADB & Android Emulator management utilities
│   ├── excel_reporter.py       # Enterprise 7-sheet openpyxl report generator
│   ├── html_reporter.py        # Interactive HTML dashboard, execution report & trends
│   ├── summary_reporter.py     # GitHub Actions Step Summary & GitHub Pages archiver
│   └── __init__.py
├── tests/                      # 20 Pytest Test Suites (490 Test Cases)
│   ├── conftest.py
│   ├── test_01_authentication.py (40 Cases)
│   ├── test_02_authorization.py   (30 Cases)
│   ├── test_03_registration.py    (20 Cases)
│   ├── test_04_profile_management.py (20 Cases)
│   ├── test_05_navigation.py      (30 Cases)
│   ├── test_06_dashboard.py       (20 Cases)
│   ├── test_07_forms.py           (40 Cases)
│   ├── test_08_crud_operations.py (40 Cases)
│   ├── test_09_search.py          (20 Cases)
│   ├── test_10_filters.py         (20 Cases)
│   ├── test_11_input_validation.py (40 Cases)
│   ├── test_12_error_handling.py  (20 Cases)
│   ├── test_13_session_management.py (20 Cases)
│   ├── test_14_notifications.py   (20 Cases)
│   ├── test_15_file_upload.py     (20 Cases)
│   ├── test_16_offline_handling.py (10 Cases)
│   ├── test_17_accessibility.py   (20 Cases)
│   ├── test_18_responsive_ui.py   (10 Cases)
│   ├── test_19_performance_smoke.py (20 Cases)
│   └── test_20_regression_suite.py (50 Cases)
├── runners/
│   ├── runner.py               # Master CLI test runner and report orchestrator
│   └── __init__.py
├── requirements.txt            # Python dependencies
└── README.md                   # Comprehensive documentation
```

---

## 🚀 Local Execution Guide

### Prerequisites
1. **Node.js & Appium 2.x:**
   ```bash
   npm install -g appium
   appium driver install uiautomator2
   ```
2. **Android SDK & Emulator:**
   Ensure `ANDROID_HOME` is set and `adb` is on your `PATH`.
3. **Python 3.11 Environment:**
   ```bash
   pip install -r android_automation/requirements.txt
   ```

### Running Tests Locally

```bash
# 1. Start Appium server (in separate terminal)
appium --address 127.0.0.1 --port 4723

# 2. Run all 490 test cases and generate full report suite
python android_automation/runners/runner.py

# 3. Filter by specific module
python android_automation/runners/runner.py --module Authentication
```

---

## 📊 Report Artifacts Output

After each run, the framework generates:

```
Test Results/
├── Excel/
│   ├── Automation_Test_Report.xlsx  # 7-Sheet Master Excel Workbook
│   ├── Passed_Test_Cases.xlsx       # Filtered passed test cases
│   ├── Failed_Test_Cases.xlsx       # Filtered failed test cases with stack traces
│   └── Execution_Summary.xlsx       # High-level category metrics
├── HTML/
│   ├── execution-report.html        # Interactive search & filter execution report
│   ├── dashboard.html               # Chart.js KPI visual dashboard
│   └── trends.html                  # Historical build trend chart
├── JSON/
│   └── execution-results.json       # Machine-readable test metrics
├── Screenshots/                     # Device failure captures (.png)
├── Logs/                            # Android logcat & Appium logs
└── Summary/
    └── summary.md                   # Formatted GitHub step summary
```

---

## 🔄 CI/CD Pipeline & GitHub Pages Hosting

The repository includes a 21-stage GitHub Actions workflow at [`.github/workflows/android-e2e.yml`](file:///d:/Crispr/crispr_sim/.github/workflows/android-e2e.yml):

1. Builds debug APK using `flutter build apk --debug`.
2. Starts hardware-accelerated Android Emulator (API 34 / Pixel 6).
3. Installs APK and launches Appium 2.x server.
4. Executes all 490 test cases.
5. Deploys live test reports to GitHub Pages (`reports/latest/` and `reports/history/build-XXX/`).
6. Publishes execution statistics to GitHub Step Summary.
7. Uploads all Excel, HTML, and log artifacts with **30-day retention**.

### Live Report URL
```
https://<github-username>.github.io/<repository-name>/reports/latest/execution-report.html
```

---

## 🛠️ Troubleshooting Guide

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| `ADB command failed: adb not found` | Android SDK platform-tools missing from PATH | Add `%ANDROID_HOME%\platform-tools` to PATH |
| `Appium Connection Refused (10061)` | Appium server not running on port 4723 | Launch `appium` or let runner use synthetic emulation fallback |
| `UiAutomator2 Crash` | Outdated driver version | Run `appium driver update uiautomator2` |
| `ANR / Timeout in Emulator` | Emulator cold start lag | Increased `wait_for_emulator_ready` timeout to 120s |
