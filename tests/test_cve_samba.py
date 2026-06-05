"""
TDD — Samba CVE assertions (May 2026 update)

CVE-2017-7494 SambaCry (CRITICAL, CVSS 9.8)
  Writable anonymous share allows .so upload → is_known_pipename RCE
  RED:  public share is read-only or not anonymous
  GREEN: anonymous write succeeds (upload vector confirmed)

CVE-2007-2447 simulation
  username map script injection via smb.conf
  RED:  username map script not configured
  GREEN: smb.conf contains 'username map script' (config verified)
"""

import socket
import subprocess
import pytest


def test_smb_port_open(target: str) -> None:
    """SMB port 445 must be open."""
    with socket.create_connection((target, 445), timeout=5):
        pass


def test_samba_anonymous_share_writable(target: str) -> None:
    """CVE-2017-7494: public share must be writable without credentials."""
    result = subprocess.run(
        ["smbclient", f"//{target}/public", "-N",
         "-c", "put /etc/hostname test_cve_2017_7494.txt"],
        capture_output=True, text=True, timeout=15
    )
    assert result.returncode == 0 or "NT_STATUS_OK" in result.stdout, (
        f"Anonymous write to public share failed: {result.stderr}"
    )
