FROM nginx:1.21-alpine

# Install certbot and create directories with proper permissions
RUN apk add --no-cache certbot certbot-nginx dcron && \
    mkdir -p /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /var/www/certbot /tmp/nginx-conf && \
    chown -R nginx:nginx /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /var/www/certbot /tmp/nginx-conf && \
    chmod -R 755 /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt /var/www/certbot /tmp/nginx-conf

# Disable problematic entrypoint scripts
RUN rm -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh

# Copy configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /nginx-config/
COPY docker-entrypoint.sh /
COPY renew-certs.sh /usr/local/bin/

# Set permissions
RUN chmod +x /docker-entrypoint.sh /usr/local/bin/renew-certs.sh && \
    chown -R nginx:nginx /usr/share/nginx/html /nginx-config && \
    chmod -R 755 /usr/share/nginx/html /nginx-config

# Modify nginx.conf
# RUN sed -i 's|pid /var/run/nginx.pid|pid /var/run/nginx/nginx.pid|' /etc/nginx/nginx.conf

RUN rm -f /etc/nginx/conf.d/default.conf

USER root

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]