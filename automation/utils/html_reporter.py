"""Interactive HTML and Dashboard Report Generator."""

import json
import os
from datetime import datetime
from typing import List, Dict, Any

from automation.config.config import config
from automation.data.test_cases_catalog import TestCaseMetadata
from automation.utils.logger import logger


class HTMLReporter:
    def __init__(self, output_dir: str = None):
        self.output_dir = output_dir or config.html_dir
        os.makedirs(self.output_dir, exist_ok=True)

    def generate_all_reports(self, test_results: List[TestCaseMetadata], metrics: Dict[str, Any]):
        self._generate_dashboard(test_results, metrics)
        self._generate_execution_report(test_results, metrics)
        logger.info(f"🌐 HTML reports generated in: {self.output_dir}")

    def _generate_dashboard(self, test_results: List[TestCaseMetadata], metrics: Dict[str, Any]):
        passed = len([t for t in test_results if t.status == "PASSED"])
        failed = len([t for t in test_results if t.status == "FAILED"])
        skipped = len([t for t in test_results if t.status in ("SKIPPED", "BLOCKED")])
        total = len(test_results)
        pass_pct = (passed / total * 100) if total > 0 else 0

        # Module stats
        modules = sorted(list(set(t.module for t in test_results)))
        module_data = []
        for m in modules:
            m_tests = [t for t in test_results if t.module == m]
            m_pass = len([t for t in m_tests if t.status == "PASSED"])
            m_fail = len([t for t in m_tests if t.status == "FAILED"])
            rate = (m_pass / len(m_tests)) * 100 if m_tests else 0
            module_data.append({"module": m, "total": len(m_tests), "pass": m_pass, "fail": m_fail, "rate": round(rate, 1)})

        html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRISPR-Sim E2E Live Test Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {{
            --bg: #0b0f19;
            --card-bg: rgba(23, 32, 54, 0.7);
            --border: rgba(255, 255, 255, 0.08);
            --primary: #38bdf8;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --text: #f3f4f6;
            --text-muted: #94a3b8;
        }}
        * {{ box-sizing: border-box; margin: 0; padding: 0; font-family: 'Outfit', sans-serif; }}
        body {{ background: var(--bg); color: var(--text); padding: 2rem; }}
        .header {{ display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border); }}
        .header h1 {{ font-size: 1.8rem; background: linear-gradient(135deg, #38bdf8, #818cf8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }}
        .card {{ background: var(--card-bg); backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: 12px; padding: 1.5rem; }}
        .card .title {{ font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; }}
        .card .value {{ font-size: 2.2rem; font-weight: 700; margin-top: 0.5rem; }}
        .val-pass {{ color: var(--success); }}
        .val-fail {{ color: var(--danger); }}
        .val-total {{ color: var(--primary); }}
        .chart-section {{ display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem; margin-bottom: 2rem; }}
        .table-container {{ background: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 1.5rem; overflow-x: auto; }}
        table {{ width: 100%; border-collapse: collapse; text-align: left; font-size: 0.95rem; }}
        th, td {{ padding: 0.85rem 1rem; border-bottom: 1px solid var(--border); }}
        th {{ color: var(--text-muted); font-weight: 600; text-transform: uppercase; font-size: 0.8rem; }}
        .badge {{ padding: 0.25rem 0.6rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }}
        .badge-pass {{ background: rgba(16, 185, 129, 0.2); color: var(--success); }}
        .badge-fail {{ background: rgba(239, 68, 68, 0.2); color: var(--danger); }}
        .badge-prio {{ background: rgba(56, 189, 248, 0.15); color: var(--primary); }}
        input.search {{ width: 100%; padding: 0.75rem 1rem; background: rgba(0,0,0,0.3); border: 1px solid var(--border); border-radius: 8px; color: #fff; margin-bottom: 1rem; outline: none; }}
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>🧬 CRISPR-Sim Enterprise E2E Test Dashboard</h1>
            <p style="color: var(--text-muted); margin-top: 0.25rem;">Live Target: <a href="{metrics.get('base_url', config.base_url)}" style="color: var(--primary); text-decoration: none;" target="_blank">{metrics.get('base_url', config.base_url)}</a></p>
        </div>
        <div style="text-align: right; color: var(--text-muted); font-size: 0.85rem;">
            <div>Executed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</div>
            <div>Duration: {metrics.get('total_duration_s', 0.0):.2f}s</div>
        </div>
    </div>

    <div class="grid">
        <div class="card">
            <div class="title">Total Test Cases</div>
            <div class="value val-total">{total}</div>
        </div>
        <div class="card">
            <div class="title">Passed Tests</div>
            <div class="value val-pass">{passed}</div>
        </div>
        <div class="card">
            <div class="title">Failed Tests</div>
            <div class="value val-fail">{failed}</div>
        </div>
        <div class="card">
            <div class="title">Pass Percentage</div>
            <div class="value" style="color: {'var(--success)' if pass_pct >= 95 else 'var(--danger)'}">{pass_pct:.1f}%</div>
        </div>
    </div>

    <div class="chart-section">
        <div class="card">
            <div class="title" style="margin-bottom: 1rem;">Execution Summary</div>
            <canvas id="donutChart"></canvas>
        </div>
        <div class="card">
            <div class="title" style="margin-bottom: 1rem;">Module Pass Rate (%)</div>
            <canvas id="barChart"></canvas>
        </div>
    </div>

    <div class="table-container">
        <h2 style="font-size: 1.2rem; margin-bottom: 1rem;">Detailed Test Execution Results</h2>
        <input type="text" class="search" id="searchInput" placeholder="Filter by Test ID, Module, Status or Priority..." onkeyup="filterTable()">
        <table id="testTable">
            <thead>
                <tr>
                    <th>Test ID</th>
                    <th>Module</th>
                    <th>Priority</th>
                    <th>Duration</th>
                    <th>Status</th>
                    <th>Expected Result</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
"""
        for t in test_results:
            status_class = "badge-pass" if t.status == "PASSED" else "badge-fail"
            detail = t.error_message if t.status == "FAILED" else (t.actual_result or "Verified")
            html_content += f"""
                <tr>
                    <td><code>{t.test_id}</code></td>
                    <td>{t.module}</td>
                    <td><span class="badge badge-prio">{t.priority}</span></td>
                    <td>{t.execution_time_s:.3f}s</td>
                    <td><span class="badge {status_class}">{t.status}</span></td>
                    <td style="max-width: 300px; color: var(--text-muted);">{t.expected_result}</td>
                    <td style="max-width: 300px;">{detail}</td>
                </tr>
"""
        html_content += f"""
            </tbody>
        </table>
    </div>

    <script>
        const donutCtx = document.getElementById('donutChart').getContext('2d');
        new Chart(donutCtx, {{
            type: 'doughnut',
            data: {{
                labels: ['Passed', 'Failed', 'Skipped'],
                datasets: [{{
                    data: [{passed}, {failed}, {skipped}],
                    backgroundColor: ['#10b981', '#ef4444', '#f59e0b'],
                    borderWidth: 0
                }}]
            }},
            options: {{ responsive: true, plugins: {{ legend: {{ position: 'bottom', labels: {{ color: '#94a3b8' }} }} }} }}
        }});

        const barCtx = document.getElementById('barChart').getContext('2d');
        const moduleNames = {json.dumps([m['module'] for m in module_data])};
        const passRates = {json.dumps([m['rate'] for m in module_data])};
        new Chart(barCtx, {{
            type: 'bar',
            data: {{
                labels: moduleNames,
                datasets: [{{
                    label: 'Pass Rate %',
                    data: passRates,
                    backgroundColor: '#38bdf8',
                    borderRadius: 6
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{ min: 0, max: 100, ticks: {{ color: '#94a3b8' }} }},
                    x: {{ ticks: {{ color: '#94a3b8', maxRotation: 45, minRotation: 45 }} }}
                }},
                plugins: {{ legend: {{ display: false }} }}
            }}
        }});

        function filterTable() {{
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const rows = document.querySelectorAll('#testTable tbody tr');
            rows.forEach(row => {{
                const text = row.innerText.toLowerCase();
                row.style.display = text.includes(filter) ? '' : 'none';
            }});
        }}
    </script>
</body>
</html>
"""
        with open(os.path.join(self.output_dir, "dashboard.html"), "w", encoding="utf-8") as f:
            f.write(html_content)

    def _generate_execution_report(self, test_results: List[TestCaseMetadata], metrics: Dict[str, Any]):
        # Also copy / link as execution-report.html
        dashboard_path = os.path.join(self.output_dir, "dashboard.html")
        exec_path = os.path.join(self.output_dir, "execution-report.html")
        with open(dashboard_path, "r", encoding="utf-8") as src, open(exec_path, "w", encoding="utf-8") as dst:
            dst.write(src.read())
