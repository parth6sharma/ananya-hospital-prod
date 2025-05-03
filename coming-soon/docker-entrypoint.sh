#!/bin/sh
set -e

# get certs if not
if [ ! -f /etc/letsencrypt/live/ananyahospital.com/fullchain.pem ]; then
    /usr/local/bin/renew-certs.sh
fi

# Start cron for auto renewals
crond -l 2 -b

# nginx
exec nginx -g "daemon off;"