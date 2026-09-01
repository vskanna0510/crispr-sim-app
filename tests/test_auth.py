"""Authentication and security tests."""

import os

import pytest

os.environ["REQUIRE_AUTH"] = "false"


def test_register_login_flow(client):
    email = "testuser@example.com"
    password = "testpass123"

    reg = client.post(
        "/auth/register",
        json={"email": email, "password": password, "full_name": "Test User"},
    )
    if reg.status_code == 409:
        login = client.post("/auth/login", json={"email": email, "password": password})
        assert login.status_code == 200
        token = login.json()["access_token"]
    else:
        assert reg.status_code == 201
        token = reg.json()["access_token"]

    me = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["email"] == email

    logout = client.post("/auth/logout", headers={"Authorization": f"Bearer {token}"})
    assert logout.status_code == 204


def test_sequence_without_auth_when_disabled(client):
  """REQUIRE_AUTH=false allows legacy test client usage."""
  resp = client.post("/sequence/paste", json={"sequence": "ATGC" * 20})
  assert resp.status_code == 200
  assert resp.json()["session_id"]
