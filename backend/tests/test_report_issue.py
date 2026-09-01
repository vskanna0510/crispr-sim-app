import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_report_issue_flow():
    # 1. Login user to get token
    res_auth = client.post(
        "/auth/google",
        json={
            "id_token": "mock_report_issue_token",
            "email": "issue_tester@gmail.com",
            "full_name": "Issue Tester",
        },
    )
    assert res_auth.status_code == 200
    token = res_auth.json()["access_token"]

    # 2. Submit issue report
    payload = {
        "category": "simulation_error",
        "severity": "high",
        "title": "Cas12a staggered cleavage point calculation error",
        "description": "When using Cas12a TTTV on an AT-rich target, the 5-nt overhang was 1 bp off from expected coordinate.",
        "steps_to_reproduce": "1. Enter AT-rich sequence. 2. Select Cas12a. 3. Run cleavage simulation.",
        "system_info": {"app_version": "v2.4.0", "platform": "Web"},
    }
    res_report = client.post(
        "/settings/report-issue",
        json=payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res_report.status_code == 200
    data = res_report.json()
    assert "CRISPR-TKT-" in data["ticket_id"]
    assert data["category"] == "simulation_error"
    assert data["severity"] == "high"
    assert data["status"] == "open"

    # 3. List user issues
    res_list = client.get(
        "/settings/issues",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert res_list.status_code == 200
    issues = res_list.json()
    assert len(issues) >= 1
    assert any(i["ticket_id"] == data["ticket_id"] for i in issues)
