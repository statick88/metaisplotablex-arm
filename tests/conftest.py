"""
Shared pytest fixtures for Metasploitable3 ARM64 test suite.
Requires the container to be running: docker compose up -d
"""

import socket
import time
import pytest


TARGET_HOST = "localhost"

# All services and their expected open ports
SERVICES: dict[str, int] = {
    "ftp":      21,
    "ssh":      22,
    "http":     80,
    "smb":      445,
    "mysql":    3306,
    "backdoor": 6200,
    "tomcat":   8080,
    "rce":      8585,
}


def _wait_for_port(host: str, port: int, timeout: float = 30.0) -> bool:
    """Poll until a TCP port is open or timeout expires."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.create_connection((host, port), timeout=2):
                return True
        except OSError:
            time.sleep(1)
    return False


@pytest.fixture(scope="session")
def target() -> str:
    return TARGET_HOST


@pytest.fixture(scope="session", autouse=True)
def wait_for_container(target: str) -> None:
    """Block until SSH (port 22) is reachable — proxy for container readiness."""
    assert _wait_for_port(target, 22, timeout=120), (
        "Container did not become ready within 120s. "
        "Run: docker compose up -d && sleep 60"
    )
