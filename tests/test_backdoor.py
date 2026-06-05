"""
TDD — Backdoor shell assertions (vsftpd 2.3.4 emulation on port 6200).
  RED:   port 6200 closed
  GREEN: nc connects, shell responds to commands
"""

import socket
import pytest


def test_backdoor_port_open(target: str) -> None:
    """Backdoor simulation must be listening on port 6200."""
    with socket.create_connection((target, 6200), timeout=10) as s:
        # Send a command and expect a response
        s.sendall(b"id\n")
        response = s.recv(256).decode("utf-8", errors="replace")
        assert "uid=" in response, (
            f"Expected shell response with 'uid=', got: {response!r}"
        )
