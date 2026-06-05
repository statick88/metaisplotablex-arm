"""
TDD — Port reachability tests.
Each test follows the red→green cycle:
  RED:   port closed / service not running
  GREEN: service started by supervisord, port open
"""

import socket
import pytest

SERVICES: dict[str, int] = {
    "ftp":          21,
    "http":         80,
    "proftpd":      2121,
    "smb":          445,
    "mysql":        3306,
    "backdoor":     6200,
    "redis":        6379,
    "irc":          6667,
    "tomcat_ajp":   8009,
    "tomcat_http":  8080,
    "rce_shell":    8585,
}

TARGET_HOST = "localhost"


def _tcp_open(host: str, port: int) -> bool:
    try:
        with socket.create_connection((host, port), timeout=5):
            return True
    except OSError:
        return False


@pytest.mark.parametrize("service,port", SERVICES.items())
def test_service_port_open(target: str, service: str, port: int) -> None:
    """Every declared service must have its TCP port open."""
    assert _tcp_open(target, port), (
        f"Service '{service}' not reachable on {target}:{port}. "
        f"Check: docker exec metaisplotablex supervisorctl status"
    )
