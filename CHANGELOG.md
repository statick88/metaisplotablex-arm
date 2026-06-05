# Changelog

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) — [Semver](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-06-05

### Added — CVE Update (up to May 2026)

| CVE | Service | Severity | Description |
|-----|---------|----------|-------------|
| CVE-2024-6387 | OpenSSH | CRITICAL | regreSSHion — signal handler race, unauthenticated RCE as root |
| CVE-2024-38474 | Apache | CRITICAL | mod_rewrite encoding substitution flaw — CGI RCE via encoded path |
| CVE-2024-40725 | Apache | HIGH | Source disclosure via mod_rewrite RewriteRule pattern |
| CVE-2012-1823 | PHP-CGI | CRITICAL | Argument injection in PHP-CGI — unauthenticated RCE via query string |
| CVE-2025-24813 | Tomcat 9 | CRITICAL | Partial PUT + Java deserialization — unauthenticated RCE |
| CVE-2020-1938 | Tomcat 9 | CRITICAL | Ghostcat — AJP port 8009 file read/inclusion → RCE |
| CVE-2021-27928 | MariaDB | HIGH | SET GLOBAL wsrep_provider OS command injection |
| mysql_udf_payload | MariaDB | HIGH | UDF .so upload via FILE priv → sys_exec() OS commands |
| CVE-2017-7494 | Samba | CRITICAL | SambaCry — .so from writable share → is_known_pipename RCE |
| CVE-2007-2447 | Samba | HIGH | username map script injection (existing, now documented) |

### Changed
- Dockerfile: `openssh-server` pinned and held to prevent upgrade past CVE-2024-6387
- Tomcat: `server.xml` added with AJP connector on port 8009 (`secretRequired=false`)
- Tomcat: `webapps/ROOT/uploads/` created writable for CVE-2025-24813
- MariaDB: `/usr/lib/mysql/plugin/` made writable for UDF payload upload
- Samba: `smb.conf` writable share retained for SambaCry (CVE-2017-7494)
- `docker-compose.yml`: port 8009 (AJP) added to mappings
- `supervisord.conf`: Tomcat section updated

### Added — Tests
- `tests/test_cve_tomcat.py` — AJP port + partial PUT assertions
- `tests/test_cve_apache.py` — PHP-CGI arg injection + rewrite endpoint
- `tests/test_cve_samba.py` — anonymous write share confirmation
- `tests/test_cve_mysql.py` — MariaDB greeting + port assertions
- `tests/conftest.py` — SERVICES dict updated with port 8009

## [1.0.0] - 2026-06-05

### Added
- Ubuntu 22.04 LTS base image with ARM64 native support
- OpenSSH server: root:root credentials, password auth
- vsftpd: anonymous login, backdoor simulation on port 6200
- Apache 2 + DVWA: SQLi, RCE, XSS, CSRF, File Upload (security: low)
- Apache vhost on port 8585 with PHP RCE shell
- MariaDB: root with no password, bind on 0.0.0.0
- Tomcat 9: manager app with default credentials (tomcat:tomcat)
- Samba 4: anonymous share, CVE-2007-2447 username map script simulation
- CTF flags in /root, /var/www/html, /srv/ftp, /srv/samba/public
- supervisord process manager, entrypoint.sh first-boot DB init
- docker-compose.yml with ms3net bridge (172.20.0.0/24)
- Multi-arch Docker Buildx support (linux/arm64 + linux/amd64)
- TDD test suite with pytest + paramiko + requests
- GitHub Actions CI/CD workflows
- Full documentation: README, CONTRIBUTING, SECURITY, CHANGELOG
