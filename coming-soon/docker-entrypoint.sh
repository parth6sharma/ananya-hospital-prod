#!/bin/sh
set -e

# Directories setup
CONFIG_DIR="/etc/letsencrypt"
WORK_DIR="/var/lib/letsencrypt"
LOG_DIR="/var/log/letsencrypt"
TMP_CONF_DIR="/tmp/nginx-conf"

# Ensure directories exist with proper permissions
mkdir -p "$CONFIG_DIR" "$WORK_DIR" "$LOG_DIR" /var/www/certbot "$TMP_CONF_DIR"
chown -R nginx:nginx "$CONFIG_DIR" "$WORK_DIR" "$LOG_DIR" /var/www/certbot "$TMP_CONF_DIR"
chmod -R 755 "$CONFIG_DIR" "$WORK_DIR" "$LOG_DIR" /var/www/certbot "$TMP_CONF_DIR"

# Temporary Nginx config for initial certificate generation
if [ ! -f "$CONFIG_DIR/live/ananyahospital.com/fullchain.pem" ]; then
    echo "Setting up temporary Nginx configuration..."
    
    # Create config in temporary directory
    cat > "$TMP_CONF_DIR/default.conf" <<EOF
server {
    listen 80;
    server_name ananyahospital.com www.ananyahospital.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF
    
    # Copy to nginx conf.d with proper permissions
    # rm -f /etc/nginx/conf.d/default.conf
    cp "$TMP_CONF_DIR/default.conf" /etc/nginx/conf.d/default.conf
    chown nginx:nginx /etc/nginx/conf.d/default.conf
    
    # Start Nginx for ACME challenge
    echo "Starting temporary Nginx server..."
    nginx -g "daemon on;"
    
    # Generate certificates
    echo "Generating SSL certificates..."
    certbot certonly --nginx \
        -d ananyahospital.com \
        -d www.ananyahospital.com \
        --non-interactive \
        --agree-tos \
        --email yashjain0333@gmail.com \
        --config-dir "$CONFIG_DIR" \
        --work-dir "$WORK_DIR" \
        --logs-dir "$LOG_DIR" \
        --keep-until-expiring \
        --preferred-challenges dns-01
        
    # Stop temporary Nginx
    echo "Stopping temporary Nginx server..."
    nginx -s stop
    
    # Install final Nginx config
    echo "Installing final Nginx configuration..."
    cp /nginx-config/default.conf /etc/nginx/conf.d/default.conf
    chown nginx:nginx /etc/nginx/conf.d/default.conf
fi

# Start cron for renewals
echo "Starting cron for certificate renewals..."
crond -l 2 -b

# Test and start Nginx
echo "Testing Nginx configuration..."
nginx -t
echo "Starting Nginx server..."
exec nginx -g "daemon off;"