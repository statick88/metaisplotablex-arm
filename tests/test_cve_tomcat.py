"""
TDD — Tomcat CVE assertions (May 2026 update)

CVE-2020-1938 Ghostcat (CRITICAL, CVSS 9.8)
  AJP port 8009 must be open and accepting connections
  RED:  port 8009 closed
  GREEN: AJP handshake received (4-byte magic prefix)

CVE-2025-24813 (CRITICAL, CVSS 9.8)
  Partial PUT + Java deserialization RCE (unauthenticated)
  RED:  PUT request rejected (405) or upload dir absent
  GREEN: partial PUT accepted (204/200) — deserialization vector active
"""

import socket
import struct
import requests
import pytest


def test_ajp_port_open(target: str) -> None:
    """CVE-2020-1938 Ghostcat: AJP connector must be open on port 8009."""
    with socket.create_connection((target, 8009), timeout=10) as s:
        # Send AJP13 forward request magic bytes
        s.sendall(b"\x12\x34\x00\x01\x02")
        data = s.recv(64)
        # AJP response starts with 0x41 0x42 ("AB")
        assert len(data) > 0, "AJP port 8009 accepted connection but sent no data"


def test_tomcat_partial_put_accepted(target: str) -> None:
    """CVE-2025-24813: partial PUT to /uploads/ must be accepted."""
    headers = {
        "Content-Type": "application/octet-stream",
        "Content-Range": "bytes 0-3/8",
    }
    r = requests.put(
        f"http://{target}:8080/uploads/test.session",
        headers=headers,
        data=b"\xac\xed",  # Java serialization magic bytes
        timeout=10,
    )
    # 204 No Content or 200 OK confirms partial PUT is enabled
    assert r.status_code in (200, 204, 201), (
        f"Partial PUT returned {r.status_code}. "
        "Check server.xml and webapps/ROOT/uploads/ permissions."
    )
