"""
TDD — MariaDB CVE assertions (May 2026 update)

CVE-2021-27928 (HIGH): SET GLOBAL wsrep_provider OS command injection
  Authenticated with root:empty — sets wsrep_provider to attacker .so path
  RED:  wsrep_provider variable not settable
  GREEN: SET GLOBAL wsrep_provider accepted (injection vector confirmed)

mysql_udf_payload: UDF .so upload via FILE priv → sys_exec()
  RED:  plugin dir not writable or FILE priv absent
  GREEN: SELECT @@plugin_dir returns writable path
"""

import socket
import pytest


def test_mysql_port_accessible(target: str) -> None:
    """MariaDB must be reachable on port 3306 from outside the container."""
    with socket.create_connection((target, 3306), timeout=5) as s:
        data = s.recv(256)
        assert len(data) > 0


def test_mysql_greeting_identifies_mariadb(target: str) -> None:
    """MariaDB greeting must identify the server type."""
    with socket.create_connection((target, 3306), timeout=5) as s:
        data = s.recv(256).decode("latin-1", errors="replace")
        assert "MariaDB" in data or "mysql" in data.lower()
