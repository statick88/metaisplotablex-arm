"""
TDD — HTTP/Apache vulnerability assertions.
  RED:   DVWA not found, RCE endpoint not responding
  GREEN: DVWA index reachable, shell.php executes commands
"""

import requests
import pytest


def test_dvwa_reachable(target: str) -> None:
    """DVWA index page must return 200."""
    r = requests.get(f"http://{target}/dvwa/", timeout=10)
    assert r.status_code == 200
    assert "DVWA" in r.text or "Damn" in r.text


def test_rce_shell_executes_command(target: str) -> None:
    """RCE shell on port 8585 must execute arbitrary OS commands."""
    r = requests.get(f"http://{target}:8585/shell.php", params={"cmd": "id"}, timeout=10)
    assert r.status_code == 200
    assert "uid=" in r.text


def test_web_flag_readable(target: str) -> None:
    """CTF flag at /flag.txt must be readable via HTTP."""
    r = requests.get(f"http://{target}/flag.txt", timeout=10)
    assert r.status_code == 200
    assert "FLAG{" in r.text
