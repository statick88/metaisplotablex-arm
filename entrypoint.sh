#!/bin/bash
# =============================================================================
# Metasploitable3 ARM64 — Entrypoint Script
# Handles first-boot DB initialization before handing off to supervisord
# =============================================================================
set -e

DB_INIT_MARKER="/var/lib/mysql/.ms3_initialized"

# -----------------------------------------------------------------------------
# MariaDB bootstrap (only on first start)
# Runs mysqld with skip-grant-tables to set root with no password + create dvwa db
# -----------------------------------------------------------------------------
if [ ! -f "$DB_INIT_MARKER" ]; then
    echo "[entrypoint] Initializing MariaDB for the first time..."

    # Start mysqld temporarily for bootstrapping
    mysqld_safe --skip-grant-tables --skip-networking &
    MYSQL_PID=$!
    sleep 5

    mysql -u root <<-EOSQL
        FLUSH PRIVILEGES;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '';
        CREATE DATABASE IF NOT EXISTS dvwa CHARACTER SET utf8mb4;
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;
        GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'%' IDENTIFIED BY 'p@ssw0rd';
        FLUSH PRIVILEGES;
EOSQL

    kill $MYSQL_PID
    wait $MYSQL_PID 2>/dev/null || true
    touch "$DB_INIT_MARKER"
    echo "[entrypoint] MariaDB initialized."
fi

# -----------------------------------------------------------------------------
# Ensure runtime dirs exist
# -----------------------------------------------------------------------------
mkdir -p /var/run/apache2 /var/run/sshd /var/log/supervisor /var/run/supervisor

echo "[entrypoint] Starting supervisord..."
exec "$@"
