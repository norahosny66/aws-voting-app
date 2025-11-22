FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force
RUN apk add --no-cache python3 py3-pip
RUN pip3 install --no-cache-dir Flask==2.3.3 redis==5.2.0 requests==2.32.0

# Create non-root user (Alpine uses different approach)
# Don't use GID 1000 - it's already used by node:18-alpine
# Use a different GID and UID
RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80

CMD ["node", "server.js"]
