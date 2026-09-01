# CRISPR-Sim E2E Testing (Selenium + API)

Automated end-to-end test suite with **120+ test cases** covering:

- Health & OpenAPI / Swagger UI (Selenium)
- Authentication (register, login, logout, profile)
- Sequence input (paste, upload, NCBI, validation)
- CRISPR simulation (scan, cut, NHEJ, HDR, off-target, safety)
- Translation & mutation analysis
- Settings, history, ratings
- Security & negative tests
- Full pipeline workflows

## Setup

```powershell
cd d:\Crispr\crispr_sim\e2e
python -m pip install -r requirements.txt
```

Requires **Google Chrome** (ChromeDriver is installed automatically via `webdriver-manager`).

## Run tests & generate Excel report

```powershell
cd d:\Crispr\crispr_sim\e2e
python run_e2e.py
```

Report saved to:

`e2e/reports/E2E_Test_Report_CRISPR-Sim_<timestamp>.xlsx`

Sheets: **Summary**, **Test Results**, **Failed Tests**

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `E2E_BASE_URL` | `https://crispr-sim-backend.onrender.com` | FastAPI backend |
| `E2E_APP_URL` | *(empty)* | Flutter web URL for UI tests (optional) |
| `E2E_HEADLESS` | `true` | Set `false` to show Chrome |
| `E2E_ENV` | `Production` | Shown on Summary sheet |

### Local backend

```powershell
$env:E2E_BASE_URL = "http://localhost:8000"
$env:E2E_ENV = "Local"
python run_e2e.py
```

### Flutter web UI tests (optional)

```powershell
# Terminal 1 — serve web build
cd d:\Crispr\crispr_sim\frontend\flutter_app
flutter build web --dart-define=API_BASE_URL=http://localhost:8000
python -m http.server 8080 --directory build/web

# Terminal 2 — run E2E with app URL
cd d:\Crispr\crispr_sim\e2e
$env:E2E_APP_URL = "http://localhost:8080"
python run_e2e.py
```

## Pytest alternative

```powershell
cd d:\Crispr\crispr_sim\e2e
pytest test_e2e.py -v --tb=short
```

Generate report after pytest by running `python run_e2e.py` (includes xlsx export).

## List test cases

```powershell
python run_e2e.py --list
```
