# 🧬 CRISPR-Sim Enterprise Live E2E Automation Framework

An enterprise-grade, Page Object Model (POM) based Selenium WebDriver automation framework designed to execute **400+ E2E test cases** against the **LIVE GitHub Pages deployment** in CI/CD.

---

## 📂 Framework Architecture & Folder Structure

```
automation/
├── config/
│   ├── __init__.py
│   └── config.py               # Environment configuration & BASE_URL resolution
├── data/
│   ├── __init__.py
│   ├── test_data.py            # Reusable DNA sequences, users, payloads
│   └── test_cases_catalog.py   # Master metadata catalog for 440 test cases
├── pages/                      # Page Object Model (POM)
│   ├── __init__.py
│   ├── base_page.py            # Base POM with explicit waits, JS execution & scrolling
│   ├── login_page.py           # Authentication & login interactions
│   ├── registration_page.py    # Account creation POM
│   ├── navigation_bar.py       # Global app navigation
│   ├── sequence_input_page.py  # DNA paste, FASTA upload, NCBI fetch
│   ├── pam_scanner_page.py     # PAM site scanning & Cas system selection
│   ├── cut_repair_page.py      # Cut simulation, NHEJ/HDR repair, mutation analysis
│   └── history_page.py         # Session history & CRUD
├── utils/
│   ├── __init__.py
│   ├── driver_factory.py       # Headless Chrome initialization with CI/CD flags
│   ├── wait_utils.py           # Explicit wait wrappers (presence, visibility, clickability)
│   ├── screenshot_utils.py     # Automated screenshot capture & console logs on failure
│   ├── live_verifier.py        # Live deployment availability, HTTP 200, CSS/JS verifier
│   ├── excel_reporter.py       # Multi-sheet Excel workbook generator (openpyxl)
│   ├── html_reporter.py        # Modern interactive HTML dashboard & execution report
│   ├── summary_reporter.py     # GitHub Actions Step Summary & JSON reporter
│   └── logger.py               # Structured thread-safe logger
├── tests/                      # Pytest executable test suites
│   ├── __init__.py
│   ├── conftest.py             # Fixtures, hooks & screenshot listeners
│   ├── test_01_authentication.py   # 40 Test Cases (AUTH-001 to AUTH-040)
│   ├── test_02_authorization.py     # 40 Test Cases (AUTHZ-001 to AUTHZ-040)
│   ├── test_03_navigation.py        # 30 Test Cases (NAV-001 to NAV-030)
│   ├── test_04_ui_validation.py     # 50 Test Cases (UIV-001 to UIV-050)
│   ├── test_05_forms.py             # 50 Test Cases (FORM-001 to FORM-050)
│   ├── test_06_crud_operations.py   # 50 Test Cases (CRUD-001 to CRUD-050)
│   ├── test_07_input_validation.py  # 40 Test Cases (INP-001 to INP-040)
│   ├── test_08_error_handling.py    # 20 Test Cases (ERR-001 to ERR-020)
│   ├── test_09_session_management.py # 20 Test Cases (SESS-001 to SESS-020)
│   ├── test_10_file_upload.py       # 20 Test Cases (UPL-001 to UPL-020)
│   ├── test_11_accessibility.py     # 20 Test Cases (A11Y-001 to A11Y-020)
│   ├── test_12_responsive_design.py # 20 Test Cases (RESP-001 to RESP-020)
│   ├── test_13_performance_smoke.py # 20 Test Cases (PERF-001 to PERF-020)
│   └── test_14_regression.py        # 50 Test Cases (REGR-001 to REGR-050)
├── runner.py                   # Master CLI execution engine with parallel threads
└── requirements.txt            # Python dependencies
```

---

## 📊 Test Distribution (440 Total Test Cases)

