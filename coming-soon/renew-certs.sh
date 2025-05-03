#!/bin/sh
set -e

# Init certificate request
if [ ! -f /etc/letsencrypt/live/ananyahospital.com/fullchain.pem ]; then
    certbot certonly --nginx \
        -d ananyahospital.com \
        -d www.ananyahospital.com \
        --non-interactive \
        --agree-tos \
        --email your-email@example.com \
        --keep-until-expiring
fi

# Regular renewal
certbot renew --quiet --nginx