# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) — [Semver](https://semver.org/).

## [Unreleased]

## [1.2.0] - 2026-06-05

### Added — Extended CVE Coverage (May 2026)

| CVE | Service | Port | Severity | Metasploit Module |
|-----|---------|------|----------|-------------------|
| CVE-2014-6271 | Bash/Apache mod_cgi | 80 | CRITICAL | `exploit/multi/http/apache_mod_cgi_bash_env_exec` |
| CVE-2015-3306 | ProFTPd mod_copy | 2121 | CRITICAL | `exploit/unix/ftp/proftpd_modcopy_exec` |
| CVE-2021-44228 | Log4Shell/Tomcat | 8080 | CRITICAL | `exploit/multi/http/log4shell_header_injection` |
| CVE-2022-0543 | Redis Lua sandbox | 6379 | CRITICAL | `exploit/linux/redis/redis_replication_cmd_exec` |
| CVE-2010-2075 | UnrealIRCd 3.2.8.1 | 6667 | CRITICAL | `exploit/unix/irc/unreal_ircd_3281_backdoor` |
| CVE-2021-4034 | PwnKit polkit LPE | — | CRITICAL | `exploit/linux/local/cve_2021_4034_pwnkit_lpe` |

### Added — Services
- ProFTPd on port 2121 (`config/proftpd/proftpd.conf`)
- Redis on port 6379 (`config/redis/redis.conf`) — no auth, bind 0.0.0.0
- UnrealIRCd on port 6667 (built from source or simulation)
- Shellshock CGI endpoint at `/cgi-bin/status`
- Log4Shell vulnerable webapp deployed as `log4shell.war` on Tomcat

### Added — Tests
- `tests/test_cve_additional.py` — Redis, IRC, ProFTPd, Shellshock, Log4Shell assertions
- `tests/conftest.py` — ports 2121, 6379, 6667 added to SERVICES dict

### Changed
- `docker-compose.yml` — ports 2121, 6379, 6667 added; memory limit 2G→3G
- `supervisord.conf` — proftpd, redis, ircd programs added
- `Dockerfile` — proftpd, redis-server, policykit-1 packages added

## [1.1.0] - 2026-06-05

### Added — CVE Update

| CVE | Service | Severity |
|-----|---------|----------|
| CVE-2024-6387 | OpenSSH regreSSHion | CRITICAL |
| CVE-2024-38474 | Apache mod_rewrite | CRITICAL |
| CVE-2012-1823 | PHP-CGI arg injection | CRITICAL |
| CVE-2025-24813 | Tomcat partial PUT | CRITICAL |
| CVE-2020-1938 | Tomcat Ghostcat AJP | CRITICAL |
| CVE-2021-27928 | MariaDB wsrep_provider | HIGH |
| mysql_udf_payload | MariaDB UDF | HIGH |
| CVE-2017-7494 | Samba SambaCry | CRITICAL |
| CVE-2007-2447 | Samba username map | HIGH |

## [1.0.0] - 2026-06-05

### Added
- Ubuntu 22.04 LTS ARM64 base image (+ AMD64 via buildx)
- SSH root:root, vsftpd anonymous + backdoor sim port 6200
- Apache + DVWA (SQLi, XSS, CSRF, File Upload, RCE)
- RCE shell vhost port 8585
- MariaDB root no-password bind 0.0.0.0
- Tomcat 9 manager tomcat:tomcat
- Samba anonymous share
- CTF flags in /root, /var/www/html, /srv/ftp, /srv/samba/public
- supervisord + entrypoint.sh first-boot DB init
- docker-compose.yml isolated ms3net bridge (172.20.0.0/24)
- Multi-arch Docker Buildx (linux/arm64 + linux/amd64)
- TDD pytest suite, GitHub Actions CI/CD
