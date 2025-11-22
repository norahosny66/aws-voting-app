FROM node:18-alpine

WORKDIR /app

# Install Node dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Install Python, pip, and build dependencies for Python packages
RUN apk add --no-cache python3 py3-pip build-base libffi-dev openssl-dev

# Upgrade pip (optional but recommended)
RUN pip3 install --upgrade pip

# Install Python packages
RUN pip3 install --no-cache-dir Flask==2.3.3 redis==5.2.0 requests==2.32.0

# Create non-root user
RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy app code
COPY --chown=appuser:appuser . .

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80

CMD ["node", "server.js"]
