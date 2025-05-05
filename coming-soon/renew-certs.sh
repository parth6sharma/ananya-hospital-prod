#!/bin/sh
set -e

# Directories
CONFIG_DIR="/etc/letsencrypt"
WORK_DIR="/var/lib/letsencrypt"
LOG_DIR="/var/log/letsencrypt"

# Renew certificates
echo "Renewing SSL certificates..."
certbot renew --nginx \
    --non-interactive \
    --agree-tos \
    --config-dir "$CONFIG_DIR" \
    --work-dir "$WORK_DIR" \
    --logs-dir "$LOG_DIR"

# Reload nginx to apply new certificates
if [ -f /var/run/nginx/nginx.pid ]; then
    echo "Reloading nginx..."
    nginx -s reload
fi