FROM nginx:1.21-alpine


# Create necessary directories with correct permissions
RUN mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /var/cache/nginx /var/run/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chmod -R 755 /etc/nginx/conf.d

# Disable problematic entrypoint scripts
RUN rm -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh

# Create SSL directory with correct permissions
RUN mkdir -p /etc/nginx/ssl && \
    chown -R nginx:nginx /etc/nginx/ssl && \
    chmod 700 /etc/nginx/ssl
    
# Remove default config and copy our config
RUN rm -rf /etc/nginx/conf.d/default.conf
# Copy configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy certificates with strict permissions
COPY dev-certs/server.crt /etc/nginx/ssl/
COPY dev-certs/server.key /etc/nginx/ssl/
RUN chmod 644 /etc/nginx/ssl/server.crt && \
    chmod 600 /etc/nginx/ssl/server.key && \
    chown nginx:nginx /etc/nginx/ssl/server.*

# Copy static files
COPY index.html /usr/share/nginx/html/

# Set permissions for web content
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html 
    
RUN chown nginx:nginx /var/log/nginx && \
    chmod 755 /var/log/nginx

# Remove any 'user' directive from nginx.conf
RUN sed -i '/user /d' /etc/nginx/nginx.conf
RUN sed -i 's|pid /var/run/nginx.pid|pid /var/run/nginx/nginx.pid|' /etc/nginx/nginx.conf


# Run as non-root user
USER nginx

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443





