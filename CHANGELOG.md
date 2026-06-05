# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-06-05

### Added
- Ubuntu 22.04 LTS base image with ARM64 native support
- OpenSSH server: root:root credentials, password auth, insecure banner
- vsftpd: anonymous login, writable dirs, backdoor simulation on port 6200
- Apache 2 + DVWA: SQLi, RCE, XSS, CSRF, File Upload (security level: low)
- Apache vhost on port 8585 with PHP RCE shell (`?cmd=` endpoint)
- MariaDB: root with no password, bind on 0.0.0.0
- Tomcat 9: manager app with default credentials (tomcat:tomcat)
- Samba 4: anonymous public share, CVE-2007-2447 username map script simulation
- CTF flags in `/root`, `/var/www/html`, `/srv/ftp`, `/srv/samba/public`
- supervisord process manager keeping all services alive
- entrypoint.sh with first-boot MariaDB initialization
- docker-compose.yml with isolated ms3net bridge network (172.20.0.0/24)
- Multi-arch Docker Buildx support (linux/arm64 + linux/amd64)
- TDD test suite with pytest + docker-py validating all service ports
- GitHub Actions CI/CD: build + test workflow
- Full documentation: README, CONTRIBUTING, SECURITY, CHANGELOG
