# Metasploitable3 ARM64 — Docker Lab

> ⚠️ **WARNING**: This container exposes **intentionally vulnerable** services.
> Use **EXCLUSIVELY** on isolated private networks for educational and CTF purposes.
> **NEVER expose to the internet or production networks.**

[![Docker Build](https://github.com/your-username/metasploitable3-arm/actions/workflows/docker-build.yml/badge.svg)](https://github.com/your-username/metasploitable3-arm/actions/workflows/docker-build.yml)
[![Tests](https://github.com/your-username/metasploitable3-arm/actions/workflows/tests.yml/badge.svg)](https://github.com/your-username/metasploitable3-arm/actions/workflows/tests.yml)

---

## Vulnerable Services

| Port | Service | Vulnerability |
|------|---------|---------------|
| 21 | vsftpd | Anonymous login, backdoor emulated on port 6200 |
| 22 | OpenSSH | `root:root` credentials, password auth enabled |
| 80 | Apache + DVWA | SQLi, RCE, XSS, CSRF, File Upload (security: low) |
| 139/445 | Samba 4 | Anonymous share, CVE-2007-2447 username map script |
| 3306 | MariaDB | root with no password, bound to 0.0.0.0 |
| 6200 | Backdoor shell | `nc -lkp 6200 -e /bin/bash` |
| 8080 | Tomcat 9 | Manager app with `tomcat:tomcat` credentials |
| 8585 | Apache RCE | `GET /shell.php?cmd=id` endpoint |

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
# Clone
git clone https://github.com/your-username/metasploitable3-arm.git
cd metasploitable3-arm

# Start the lab
docker compose up -d

# Verify all services are up
docker exec metasploitable3 supervisorctl status
```

---

## Build Multi-Platform Image (Docker Hub)

```bash
# Create builder (once)
docker buildx create --name ms3-builder --use
docker buildx inspect --bootstrap

# Build and push
docker buildx build \
  --platform linux/arm64,linux/amd64 \
  -t your-username/metasploitable3-arm:latest \
  --push .
```

---

## Connecting Kali Linux ARM (UTM / Parallels)

### Option A — Via Host IP

From your Kali VM, the Mac host IP (typically `192.168.64.1` on UTM) routes to Docker:

```bash
export TARGET=192.168.64.1

# Full port scan
nmap -sV -p 21,22,80,139,445,3306,6200,8080,8585 $TARGET
```

### Option B — Direct Container IP

If Kali shares the Docker bridge `172.20.0.0/24`:

```bash
nmap -sV 172.20.0.10
```

### Quick Access Commands

```bash
# SSH (root:root)
ssh root@$TARGET

# FTP anonymous
ftp $TARGET

# DVWA
curl http://$TARGET/dvwa/

# Tomcat Manager
curl http://tomcat:tomcat@$TARGET:8080/manager/html

# MySQL root (no password)
mysql -h $TARGET -u root

# RCE test
curl "http://$TARGET:8585/shell.php?cmd=whoami"

# SMB
smbclient -L //$TARGET -N
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
# With the container running:
pytest tests/ -v
```

## Shutdown

```bash
docker compose down
```
