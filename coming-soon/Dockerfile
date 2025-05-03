FROM nginx:1.21-alpine

# Install certbot and dependencies
RUN apk add --no-cache certbot certbot-nginx && \
    mkdir -p /etc/letsencrypt && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /var/cache/nginx /var/run/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chmod -R 755 /etc/nginx/conf.d

# Disable problematic entrypoint scripts
RUN rm -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh

# Copy configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/

# Copy static files
COPY index.html /usr/share/nginx/html/

# Set permissions for web content
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chown nginx:nginx /var/log/nginx && \
    chmod 755 /var/log/nginx

# Remove any 'user' directive from nginx.conf
RUN sed -i '/user /d' /etc/nginx/nginx.conf
RUN sed -i 's|pid /var/run/nginx.pid|pid /var/run/nginx/nginx.pid|' /etc/nginx/nginx.conf

# Add certificate renewal script
COPY renew-certs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/renew-certs.sh

# Add entrypoint wrapper
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

USER nginx

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443