| Category | Module | Test Cases | Priorities |
| :--- | :--- | :---: | :--- |
| **01** | Authentication | **40** | Critical (10), High (15), Medium (15) |
| **02** | Authorization | **40** | Critical (10), High (15), Medium (15) |
| **03** | Navigation | **30** | High (10), Medium (20) |
| **04** | UI Validation | **50** | Medium (50) |
| **05** | Forms | **50** | High (15), Medium (35) |
| **06** | CRUD Operations | **50** | Critical (15), High (35) |
| **07** | Input Validation | **40** | High (40) |
| **08** | Error Handling | **20** | High (20) |
| **09** | Session Management | **20** | High (20) |
| **10** | File Upload | **20** | Medium (20) |
| **11** | Accessibility (A11Y) | **20** | Medium (20) |
| **12** | Responsive Design | **20** | Medium (20) |
| **13** | Performance Smoke | **20** | High (20) |
| **14** | Regression Suite | **50** | Critical (15), High (35) |
| **TOTAL** | **Full Catalog** | **440+** | **400+ Target Met** |

---

## 🚀 Local Execution Guide

### 1. Install Dependencies
```bash
pip install -r automation/requirements.txt
```

### 2. Run Full E2E Suite Against Live URL
```bash
python -m automation.runner --base-url "https://vskanna0510.github.io/crispr-sim-app" --workers 8 --headless
```

### 3. Run Pytest Directly with Markers
```bash
# Run only authentication tests in parallel
pytest automation/tests/test_01_authentication.py -n 4 -v

# Run only regression tests
pytest automation/tests/test_14_regression.py -v
```

### 4. Verify Live Deployment Only
```bash
python -m automation.runner --base-url "https://vskanna0510.github.io/crispr-sim-app" --verify-only
```

---

## ⚙️ CI/CD Pipeline Stages (`deploy-and-test.yml`)

The workflow `.github/workflows/deploy-and-test.yml` executes 13 distinct stages on every push and pull request:

```
[Stage 1: Checkout] ➔ [Stage 2: Dependencies] ➔ [Stage 3: Build App] ➔ [Stage 4: Static Analysis]
                                                                               │
[Stage 8: Selenium Live E2E]  [Stage 7: Verify Live]  [Stage 6: Wait Deploy]  [Stage 5: GitHub Pages]
         │
         ▼
[Stage 9: HTML Reports] ➔ [Stage 10: Excel Reports] ➔ [Stage 11: Upload Artifacts] ➔ [Stage 12: Summary] ➔ [Stage 13: History]
```

### GitHub Repository Settings Required:
1. **GitHub Pages Source**:
   - Go to **Settings** ➔ **Pages**.
   - Under **Build and deployment > Source**, select **GitHub Actions**.
2. **Repository Actions Permissions**:
   - Go to **Settings** ➔ **Actions > General**.
   - Ensure **Workflow permissions** is set to **Read and write permissions**.
3. **Configuring `BASE_URL` (Optional)**:
   - Go to **Settings** ➔ **Secrets and variables > Actions > Variables**.
   - Add variable `BASE_URL` = `https://<username>.github.io/<repository-name>`.

---

## 📈 Pass / Fail Quality Gate

The pipeline evaluates:
- **Deployment Gate**: Fails immediately if the deployment URL is unreachable or assets fail to load.
- **Critical Failure Gate**: Fails if **> 5%** of Critical priority test cases fail.
- **Quality SLA Gate**: Fails if the overall pass rate is **< 95%**.
- **Success Condition**: Deployment succeeds **AND** Pass Rate **≥ 95%**.

---

## 📦 Generated Artifacts

On completion of every execution, the following artifacts are stored in `Test Results/` and uploaded to GitHub Actions:
- `Automation_Test_Report.xlsx` (6 sheets: Executed Cases, Passed Tests, Failed Tests, Skipped Tests, Execution Metrics, Defect Summary)
- `Failed_Test_Cases.xlsx`
- `Passed_Test_Cases.xlsx`
- `Summary_Report.xlsx`
- `execution-report.html` & `dashboard.html` (Interactive KPI cards, Donut/Bar charts, filterable table)
- `execution-results.json`
- `summary.md` (Published to GitHub Actions step summary)
- `Screenshots/` (Failure captures)
- `Logs/` (Detailed diagnostic logs)
