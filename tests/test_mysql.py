"""
TDD — MariaDB vulnerability assertions.
  RED:   root requires password or only listens on 127.0.0.1
  GREEN: root login with empty password works from any host
"""

import socket
import pytest


def test_mysql_port_accessible(target: str) -> None:
    """MariaDB must be reachable on port 3306 from outside the container."""
    with socket.create_connection((target, 3306), timeout=5) as s:
        # MySQL/MariaDB sends a greeting packet immediately
        data = s.recv(128)
        assert len(data) > 0, "No greeting from MariaDB"


def test_mysql_greeting_contains_version(target: str) -> None:
    """MariaDB greeting must identify the server."""
    with socket.create_connection((target, 3306), timeout=5) as s:
        data = s.recv(256).decode("latin-1", errors="replace")
        assert "MariaDB" in data or "mysql" in data.lower()
