# Builder stage for certificates and configurations
FROM alpine:3.15 as certs-config

# Create directory structure with correct permissions
RUN mkdir -p /etc/nginx/ssl && \
    mkdir -p /output/conf.d && \
    chmod -R 755 /etc/nginx/ssl /output/conf.d

# Copy certificates with strict permissions
COPY dev-certs/server.crt /etc/nginx/ssl/
COPY dev-certs/server.key /etc/nginx/ssl/
RUN chmod 644 /etc/nginx/ssl/server.crt && \
    chmod 600 /etc/nginx/ssl/server.key

# Copy configurations
COPY nginx.conf /output/nginx.conf
COPY default.conf /output/conf.d/default.conf

# Copy static files
COPY index.html /output/html/

# Final stage
FROM nginx:1.21-alpine

# Add metadata for Artifact Registry
LABEL org.opencontainers.image.source="https://github.com/parth6sharma/ananya-hospital-prod"
LABEL org.opencontainers.image.description="Nginx for Ananya Hospital"
LABEL org.opencontainers.image.licenses="MIT"

# Disable problematic entrypoint scripts
RUN rm -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh

# Create necessary directories with correct permissions
RUN mkdir -p /var/cache/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /var/cache/nginx /var/run/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chmod -R 755 /etc/nginx/conf.d && \
    mkdir -p /etc/nginx/ssl && \
    chown -R nginx:nginx /etc/nginx/ssl && \
    chmod 700 /etc/nginx/ssl && \
    chown nginx:nginx /var/log/nginx && \
    chmod 755 /var/log/nginx

# Copy from builder stage
COPY --from=certs-config /etc/nginx/ssl/ /etc/nginx/ssl/
COPY --from=certs-config /output/nginx.conf /etc/nginx/nginx.conf
COPY --from=certs-config /output/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --from=certs-config /output/html/index.html /usr/share/nginx/html/

# Set permissions for web content
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Remove any 'user' directive from nginx.conf
RUN sed -i '/user /d' /etc/nginx/nginx.conf && \
    sed -i 's|pid /var/run/nginx.pid|pid /var/run/nginx/nginx.pid|' /etc/nginx/nginx.conf

# Run as non-root user
USER nginx

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443