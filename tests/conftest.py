"""
Shared pytest fixtures — Metasploitable3 ARM64 (extended CVE May 2026)
Requires: docker compose up -d && sleep 60
"""

import socket
import time
import pytest

TARGET_HOST = "localhost"

SERVICES: dict[str, int] = {
    "ftp":          21,
    "ssh":          22,
    "http":         80,
    "proftpd":      2121,   # CVE-2015-3306 mod_copy
    "smb":          445,
    "mysql":        3306,
    "backdoor":     6200,
    "redis":        6379,   # CVE-2022-0543
    "irc":          6667,   # CVE-2010-2075 UnrealIRCd
    "tomcat_ajp":   8009,   # CVE-2020-1938 Ghostcat
    "tomcat_http":  8080,   # CVE-2025-24813 + Log4Shell
    "rce_shell":    8585,
}


def _wait_for_port(host: str, port: int, timeout: float = 30.0) -> bool:
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
    assert _wait_for_port(target, 22, timeout=120), (
        "Container not ready. Run: docker compose up -d && sleep 60"
    )
