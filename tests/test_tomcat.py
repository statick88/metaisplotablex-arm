"""
TDD — Tomcat vulnerability assertions.
  RED:   manager app returns 401 or is unreachable
  GREEN: tomcat:tomcat grants access to /manager/html
"""

import requests
from requests.auth import HTTPBasicAuth
import pytest


def test_tomcat_manager_accessible(target: str) -> None:
    """Tomcat manager must be accessible with tomcat:tomcat credentials."""
    r = requests.get(
        f"http://{target}:8080/manager/html",
        auth=HTTPBasicAuth("tomcat", "tomcat"),
        timeout=15,
    )
    assert r.status_code == 200
    assert "Tomcat" in r.text or "Manager" in r.text


def test_tomcat_manager_rejects_no_auth(target: str) -> None:
    """Tomcat manager must require authentication (returns 401 without creds)."""
    r = requests.get(f"http://{target}:8080/manager/html", timeout=10)
    assert r.status_code == 401
