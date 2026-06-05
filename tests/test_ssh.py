"""
TDD — SSH vulnerability assertions.
  RED:   SSH rejects root login or password auth
  GREEN: root:root auth succeeds, banner present
"""

import paramiko
import pytest


def test_ssh_root_login(target: str) -> None:
    """SSH must accept root login with password 'root'."""
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(target, port=22, username="root", password="root", timeout=10)
        _, stdout, _ = client.exec_command("id")
        output = stdout.read().decode()
        assert "uid=0(root)" in output
    finally:
        client.close()


def test_ssh_msfadmin_login(target: str) -> None:
    """SSH must accept msfadmin:msfadmin credentials."""
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(target, port=22, username="msfadmin", password="msfadmin", timeout=10)
        _, stdout, _ = client.exec_command("whoami")
        assert "msfadmin" in stdout.read().decode()
    finally:
        client.close()


def test_ssh_banner_present(target: str) -> None:
    """SSH banner must warn about intentionally vulnerable lab."""
    transport = paramiko.Transport((target, 22))
    try:
        transport.start_client(timeout=10)
        banner = transport.get_banner()
        assert banner is not None and b"METASPLOITABLE3" in banner.upper()
    finally:
        transport.close()
